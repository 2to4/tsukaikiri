import '../domain/shopping_list.dart';

/// 買い物リスト連携の共通インターフェース。
/// macOS/iOS = EventKit（リマインダー）、Android = Google Tasks で実装を差し替える。
abstract class ShoppingListService {
  /// 利用可能なリスト一覧を返す。
  Future<List<ShoppingList>> getLists();

  /// 指定名のリストを新規作成して返す。
  Future<ShoppingList> createList(String name);

  /// 指定リストへアイテムを追加する。重複（タイトル完全一致）はスキップ。
  /// 戻り値は実際に追加した件数。
  Future<int> addItems(String listId, List<ShoppingListItem> items);
}
