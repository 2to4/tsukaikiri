import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/ingredient_category.dart';

/// 在庫データへのアクセスを Drift に閉じ込める層。
class InventoryRepository {
  InventoryRepository(this._db);

  final AppDatabase _db;

  /// 期限が近い順（期限なしは末尾）→ 同順なら更新日時の新しい順で監視する。
  Stream<List<Ingredient>> watchInventory({IngredientCategory? filter}) {
    final query = _db.select(_db.ingredients)
      ..orderBy([
        // expiryDate が NULL のものを後ろへ（false=0 が先）
        (t) => OrderingTerm(expression: t.expiryDate.isNull()),
        (t) => OrderingTerm(expression: t.expiryDate),
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    if (filter != null) {
      query.where((t) => t.category.equalsValue(filter));
    }
    return query.watch();
  }

  Future<void> save(Ingredient ingredient) =>
      _db.into(_db.ingredients).insertOnConflictUpdate(ingredient);

  Future<void> deleteById(String id) =>
      (_db.delete(_db.ingredients)..where((t) => t.id.equals(id))).go();

  /// 在庫からの減算。0 未満にはせず、0 になっても行は残す（自動削除しない）。
  Future<void> decrement(String id, {double by = 1}) => _adjust(id, -by);

  /// 在庫の加算。
  Future<void> increment(String id, {double by = 1}) => _adjust(id, by);

  Future<void> _adjust(String id, double delta) async {
    final row = await (_db.select(_db.ingredients)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return;
    final next = (row.quantity + delta).clamp(0, double.infinity).toDouble();
    await save(row.copyWith(quantity: next, updatedAt: DateTime.now()));
  }

  // ---- normalizedName バックフィル ----

  /// 名寄せキー未付与（normalizedName が name の流用のまま）の食材を返す。
  Future<List<Ingredient>> findUnnormalized() =>
      (_db.select(_db.ingredients)
            ..where((t) => t.normalizedName.equalsExp(t.name)))
          .get();

  /// 名前 → 正規化キーのマップを未付与の行にだけ適用し、更新件数を返す。
  /// updatedAt は変更しない（ユーザー編集ではないため。並び順・同期判定に影響させない）。
  Future<int> applyNormalizedNames(Map<String, String> keysByName) async {
    var updated = 0;
    for (final entry in keysByName.entries) {
      updated += await (_db.update(_db.ingredients)
            ..where((t) =>
                t.name.equals(entry.key) & t.normalizedName.equalsExp(t.name)))
          .write(IngredientsCompanion(normalizedName: Value(entry.value)));
    }
    return updated;
  }
}
