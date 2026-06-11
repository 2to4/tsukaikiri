import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../features/inventory/domain/ingredient_category.dart';

/// 1 件の日持ちルール（generate.dart が出力する JSON の 1 要素）。
class ShelfLifeRule {
  const ShelfLifeRule({
    required this.normalizedKey,
    required this.aliases,
    required this.category,
    required this.days,
    required this.source,
  });

  /// 言語非依存キー（例 "chicken_breast"）。
  final String normalizedKey;

  /// 日本語エイリアス（表示名・別名）。完全一致/部分一致の照合に使う。
  final List<String> aliases;

  /// アプリの [IngredientCategory]（不明なら null）。
  final IngredientCategory? category;

  /// 冷蔵保存の目安日数。
  final int days;

  /// 出典（"foodkeeper" | "supplement"）。
  final String source;

  static ShelfLifeRule fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String?;
    final category = IngredientCategory.values
        .where((c) => c.name == categoryName)
        .cast<IngredientCategory?>()
        .firstOrNull;
    return ShelfLifeRule(
      normalizedKey: json['normalizedKey'] as String,
      aliases: (json['aliases'] as List).cast<String>(),
      category: category,
      days: (json['days'] as num).toInt(),
      source: json['source'] as String? ?? 'foodkeeper',
    );
  }
}

/// 同梱 JSON（assets/shelf_life/shelf_life_rules.json）を読み込み、
/// 食材名から日持ち目安日数を引く同期テーブル。
///
/// 照合順（[daysFor]）:
///   1. エイリアス完全一致
///   2. 部分一致（最長エイリアス優先）
///   3. normalizedKey 一致
///   4. null
class ShelfLifeTable {
  ShelfLifeTable._(this._rules, this._aliasIndex, this._keyIndex);

  final List<ShelfLifeRule> _rules;

  /// 正規化済みエイリアス → ルール（完全一致用）。
  final Map<String, ShelfLifeRule> _aliasIndex;

  /// normalizedKey（小文字）→ ルール。
  final Map<String, ShelfLifeRule> _keyIndex;

  /// 空テーブル（アセット未ロード・読み込み失敗時のフォールバック）。
  factory ShelfLifeTable.empty() => ShelfLifeTable._(const [], const {}, const {});

  /// ルール一覧（テスト・デバッグ用）。
  List<ShelfLifeRule> get rules => List.unmodifiable(_rules);

  static const String assetPath = 'assets/shelf_life/shelf_life_rules.json';

  /// アセットから読み込む。失敗時は呼び出し側で [empty] にフォールバックする。
  static Future<ShelfLifeTable> load() async {
    final raw = await rootBundle.loadString(assetPath);
    return parse(raw);
  }

  /// JSON 文字列から構築する（テストから直接呼べるよう公開）。
  static ShelfLifeTable parse(String jsonStr) {
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    final rules = (decoded['rules'] as List)
        .map((e) => ShelfLifeRule.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    final aliasIndex = <String, ShelfLifeRule>{};
    final keyIndex = <String, ShelfLifeRule>{};
    for (final rule in rules) {
      keyIndex.putIfAbsent(rule.normalizedKey.toLowerCase(), () => rule);
      for (final alias in rule.aliases) {
        aliasIndex.putIfAbsent(_normalize(alias), () => rule);
      }
    }
    return ShelfLifeTable._(rules, aliasIndex, keyIndex);
  }

  /// [name]（と任意の [category]）から日持ち目安日数を引く。
  /// ヒットしなければ null。
  int? daysFor(String name, {IngredientCategory? category}) {
    final query = _normalize(name);
    if (query.isEmpty) return null;

    // 1. 完全一致。
    final exact = _aliasIndex[query];
    if (exact != null) return exact.days;

    // 2. 部分一致（最長エイリアス優先 = より具体的なものを優先）。
    ShelfLifeRule? best;
    var bestLen = 0;
    for (final rule in _rules) {
      for (final alias in rule.aliases) {
        final a = _normalize(alias);
        if (a.isEmpty) continue;
        // クエリがエイリアスを含む、またはエイリアスがクエリを含む。
        if (query.contains(a) || a.contains(query)) {
          if (a.length > bestLen) {
            best = rule;
            bestLen = a.length;
          }
        }
      }
    }
    if (best != null) return best.days;

    // 3. normalizedKey 一致（英語キーで直接来た場合）。
    final byKey = _keyIndex[query];
    if (byKey != null) return byKey.days;

    return null;
  }

  /// 空白除去・小文字化した照合用キー。
  static String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
}
