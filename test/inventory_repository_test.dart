import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/features/inventory/data/inventory_repository.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';

void main() {
  late AppDatabase db;
  late InventoryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = InventoryRepository(db);
  });

  tearDown(() async => db.close());

  Ingredient sample({
    required String id,
    required String name,
    IngredientCategory category = IngredientCategory.vegetable,
    double quantity = 1,
    DateTime? expiry,
  }) =>
      Ingredient(
        id: id,
        name: name,
        normalizedName: name,
        category: category,
        quantity: quantity,
        unit: 'piece',
        expiryDate: expiry,
        updatedAt: DateTime(2026, 6, 7),
      );

  test('save して watchInventory で取得できる', () async {
    await repo.save(sample(id: '1', name: 'にんじん'));
    final items = await repo.watchInventory().first;
    expect(items.map((e) => e.name), ['にんじん']);
  });

  test('期限が近い順、期限なしは末尾に並ぶ', () async {
    await repo.save(sample(id: 'a', name: '遠い', expiry: DateTime(2026, 7, 1)));
    await repo.save(sample(id: 'b', name: '近い', expiry: DateTime(2026, 6, 8)));
    await repo.save(sample(id: 'c', name: '期限なし'));

    final items = await repo.watchInventory().first;
    expect(items.map((e) => e.name), ['近い', '遠い', '期限なし']);
  });

  test('カテゴリでフィルタできる', () async {
    await repo.save(sample(id: '1', name: '鶏肉', category: IngredientCategory.meat));
    await repo.save(
        sample(id: '2', name: 'キャベツ', category: IngredientCategory.vegetable));

    final meat =
        await repo.watchInventory(filter: IngredientCategory.meat).first;
    expect(meat.map((e) => e.name), ['鶏肉']);
  });

  test('decrement は数量を減らし、0 未満にはしない', () async {
    await repo.save(sample(id: '1', name: '卵', quantity: 2));
    await repo.decrement('1');
    expect((await repo.watchInventory().first).single.quantity, 1);

    await repo.decrement('1');
    await repo.decrement('1'); // 0 未満にならない
    final row = (await repo.watchInventory().first).single;
    expect(row.quantity, 0);
    // 0 になっても行は残る
    expect((await repo.watchInventory().first).length, 1);
  });

  test('deleteById で削除できる', () async {
    await repo.save(sample(id: '1', name: '牛乳'));
    await repo.deleteById('1');
    expect(await repo.watchInventory().first, isEmpty);
  });
}
