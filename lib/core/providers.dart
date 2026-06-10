import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/inventory/data/inventory_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/domain/user_settings.dart';
import '../features/shopping/service/reminders_shopping_list_service.dart';
import '../features/shopping/service/shopping_list_service.dart';
import 'db/app_database.dart';
import 'secure_storage/secure_storage_service.dart';

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

/// 買い物リストサービス（macOS / iOS は EventKit リマインダー）。
/// Android 版（Google Tasks）はプラットフォームに応じて差し替える。
final shoppingListServiceProvider = Provider<ShoppingListService>(
  (_) => RemindersShoppingListService(),
);
