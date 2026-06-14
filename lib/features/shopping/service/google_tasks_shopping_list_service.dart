import '../domain/shopping_list.dart';
import 'shopping_list_service.dart';

/// Android 向け買い物リスト連携（Google Tasks）のスケルトン。
///
/// 本実装には google_sign_in での `auth/tasks` スコープ取得と Google Tasks
/// REST API 呼び出しが必要（Google Cloud の OAuth クライアント設定・Android の
/// SHA-1 登録が前提）。これらは外部準備（ユーザー対応）待ちのため、現時点では
/// 未対応として明示的に失敗させる。
///
/// 目的は、macOS/iOS 専用の [reminders] 実装を Android で呼んで
/// `MissingPluginException` で落ちるのを防ぎ、買い物フローを「エラー表示」で
/// 穏やかに縮退させること（呼び出し元コントローラは例外を catch して
/// エラー状態に遷移する）。
class GoogleTasksShoppingListService implements ShoppingListService {
  const GoogleTasksShoppingListService();

  // TODO(Android): google_sign_in（scope: https://www.googleapis.com/auth/tasks）
  //   でアクセストークンを取得し、Tasks REST API（tasklists / tasks）で実装する。
  //   識別子は tasklist id を保存する（CLAUDE.md の ShoppingListService 規約）。
  Never _unimplemented() => throw UnimplementedError(
        'Google Tasks 連携は未実装です（Android 対応フェーズで実装予定）',
      );

  @override
  Future<List<ShoppingList>> getLists() async => _unimplemented();

  @override
  Future<ShoppingList> createList(String name) async => _unimplemented();

  @override
  Future<int> addItems(String listId, List<ShoppingListItem> items) async =>
      _unimplemented();
}
