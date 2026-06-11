/// iCloud ubiquity コンテナへのバックアップ / 復元を担う抽象インターフェース。
abstract class SyncService {
  /// iCloud が利用可能かどうかを返す。
  Future<bool> isAvailable();

  /// バックアップ JSON を iCloud コンテナに書き込む。
  Future<void> writeBackup(String payload);

  /// iCloud コンテナからバックアップ JSON を読み込む。
  /// ファイルが存在しない場合は null を返す。
  Future<String?> readBackup();
}

// ──────────────────────────────────────────────────────────────
// 独自例外
// ──────────────────────────────────────────────────────────────

/// iCloud にサインインしていない場合にスローされる例外。
class SyncNotSignedInException implements Exception {
  const SyncNotSignedInException();

  @override
  String toString() => 'SyncNotSignedInException';
}

/// iCloud の読み書きで IO エラーが発生した場合にスローされる例外。
class SyncIOException implements Exception {
  const SyncIOException(this.message);
  final String message;

  @override
  String toString() => 'SyncIOException($message)';
}
