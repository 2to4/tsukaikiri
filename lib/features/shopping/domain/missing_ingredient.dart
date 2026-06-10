import 'shopping_list.dart';

/// 献立に必要だが在庫にない材料（買い物リスト候補）。
class MissingIngredient {
  const MissingIngredient({required this.name, required this.sources});

  /// 表示名（最初に出現した献立での表記）。
  final String name;

  /// 由来献立と分量。複数の献立が同じ材料を要求した場合は複数になる。
  final List<MissingIngredientSource> sources;

  /// 買い物リストへ渡すアイテムに変換する。
  /// タイトルは材料名のみ（リマインダー側の重複チェックがタイトル完全一致のため）、
  /// 分量と由来献立は notes に載せる。
  ShoppingListItem toShoppingListItem() => ShoppingListItem(
        title: name,
        notes: sources.map((s) => '${s.recipeTitle}: ${s.amount}').join(' / '),
      );
}

class MissingIngredientSource {
  const MissingIngredientSource({
    required this.recipeTitle,
    required this.amount,
  });

  final String recipeTitle;

  /// 分量（AI が生成した自然文。例: '2個'）。
  final String amount;
}
