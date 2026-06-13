import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/recipe/presentation/meal_suggestion_controller.dart';
import 'package:tsukaikiri/features/recipe/service/recipe_provider.dart';

import 'fakes/fake_recipe_provider.dart';

/// suggest() のエラー分類を検証する。
/// オンデバイス AI の失敗をネットワークエラー（「Wi-Fi に接続」）と
/// 誤表示しないこと（コードレビュー指摘 #2）を回帰テストで守る。
void main() {
  Future<MealSuggestionError?> errorFor(RecipeProviderException ex) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      recipeProviderProvider
          .overrideWith((ref) async => FakeRecipeProvider(suggestError: ex)),
    ]);
    addTearDown(container.dispose);

    final controller =
        container.read(mealSuggestionControllerProvider.notifier);
    await controller.suggest();
    return container.read(mealSuggestionControllerProvider).error;
  }

  test('オンデバイス由来の失敗 → onDeviceFailed（network 誤分類しない）', () async {
    final e = await errorFor(const RecipeProviderException('ondevice', 0, 'x'));
    expect(e, MealSuggestionError.onDeviceFailed);
  });

  test('クラウド由来の失敗 → network', () async {
    final e = await errorFor(const RecipeProviderException('gemini', 0, 'x'));
    expect(e, MealSuggestionError.network);
  });
}
