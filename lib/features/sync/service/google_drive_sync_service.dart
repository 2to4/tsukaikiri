import 'sync_service.dart';

/// Android 向けクラウド同期（Google Drive App Data）のスケルトン。
///
/// 本実装には google_sign_in での `drive.appdata` スコープ取得と Drive REST API
/// （App Data フォルダ内の単一 JSON 読み書き）が必要。外部準備（OAuth クライアント
/// 設定）待ちのため、現時点では [isAvailable] が false を返して同期 UI を無効表示に
/// 縮退させる（iCloud 専用実装を Android で呼んで `MissingPluginException` で落ちるのを
/// 防ぐ）。
class GoogleDriveSyncService implements SyncService {
  const GoogleDriveSyncService();

  // TODO(Android): google_sign_in（scope:
  //   https://www.googleapis.com/auth/drive.appdata）でトークンを取得し、Drive REST
  //   API の appDataFolder に backup JSON を単一ファイルで読み書きする
  //   （iCloud 実装と同じく last-write-wins・API キーは含めない）。

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<void> writeBackup(String payload) async =>
      throw const SyncIOException('Google Drive 同期は未実装です（Android）');

  @override
  Future<String?> readBackup() async =>
      throw const SyncIOException('Google Drive 同期は未実装です（Android）');
}
