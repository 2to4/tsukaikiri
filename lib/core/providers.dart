import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/inventory/data/inventory_repository.dart';
import '../features/recipe/service/apple_foundation_models_provider.dart';
import '../features/recipe/service/on_device_ai_service.dart';
import '../features/recipe/service/recipe_provider.dart';
import '../features/recipe/service/recipe_provider_factory.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/domain/user_settings.dart';
import '../features/shopping/service/reminders_shopping_list_service.dart';
import '../features/shopping/service/shopping_list_service.dart';
import '../features/sync/presentation/sync_controller.dart';
import '../features/sync/service/icloud_sync_service.dart';
import '../features/sync/service/sync_service.dart';
import 'db/app_database.dart';
import 'secure_storage/secure_storage_service.dart';
import 'shelf_life/shelf_life_table.dart';

/// アプリ全体で 1 つの DB インスタンスを共有する。
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final inventoryRepositoryProvider = Provider<InventoryRepository>(
  (ref) => InventoryRepository(ref.watch(databaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

/// アプリ設定を Stream で監視する。
final userSettingsProvider = StreamProvider<UserSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// API キー管理サービス。
final secureStorageProvider = Provider<SecureStorageService>(
  (_) => const SecureStorageService(),
);

/// 日持ち目安テーブル（食材名 → 冷蔵保存の目安日数）。
///
/// 既定は空テーブル。起動時に [ShelfLifeTable.load] したものを
/// [main] の ProviderScope overrides で注入する（読み込み失敗時は空のまま）。
final shelfLifeTableProvider = Provider<ShelfLifeTable>(
  (_) => ShelfLifeTable.empty(),
);

/// 買い物リストサービス（macOS / iOS は EventKit リマインダー）。
/// Android 版（Google Tasks）はプラットフォームに応じて差し替える。
final shoppingListServiceProvider = Provider<ShoppingListService>(
  (_) => RemindersShoppingListService(),
);

/// データ同期サービス（iCloud ubiquity コンテナ実装）。
final syncServiceProvider = Provider<SyncService>(
  (_) => const ICloudSyncService(),
);

/// バックアップ / 復元操作のコントローラ（Riverpod v3 Notifier）。
final syncControllerProvider = NotifierProvider<SyncController, SyncState>(
  SyncController.new,
);

/// 自動バックアップ用デバウンスタイマー（アプリ生存期間と同期）。
final backupSchedulerProvider = Provider<BackupScheduler>((ref) {
  final scheduler = BackupScheduler();
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

/// 自動バックアップ購読（在庫・設定の変化を検知してデバウンスバックアップ）。
///
/// アプリ起動時に ref.watch させて常駐させる。
/// syncEnabled が false の場合はバックアップをスキップする。
///
/// **ループ防止**: バックアップ自身が lastSyncedAt を更新して設定ストリームを
/// 発火させるため、設定側はバックアップ対象フィールドの指紋（lastSyncedAt を
/// 除く）が前回から変わったときだけスケジュールする。そうしないと
/// バックアップ → lastSyncedAt 更新 → 発火 → 再バックアップ…が永遠に続く。
final autoBackupWatcherProvider = Provider<void>((ref) {
  final scheduler = ref.watch(backupSchedulerProvider);
  final syncCtrl = ref.read(syncControllerProvider.notifier);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);

  // 在庫ストリーム（バックアップは在庫を変更しないのでループしない）
  final invSub = inventoryRepo.watchInventory().listen((_) async {
    final settings = await settingsRepo.get();
    if (!settings.syncEnabled) return;
    scheduler.schedule(() => syncCtrl.silentBackup());
  });

  // 設定ストリーム（lastSyncedAt 以外のフィールドの変化のみ反応）
  String fingerprint(UserSettings s) => [
        s.localePref,
        s.shoppingListId,
        s.shoppingListName,
        s.selectedProvider,
        (s.modelOverrides.entries.map((e) => '${e.key}=${e.value}').toList()
              ..sort())
            .join(','),
        s.syncEnabled,
        s.appliances.map((a) => a.toJson()).toList(),
      ].join('|');

  String? lastFingerprint;
  final settingsSub = settingsRepo.watch().listen((settings) {
    final fp = fingerprint(settings);
    final changed = lastFingerprint != null && fp != lastFingerprint;
    lastFingerprint = fp;
    if (!changed) return; // 初回発行 or lastSyncedAt だけの更新はスキップ
    if (!settings.syncEnabled) return;
    scheduler.schedule(() => syncCtrl.silentBackup());
  });

  ref.onDispose(() {
    invSub.cancel();
    settingsSub.cancel();
    scheduler.cancel();
  });
});

/// オンデバイス AI（Apple Foundation Models）のネイティブブリッジ。
/// テストでは availability / generate を差し替えられるよう Provider 化する。
final onDeviceAiServiceProvider = Provider<OnDeviceAiService>(
  (_) => const OnDeviceAiService(),
);

/// オンデバイス AI の可用性。設定 UI のグレーアウト判定・既定決定に使う。
final onDeviceAiAvailabilityProvider =
    FutureProvider<OnDeviceAiAvailability>(
  (ref) => ref.read(onDeviceAiServiceProvider).availability(),
);

/// 実際に使う RecipeProvider を解決する（2段構え・オンデバイス既定）。
///
/// 解決順:
///   1. クラウドのプロバイダが選択され、その API キーが登録済み → そのクラウド
///   2. それ以外（キー無し / `'ondevice'` 選択など）でオンデバイス AI が使える
///      端末 → [AppleFoundationModelsProvider]
///   3. どちらも使えない → null（AI 機能は無効。UI が案内）
///
/// モデルはユーザーの上書き設定があればそれを、なければ実装の既定値を使う。
final recipeProviderProvider = FutureProvider<RecipeProvider?>((ref) async {
  // 設定変更（プロバイダ選択・キー登録は別経路だが）で再解決されるよう依存を張る。
  // 値自体は一発クエリで取る（CLAUDE.md: 非 UI は repo クエリ / .future を使わない）。
  ref.watch(userSettingsProvider);
  final settings = await ref.read(settingsRepositoryProvider).get();
  final providerId = settings.selectedProvider;

  // 1. クラウドプロバイダが選択され、キーが登録済みならそれを使う。
  if (supportedProviderIds.contains(providerId)) {
    final apiKey = await ref.read(secureStorageProvider).getApiKey(providerId);
    if (apiKey != null && apiKey.isNotEmpty) {
      return createRecipeProvider(
        providerId: providerId,
        apiKey: apiKey,
        model: settings.modelOverrides[providerId],
      );
    }
  }

  // 2. キー無し / 'ondevice' 選択 / 未知 ID → オンデバイスが使えるなら使う。
  final service = ref.read(onDeviceAiServiceProvider);
  final availability = await service.availability();
  if (availability.available) {
    return AppleFoundationModelsProvider(
      service: service,
      supportsVision: availability.supportsVision,
    );
  }

  // 3. オンデバイス非対応かつキー無し → AI 無効。
  return null;
});
