import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/appliance.dart';
import '../domain/user_settings.dart';

/// アプリ設定（単一レコード）へのアクセス。
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;
  static const _rowId = 0;

  // ---- 読み出し ----

  /// settings テーブルの生の [AppSettings] 行を返す（バックアップ用）。
  /// 行が存在しない場合は null を返す。
  Future<AppSettings?> getRow() async {
    return (_db.select(_db.settingsTable)..where((t) => t.id.equals(_rowId)))
        .getSingleOrNull();
  }

  /// settings テーブルを [companion] の内容で完全置換（復元用）。
  /// API キー関連の列は含まないため、既存値はそのまま維持される。
  Future<void> replaceSettings(SettingsTableCompanion companion) async {
    await _db.into(_db.settingsTable).insertOnConflictUpdate(companion);
  }

  Future<UserSettings> get() async {
    final row = await (_db.select(_db.settingsTable)
          ..where((t) => t.id.equals(_rowId)))
        .getSingleOrNull();
    if (row == null) return const UserSettings(localePref: 'system');
    return _toSettings(row);
  }

  Stream<UserSettings> watch() {
    return (_db.select(_db.settingsTable)
          ..where((t) => t.id.equals(_rowId)))
        .watchSingleOrNull()
        .map((row) => row != null
            ? _toSettings(row)
            : const UserSettings(localePref: 'system'));
  }

  // ---- 書き込み（フィールド単位） ----

  Future<void> setLocalePref(String pref) => _upsert(
        localePref: Value(pref),
      );

  Future<void> setShoppingList(String? id, String? name) => _upsert(
        shoppingListId: Value(id),
        shoppingListName: Value(name),
      );

  Future<void> setSelectedProvider(String provider) => _upsert(
        selectedProvider: Value(provider),
      );

  /// プロバイダの使用モデルを設定する。[modelId] が null なら上書きを解除し
  /// 実装側のフォールバック既定値に戻す。
  Future<void> setModelOverride(String provider, String? modelId) async {
    final current = Map<String, String>.from((await get()).modelOverrides);
    if (modelId == null) {
      current.remove(provider);
    } else {
      current[provider] = modelId;
    }
    await _upsert(modelOverridesJson: Value(jsonEncode(current)));
  }

  Future<void> setSyncEnabled(bool enabled) => _upsert(
        syncEnabled: Value(enabled),
      );

  Future<void> setLastSyncedAt(DateTime? dt) => _upsert(
        lastSyncedAt: Value(dt),
      );

  Future<void> setAppliances(List<Appliance> appliances) => _upsert(
        appliancesJson: Value(
          jsonEncode(appliances.map((a) => a.toJson()).toList()),
        ),
      );

  // ---- 内部ユーティリティ ----

  /// 既存行を読み出して指定フィールドだけ上書きして保存（upsert）。
  Future<void> _upsert({
    Value<String> localePref = const Value.absent(),
    Value<String?> shoppingListId = const Value.absent(),
    Value<String?> shoppingListName = const Value.absent(),
    Value<String> selectedProvider = const Value.absent(),
    Value<String> modelOverridesJson = const Value.absent(),
    Value<bool> syncEnabled = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<String> appliancesJson = const Value.absent(),
  }) async {
    final existing = await (_db.select(_db.settingsTable)
          ..where((t) => t.id.equals(_rowId)))
        .getSingleOrNull();

    final companion = SettingsTableCompanion(
      id: const Value(_rowId),
      localePref: localePref.present
          ? localePref
          : Value(existing?.localePref ?? 'system'),
      shoppingListId: shoppingListId.present
          ? shoppingListId
          : Value(existing?.shoppingListId),
      shoppingListName: shoppingListName.present
          ? shoppingListName
          : Value(existing?.shoppingListName),
      selectedProvider: selectedProvider.present
          ? selectedProvider
          : Value(existing?.selectedProvider ?? 'gemini'),
      modelOverridesJson: modelOverridesJson.present
          ? modelOverridesJson
          : Value(existing?.modelOverridesJson ?? '{}'),
      syncEnabled: syncEnabled.present
          ? syncEnabled
          : Value(existing?.syncEnabled ?? false),
      lastSyncedAt: lastSyncedAt.present
          ? lastSyncedAt
          : Value(existing?.lastSyncedAt),
      appliancesJson: appliancesJson.present
          ? appliancesJson
          : Value(existing?.appliancesJson ?? '[]'),
    );

    await _db.into(_db.settingsTable).insertOnConflictUpdate(companion);
  }

  static UserSettings _toSettings(AppSettings row) {
    final appliancesRaw = jsonDecode(row.appliancesJson) as List<dynamic>;
    return UserSettings(
      localePref: row.localePref,
      shoppingListId: row.shoppingListId,
      shoppingListName: row.shoppingListName,
      selectedProvider: row.selectedProvider,
      modelOverrides: Map<String, String>.from(
          jsonDecode(row.modelOverridesJson) as Map),
      syncEnabled: row.syncEnabled,
      lastSyncedAt: row.lastSyncedAt,
      appliances: appliancesRaw
          .map((e) => Appliance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
