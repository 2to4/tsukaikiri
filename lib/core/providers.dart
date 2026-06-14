import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/inventory/data/inventory_repository.dart';
import '../features/recipe/service/on_device_ai_service.dart';
import '../features/recipe/service/on_device_recipe_provider.dart';
import '../features/recipe/service/recipe_provider.dart';
import '../features/recipe/service/recipe_provider_factory.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/domain/user_settings.dart';
import '../features/shopping/service/google_tasks_shopping_list_service.dart';
import '../features/shopping/service/reminders_shopping_list_service.dart';
import '../features/shopping/service/shopping_list_service.dart';
import '../features/sync/presentation/sync_controller.dart';
import '../features/sync/service/google_drive_sync_service.dart';
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

/// 買い物リストサービス。
/// macOS / iOS = EventKit リマインダー、Android = Google Tasks（現状は未実装スケルトン）。
/// Android 専用端末で macOS/iOS 用チャネルを呼んで MissingPluginException にならないよう
/// プラットフォームで実装を切り替える。
final shoppingListServiceProvider = Provider<ShoppingListService>((_) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return const GoogleTasksShoppingListService();
  }
  return RemindersShoppingListService();
});

/// データ同期サービス。
/// macOS / iOS = iCloud、Android = Google Drive App Data（現状は未実装スケルトン・
/// isAvailable=false で同期 UI を無効表示に縮退）。
final syncServiceProvider = Provider<SyncService>((_) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return const GoogleDriveSyncService();
  }
  return const ICloudSyncService();
});

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

/// この端末で AI 機能（献立提案・カメラ登録）が使えるか。
///
/// `recipeProviderProvider` が解決できれば true（オンデバイス対応 or 自前キー登録済み）。
/// false のときは AI 専用画面で「この端末では AI を使えない」案内を出し、入口を無効化する。
/// 設定でキーを登録するなどで再解決される。
final aiAvailableProvider = FutureProvider<bool>((ref) async {
  final provider = await ref.watch(recipeProviderProvider.future);
  return provider != null;
});

/// この端末で AI 画像認識（カメラ登録）が使えるか。
///
/// 解決された [RecipeProvider] が `supportsVision` を満たすときだけ true。
/// オンデバイス AI はテキスト専用（`supportsVision=false`）のため、オンデバイス
/// 既定の端末では false になる。カメラ登録の入口はこれで出し分ける
/// （`aiAvailableProvider`（非 null）だけだと vision 非対応でも入口が開き、
/// 解析時に必ず失敗するため）。
final aiVisionAvailableProvider = FutureProvider<bool>((ref) async {
  final provider = await ref.watch(recipeProviderProvider.future);
  return provider?.supportsVision ?? false;
});

/// AI 入口（献立提案）を表示・有効化してよいか。
/// 解決中は誤フラッシュ防止で true、エラーは案内を出すため false にする
/// （この方針を4ビューに散らさず一箇所に集約する）。
final aiEntryEnabledProvider = Provider<bool>((ref) =>
    ref.watch(aiAvailableProvider).maybeWhen(
        data: (v) => v, loading: () => true, orElse: () => false));

/// カメラ登録の入口（画像認識）を表示・有効化してよいか。
/// オンデバイス AI は vision 非対応のため [aiVisionAvailableProvider] で判定する。
final cameraEntryEnabledProvider = Provider<bool>((ref) =>
    ref.watch(aiVisionAvailableProvider).maybeWhen(
        data: (v) => v, loading: () => true, orElse: () => false));

/// AI 機能の利用可否の種別（UI の案内文言を出し分けるため）。
enum AiStatus {
  /// 使える（クラウド or オンデバイス）。
  available,

  /// クラウドプロバイダが選択されているが API キーが未登録/無効。
  /// オンデバイスへ無言フォールバックせず、キー登録 or オンデバイス切替を促す。
  cloudKeyMissing,

  /// オンデバイス非対応かつクラウドキーも無い → AI 不可。
  unavailable,
}

/// AI の解決結果（実際に使う [RecipeProvider] と、その可否種別）。
///
/// 解決順:
///   1. クラウドのプロバイダが選択されている
///      - キー登録済み → そのクラウド（[AiStatus.available]）
///      - キー無し/無効 → null（[AiStatus.cloudKeyMissing]）。
///        **オンデバイスへ無言フォールバックしない**（ユーザーが選んだプロバイダと
///        実際に動くエンジンが食い違う混乱を避け、設定変更を促すため）。
///   2. `'ondevice'` 選択 / 未知 ID → オンデバイスが使えるなら使う（[AiStatus.available]）
///   3. どちらも使えない → null（[AiStatus.unavailable]）
///
/// モデルはユーザーの上書き設定があればそれを、なければ実装の既定値を使う。
final aiResolutionProvider =
    FutureProvider<({RecipeProvider? provider, AiStatus status})>((ref) async {
  // 設定変更で再解決されるよう依存を張る。
  // 値自体は一発クエリで取る（CLAUDE.md: 非 UI は repo クエリ / .future を使わない）。
  ref.watch(userSettingsProvider);
  final settings = await ref.read(settingsRepositoryProvider).get();
  final providerId = settings.selectedProvider;

  // 1. クラウドプロバイダが選択されている。
  if (supportedProviderIds.contains(providerId)) {
    final apiKey = await ref.read(secureStorageProvider).getApiKey(providerId);
    if (apiKey != null && apiKey.isNotEmpty) {
      return (
        provider: createRecipeProvider(
          providerId: providerId,
          apiKey: apiKey,
          model: settings.modelOverrides[providerId],
        ),
        status: AiStatus.available,
      );
    }
    // キー未登録/無効 → オンデバイスへ落とさず、案内のみ。
    return (provider: null, status: AiStatus.cloudKeyMissing);
  }

  // 2. 'ondevice' 選択 / 未知 ID → オンデバイスが使えるなら使う。
  //    可否はキャッシュ済みの onDeviceAiAvailabilityProvider を共有し、
  //    設定 UI・起動時判定と二重プローブにならないようにする。
  final service = ref.read(onDeviceAiServiceProvider);
  final availability = await ref.watch(onDeviceAiAvailabilityProvider.future);
  if (availability.available) {
    return (
      provider: OnDeviceRecipeProvider(
        service: service,
        supportsVision: availability.supportsVision,
      ),
      status: AiStatus.available,
    );
  }

  // 3. オンデバイス非対応かつキー無し → AI 無効。
  return (provider: null, status: AiStatus.unavailable);
});

/// 実際に使う [RecipeProvider]（解決できなければ null）。
final recipeProviderProvider = FutureProvider<RecipeProvider?>((ref) async {
  return (await ref.watch(aiResolutionProvider.future)).provider;
});

/// AI 利用可否の種別（案内文言の出し分け用）。
final aiStatusProvider = FutureProvider<AiStatus>((ref) async {
  return (await ref.watch(aiResolutionProvider.future)).status;
});
