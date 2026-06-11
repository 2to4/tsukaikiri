import 'package:flutter/services.dart';

import 'sync_service.dart';

/// iCloud ubiquity コンテナへのバックアップ / 復元実装。
///
/// Platform channel `com.futo4.tsukaikiri/icloud_sync` 経由で
/// macOS / iOS ネイティブ側の [ICloudSyncPlugin] を呼ぶ。
class ICloudSyncService implements SyncService {
  const ICloudSyncService();

  static const _channel =
      MethodChannel('com.futo4.tsukaikiri/icloud_sync');

  @override
  Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> writeBackup(String payload) async {
    try {
      await _channel.invokeMethod<void>('writeBackup', {'payload': payload});
    } on PlatformException catch (e) {
      if (e.code == 'not_signed_in') {
        throw const SyncNotSignedInException();
      }
      throw SyncIOException(e.message ?? e.code);
    }
  }

  @override
  Future<String?> readBackup() async {
    try {
      final result = await _channel.invokeMethod<String?>('readBackup');
      return result;
    } on PlatformException catch (e) {
      if (e.code == 'not_signed_in') {
        throw const SyncNotSignedInException();
      }
      throw SyncIOException(e.message ?? e.code);
    }
  }
}
