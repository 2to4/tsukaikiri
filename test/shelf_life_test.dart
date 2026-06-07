import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/shelf_life/shelf_life.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';

void main() {
  group('defaultExpiryFrom', () {
    final from = DateTime(2026, 6, 7, 15, 30); // 時刻は無視される想定

    test('カテゴリ目安日数を登録日に加算する', () {
      // meat = 3 日
      expect(
        defaultExpiryFrom(IngredientCategory.meat, from),
        DateTime(2026, 6, 10),
      );
      // egg = 14 日
      expect(
        defaultExpiryFrom(IngredientCategory.egg, from),
        DateTime(2026, 6, 21),
      );
    });

    test('目安のないカテゴリ(other)は null', () {
      expect(defaultExpiryFrom(IngredientCategory.other, from), isNull);
    });

    test('全カテゴリに other 以外は目安がある', () {
      for (final c in IngredientCategory.values) {
        if (c == IngredientCategory.other) continue;
        expect(categoryShelfLifeDays[c], isNotNull, reason: c.name);
      }
    });
  });
}
