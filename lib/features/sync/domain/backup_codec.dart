import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../inventory/domain/ingredient_category.dart';
import '../../recipe/service/recipe_provider_factory.dart';

// ──────────────────────────────────────────────────────────────
// 独自例外
// ──────────────────────────────────────────────────────────────

/// バックアップファイルの形式が不正なときにスローされる例外。
class BackupFormatException implements Exception {
  const BackupFormatException(this.code, [this.detail = '']);

  /// エラーコード。
  /// - `newer_version`: formatVersion が現在のアプリより新しい
  /// - `invalid_format`: formatVersion が欠落 / 不正
  /// - `invalid_category`: ingredients の category 値が不正
  /// - `missing_field`: 必須フィールドが欠落
  final String code;
  final String detail;

  @override
  String toString() => 'BackupFormatException($code: $detail)';
}

// ──────────────────────────────────────────────────────────────
// バックアップ形式
// ──────────────────────────────────────────────────────────────

const int _kCurrentFormatVersion = 1;
const int _kCurrentAppDbSchemaVersion = 3;

// ──────────────────────────────────────────────────────────────
// BackupData（デコード結果）
// ──────────────────────────────────────────────────────────────

/// [BackupCodec.decodeBackup] が返すデコード済みデータ。
class BackupData {
  const BackupData({
    required this.ingredients,
    required this.settingsCompanion,
  });

  final List<Ingredient> ingredients;
  final SettingsTableCompanion settingsCompanion;
}

// ──────────────────────────────────────────────────────────────
// BackupCodec
// ──────────────────────────────────────────────────────────────

/// バックアップ JSON のエンコード / デコード純ロジック。
///
/// **バックアップ形式 v1:**
/// ```json
/// {
///   "formatVersion": 1,
///   "appDbSchemaVersion": 3,
///   "exportedAt": "2026-06-11T12:00:00.000Z",
///   "ingredients": [...],
///   "settings": { ... }
/// }
/// ```
abstract class BackupCodec {
  BackupCodec._();

  // ----------------------------------------------------------
  // encode
  // ----------------------------------------------------------

  /// [ingredients] と [settings] をバックアップ JSON 文字列にエンコードする。
  /// API キーは含まない。
  static String encodeBackup({
    required List<Ingredient> ingredients,
    required AppSettings settings,
  }) {
    final map = <String, dynamic>{
      'formatVersion': _kCurrentFormatVersion,
      'appDbSchemaVersion': _kCurrentAppDbSchemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'ingredients': ingredients.map(_encodeIngredient).toList(),
      'settings': _encodeSettings(settings),
    };
    return jsonEncode(map);
  }

  static Map<String, dynamic> _encodeIngredient(Ingredient ing) {
    return {
      'id': ing.id,
      'name': ing.name,
      'normalizedName': ing.normalizedName,
      'category': ing.category.name, // 列挙子名の文字列
      'quantity': ing.quantity,
      'unit': ing.unit,
      'expiryDate': ing.expiryDate?.toUtc().toIso8601String(),
      'updatedAt': ing.updatedAt.toUtc().toIso8601String(),
    };
  }

  static Map<String, dynamic> _encodeSettings(AppSettings settings) {
    return {
      'localePref': settings.localePref,
      'shoppingListId': settings.shoppingListId,
      'shoppingListName': settings.shoppingListName,
      'selectedProvider': settings.selectedProvider,
      'modelOverridesJson': settings.modelOverridesJson,
      'syncEnabled': settings.syncEnabled,
      'lastSyncedAt': settings.lastSyncedAt?.toUtc().toIso8601String(),
      'appliancesJson': settings.appliancesJson,
    };
  }

  // ----------------------------------------------------------
  // decode
  // ----------------------------------------------------------

  /// JSON 文字列をパースして [BackupData] に変換する。
  ///
  /// Throws [BackupFormatException] on invalid input.
  static BackupData decodeBackup(String json) {
    final dynamic raw;
    try {
      raw = jsonDecode(json);
    } catch (_) {
      throw const BackupFormatException('invalid_format', 'JSON parse failed');
    }

    if (raw is! Map<String, dynamic>) {
      throw const BackupFormatException('invalid_format', 'root is not object');
    }

    // formatVersion チェック
    final versionRaw = raw['formatVersion'];
    if (versionRaw == null || versionRaw is! int) {
      throw const BackupFormatException(
          'invalid_format', 'formatVersion missing or not int');
    }
    if (versionRaw > _kCurrentFormatVersion) {
      throw BackupFormatException(
          'newer_version', 'got $versionRaw, supports $_kCurrentFormatVersion');
    }

    // ingredients
    final ingredientsRaw = raw['ingredients'];
    if (ingredientsRaw == null || ingredientsRaw is! List) {
      throw const BackupFormatException(
          'missing_field', 'ingredients field missing');
    }
    final ingredients =
        (ingredientsRaw).map((e) => _decodeIngredient(e)).toList();

    // settings
    final settingsRaw = raw['settings'];
    if (settingsRaw == null || settingsRaw is! Map<String, dynamic>) {
      throw const BackupFormatException(
          'missing_field', 'settings field missing');
    }
    final companion = _decodeSettings(settingsRaw);

    return BackupData(ingredients: ingredients, settingsCompanion: companion);
  }

  static Ingredient _decodeIngredient(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const BackupFormatException('invalid_format', 'ingredient not object');
    }

    final id = _requireString(raw, 'id');
    final name = _requireString(raw, 'name');
    final normalizedName = _requireString(raw, 'normalizedName');
    final categoryStr = _requireString(raw, 'category');
    final quantityRaw = raw['quantity'];
    if (quantityRaw == null) {
      throw const BackupFormatException('missing_field', 'quantity');
    }
    final unit = _requireString(raw, 'unit');
    final updatedAtStr = _requireString(raw, 'updatedAt');

    // category
    final category = IngredientCategory.values
        .where((c) => c.name == categoryStr)
        .firstOrNull;
    if (category == null) {
      throw BackupFormatException('invalid_category', 'unknown: $categoryStr');
    }

    // quantity
    final double quantity;
    if (quantityRaw is num) {
      quantity = quantityRaw.toDouble();
    } else {
      throw const BackupFormatException('missing_field', 'quantity not num');
    }

    // expiryDate（nullable）
    final expiryDateStr = raw['expiryDate'] as String?;
    DateTime? expiryDate;
    if (expiryDateStr != null) {
      expiryDate = DateTime.parse(expiryDateStr).toLocal();
    }

    // updatedAt
    final updatedAt = DateTime.parse(updatedAtStr).toLocal();

    return Ingredient(
      id: id,
      name: name,
      normalizedName: normalizedName,
      category: category,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
      updatedAt: updatedAt,
    );
  }

  static SettingsTableCompanion _decodeSettings(Map<String, dynamic> raw) {
    final localePref = raw['localePref'] as String? ?? 'system';
    final shoppingListId = raw['shoppingListId'] as String?;
    final shoppingListName = raw['shoppingListName'] as String?;
    final rawProvider = raw['selectedProvider'] as String? ?? 'gemini';
    // 未知の providerId（旧版・破損バックアップ）は 'gemini' にフォールバック（クラッシュ/誤動作防止）。
    // supportedProviderIds は recipe_provider_factory の単一真実源。
    final selectedProvider =
        supportedProviderIds.contains(rawProvider) ? rawProvider : 'gemini';
    final modelOverridesJson = raw['modelOverridesJson'] as String? ?? '{}';
    final syncEnabled = raw['syncEnabled'] as bool? ?? false;
    final lastSyncedAtStr = raw['lastSyncedAt'] as String?;
    final appliancesJson = raw['appliancesJson'] as String? ?? '[]';

    DateTime? lastSyncedAt;
    if (lastSyncedAtStr != null) {
      lastSyncedAt = DateTime.parse(lastSyncedAtStr).toLocal();
    }

    return SettingsTableCompanion(
      id: const Value(0),
      localePref: Value(localePref),
      shoppingListId: Value(shoppingListId),
      shoppingListName: Value(shoppingListName),
      selectedProvider: Value(selectedProvider),
      modelOverridesJson: Value(modelOverridesJson),
      syncEnabled: Value(syncEnabled),
      lastSyncedAt: Value(lastSyncedAt),
      appliancesJson: Value(appliancesJson),
    );
  }

  // ----------------------------------------------------------
  // ユーティリティ
  // ----------------------------------------------------------

  static String _requireString(Map<String, dynamic> raw, String key) {
    final value = raw[key];
    if (value == null) {
      throw BackupFormatException('missing_field', key);
    }
    if (value is! String) {
      throw BackupFormatException('missing_field', '$key is not String');
    }
    return value;
  }
}
