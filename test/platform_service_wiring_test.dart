import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/shopping/service/google_tasks_shopping_list_service.dart';
import 'package:tsukaikiri/features/shopping/service/reminders_shopping_list_service.dart';
import 'package:tsukaikiri/features/sync/service/google_drive_sync_service.dart';
import 'package:tsukaikiri/features/sync/service/icloud_sync_service.dart';
import 'package:tsukaikiri/features/sync/service/sync_service.dart';

/// プラットフォームに応じた買い物リスト/同期サービスの差し替えを検証する。
/// Android では macOS/iOS 専用チャネルを呼ばない（MissingPluginException 回避）。
void main() {
  ProviderContainer makeContainer() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  group('Android', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('shopping = GoogleTasks / sync = GoogleDrive スケルトン', () {
      final c = makeContainer();
      expect(c.read(shoppingListServiceProvider),
          isA<GoogleTasksShoppingListService>());
      expect(c.read(syncServiceProvider), isA<GoogleDriveSyncService>());
    });

    test('GoogleDriveSyncService.isAvailable() は false（同期 UI を無効に縮退）',
        () async {
      expect(await const GoogleDriveSyncService().isAvailable(), isFalse);
    });

    test('GoogleDriveSyncService の書き込みは SyncIOException', () {
      expectLater(const GoogleDriveSyncService().writeBackup('x'),
          throwsA(isA<SyncIOException>()));
    });

    test('GoogleTasks getLists は UnimplementedError（コントローラ側で catch される）',
        () {
      expectLater(const GoogleTasksShoppingListService().getLists(),
          throwsA(isA<UnimplementedError>()));
    });
  });

  group('macOS（既定実装を維持）', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.macOS);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('shopping = Reminders / sync = iCloud', () {
      final c = makeContainer();
      expect(c.read(shoppingListServiceProvider),
          isA<RemindersShoppingListService>());
      expect(c.read(syncServiceProvider), isA<ICloudSyncService>());
    });
  });
}
