import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/shelf_life/shelf_life.dart';
import 'package:tsukaikiri/core/shelf_life/shelf_life_table.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';

void main() {
  // 照合階層の検証用の小さなテーブル。
  const json = '''
{
  "schemaVersion": 1,
  "rules": [
    {"normalizedKey": "chicken_breast", "aliases": ["鶏むね肉", "鶏胸肉"], "category": "meat", "days": 2, "source": "foodkeeper"},
    {"normalizedKey": "tofu", "aliases": ["豆腐", "木綿豆腐"], "category": "other", "days": 4, "source": "supplement"},
    {"normalizedKey": "cabbage", "aliases": ["キャベツ"], "category": "vegetable", "days": 11, "source": "foodkeeper"}
  ]
}
''';

  group('ShelfLifeTable 照合階層', () {
    final table = ShelfLifeTable.parse(json);

    test('① エイリアス完全一致', () {
      expect(table.daysFor('豆腐'), 4);
      expect(table.daysFor('鶏むね肉'), 2);
      expect(table.daysFor('キャベツ'), 11);
    });

    test('完全一致は前後空白を無視する', () {
      expect(table.daysFor('  豆腐 '), 4);
    });

    test('② 部分一致（クエリがエイリアスを含む）', () {
      // 「木綿豆腐パック」はエイリアス「木綿豆腐」を含む。
      expect(table.daysFor('木綿豆腐パック'), 4);
    });

    test('② 部分一致（最長エイリアス優先）', () {
      // 「国産鶏むね肉」は「鶏むね肉」を含む。
      expect(table.daysFor('国産鶏むね肉'), 2);
    });

    test('③ normalizedKey 一致（英語キー直指定）', () {
      expect(table.daysFor('chicken_breast'), 2);
      expect(table.daysFor('TOFU'), 4); // 大文字小文字無視
    });

    test('④ ミスは null', () {
      expect(table.daysFor('まったく無い食材'), isNull);
      expect(table.daysFor(''), isNull);
    });
  });

  group('ShelfLifeTable.empty', () {
    test('常に null を返す', () {
      final empty = ShelfLifeTable.empty();
      expect(empty.daysFor('豆腐'), isNull);
      expect(empty.rules, isEmpty);
    });
  });

  group('expiryFromName フォールバック', () {
    final table = ShelfLifeTable.parse(json);
    final from = DateTime(2026, 6, 11);

    test('テーブルヒット時はその日数を使う', () {
      expect(expiryFromName(table, '豆腐', IngredientCategory.other, from),
          DateTime(2026, 6, 15)); // +4
    });

    test('テーブルミス時はカテゴリ目安にフォールバック', () {
      // 未知の肉 → meat=3日
      expect(expiryFromName(table, '謎の肉', IngredientCategory.meat, from),
          DateTime(2026, 6, 14));
    });

    test('テーブルミス＋カテゴリ目安なし（other）は null', () {
      expect(
          expiryFromName(table, '謎のもの', IngredientCategory.other, from), isNull);
    });

    test('カテゴリ null でテーブルミスなら null', () {
      expect(expiryFromName(table, '謎のもの', null, from), isNull);
    });

    test('カテゴリ null でもテーブルヒットすればその日数', () {
      expect(expiryFromName(table, '豆腐', null, from), DateTime(2026, 6, 15));
    });
  });

  group('実アセット読み込みスモーク', () {
    setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

    test('同梱 JSON をロードし主要食材がヒットする', () async {
      final table = await ShelfLifeTable.load();
      expect(table.rules, isNotEmpty);
      // 豆腐・鶏むね肉・もやしがヒットすること。
      expect(table.daysFor('豆腐'), isNotNull);
      expect(table.daysFor('鶏むね肉'), isNotNull);
      expect(table.daysFor('もやし'), isNotNull);
      // もやしは保守的に短い（3日）。
      expect(table.daysFor('もやし'), lessThanOrEqualTo(3));
    });
  });
}
