import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../domain/ingredient_category.dart';

/// カテゴリフィルタ（null = すべて）。
class CategoryFilter extends Notifier<IngredientCategory?> {
  @override
  IngredientCategory? build() => null;

  void set(IngredientCategory? category) => state = category;
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilter, IngredientCategory?>(CategoryFilter.new);

/// 期限近い順にソート済みの在庫一覧。フィルタ変更に追従する。
final inventoryListProvider = StreamProvider<List<Ingredient>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  final filter = ref.watch(categoryFilterProvider);
  return repo.watchInventory(filter: filter);
});

/// master-detail（広い画面）で選択中の食材 id。
class SelectedIngredientId extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

final selectedIngredientIdProvider =
    NotifierProvider<SelectedIngredientId, String?>(SelectedIngredientId.new);

/// デスクトップ在庫ビュー用の検索クエリ。
/// ツールバーの MacSearch と InventoryDesktopView が共有する。
class DesktopSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String q) => state = q;
  void clear() => state = '';
}

final desktopSearchQueryProvider =
    NotifierProvider<DesktopSearchQuery, String>(DesktopSearchQuery.new);

/// デスクトップ在庫ビュー用のカテゴリフィルタ。
/// 左レールの FilterRow と InventoryDesktopView が共有する。
class DesktopCategoryFilter extends Notifier<IngredientCategory?> {
  @override
  IngredientCategory? build() => null;

  void set(IngredientCategory? cat) => state = cat;
}

final desktopCategoryFilterProvider =
    NotifierProvider<DesktopCategoryFilter, IngredientCategory?>(
        DesktopCategoryFilter.new);
