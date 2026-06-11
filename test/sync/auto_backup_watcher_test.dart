// autoBackupWatcherProvider の結合テスト（実時間・短縮デバウンス）。
//
// 特に「バックアップが lastSyncedAt を更新 → 設定 stream 発火 → 再バックアップ」
// の無限ループが起きないこと（指紋比較によるスキップ）を検証する。

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/sync/presentation/sync_controller.dart';
import 'package:tsukaikiri/features/sync/service/sync_service.dart';

class _CountingSyncService implements SyncService {
  int writeCount = 0;
  String? lastPayload;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> writeBackup(String payload) async {
    writeCount++;
    lastPayload = payload;
  }

  @override
  Future<String?> readBackup() async => lastPayload;
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late _CountingSyncService sync;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    sync = _CountingSyncService();
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      syncServiceProvider.overrideWithValue(sync),
      // テストではデバウンスを 20ms に短縮する。
      backupSchedulerProvider.overrideWith((ref) {
        final scheduler = BackupScheduler(const Duration(milliseconds: 20));
        ref.onDispose(scheduler.dispose);
        return scheduler;
      }),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// デバウンス + バックアップ処理が完了するのに十分な時間待つ。
  Future<void> settle() => Future<void>.delayed(
        const Duration(milliseconds: 300),
      );

  test('設定変更で1回だけバックアップされ、lastSyncedAt 更新でループしない', () async {
    container.read(autoBackupWatcherProvider); // 常駐開始
    final repo = container.read(settingsRepositoryProvider);

    await repo.setSyncEnabled(true);
    await settle();

    // ループしていれば 20ms ごとに増え続けるため 300ms 待てば多数になる。
    expect(sync.writeCount, 1);

    // さらに待ってもバックアップが増えない（ループなしの追い打ち確認）。
    await settle();
    expect(sync.writeCount, 1);
  });

  test('在庫変更でバックアップされる（syncEnabled ON のとき）', () async {
    container.read(autoBackupWatcherProvider);
    final settingsRepo = container.read(settingsRepositoryProvider);
    final inventoryRepo = container.read(inventoryRepositoryProvider);

    await settingsRepo.setSyncEnabled(true);
    await settle();
    expect(sync.writeCount, 1);

    await inventoryRepo.save(Ingredient(
      id: 'tofu-1',
      name: '豆腐',
      normalizedName: 'tofu',
      category: IngredientCategory.other,
      quantity: 1,
      unit: '個',
      expiryDate: null,
      updatedAt: DateTime.now(),
    ));
    await settle();

    expect(sync.writeCount, 2);
    expect(sync.lastPayload, contains('豆腐'));
  });

  test('syncEnabled OFF では在庫を変更してもバックアップされない', () async {
    container.read(autoBackupWatcherProvider);
    final inventoryRepo = container.read(inventoryRepositoryProvider);

    await inventoryRepo.save(Ingredient(
      id: 'milk-1',
      name: '牛乳',
      normalizedName: 'milk',
      category: IngredientCategory.dairy,
      quantity: 1,
      unit: '本',
      expiryDate: null,
      updatedAt: DateTime.now(),
    ));
    await settle();

    expect(sync.writeCount, 0);
  });
}
