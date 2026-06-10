import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/inventory/data/inventory_repository.dart';
import '../features/recipe/service/recipe_provider.dart';
import '../features/recipe/service/recipe_provider_factory.dart';
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

/// 選択中プロバイダの RecipeProvider を解決する。
/// API キー未登録なら null（UI はキー登録を促す）。
/// モデルはユーザーの上書き設定があればそれを、なければ実装の既定値を使う。
final recipeProviderProvider = FutureProvider<RecipeProvider?>((ref) async {
  final settings = await ref.watch(userSettingsProvider.future);
  final providerId = settings.selectedProvider;
  final apiKey =
      await ref.watch(secureStorageProvider).getApiKey(providerId);
  if (apiKey == null || apiKey.isEmpty) return null;
  return createRecipeProvider(
    providerId: providerId,
    apiKey: apiKey,
    model: settings.modelOverrides[providerId],
  );
});
