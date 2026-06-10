import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/features/inventory/data/inventory_repository.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/inventory/service/normalized_name_backfill_service.dart';

import 'fakes/fake_recipe_provider.dart';

void main() {
  late AppDatabase db;
  late InventoryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = InventoryRepository(db);
  });

  tearDown(() async => db.close());

  Future<void> seed(String id, String name, {String? normalizedName}) =>
      repo.save(Ingredient(
        id: id,
        name: name,
        normalizedName: normalizedName ?? name,
        category: IngredientCategory.meat,
        quantity: 1,
        unit: 'piece',
        expiryDate: null,
        updatedAt: DateTime(2026, 6, 10),
      ));

  Future<Map<String, String>> normalizedByName() async {
    final all = await repo.watchInventory().first;
    return {for (final i in all) i.id: i.normalizedName};
  }

  test('未付与の行にだけキーを付与し件数を返す', () async {
    await seed('1', '鶏むね');
    await seed('2', '鶏胸肉');
    await seed('3', '卵', normalizedName: 'egg'); // 付与済み

    final provider = FakeRecipeProvider(normalizedKeys: const {
      '鶏むね': 'chicken_breast',
      '鶏胸肉': 'chicken_breast',
      '卵': 'SHOULD_NOT_BE_USED',
    });
    final updated =
        await NormalizedNameBackfillService(repo, provider).run();

    expect(updated, 2);
    expect(provider.normalizeCalls.single, ['鶏むね', '鶏胸肉']);
    expect(await normalizedByName(), {
      '1': 'chicken_breast',
      '2': 'chicken_breast',
      '3': 'egg',
    });
  });

  test('同名の複数行はまとめて更新される', () async {
    await seed('1', '鶏むね');
    await seed('2', '鶏むね');

    final provider =
        FakeRecipeProvider(normalizedKeys: const {'鶏むね': 'chicken_breast'});
    final updated =
        await NormalizedNameBackfillService(repo, provider).run();

    expect(updated, 2);
    expect((await normalizedByName()).values.toSet(), {'chicken_breast'});
  });

  test('冪等: 2回目は対象がなく AI を呼ばない', () async {
    await seed('1', '鶏むね');
    final provider =
        FakeRecipeProvider(normalizedKeys: const {'鶏むね': 'chicken_breast'});
    final service = NormalizedNameBackfillService(repo, provider);

    expect(await service.run(), 1);
    expect(await service.run(), 0);
    expect(provider.normalizeCalls, hasLength(1));
  });

  test('対象ゼロなら AI を呼ばず 0 を返す', () async {
    final provider = FakeRecipeProvider();
    expect(await NormalizedNameBackfillService(repo, provider).run(), 0);
    expect(provider.normalizeCalls, isEmpty);
  });

  test('キーが名前と同じ場合は書き込まない', () async {
    await seed('1', 'egg');
    final provider = FakeRecipeProvider(normalizedKeys: const {'egg': 'egg'});
    expect(await NormalizedNameBackfillService(repo, provider).run(), 0);
  });
}
