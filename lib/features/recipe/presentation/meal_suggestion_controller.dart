import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../domain/recipe_constraints.dart';
import '../domain/suggested_recipe.dart';
import '../service/recipe_provider.dart';

// ──────────────────────────────────────────────────────────────
// 献立提案の状態（5状態）
// ──────────────────────────────────────────────────────────────

/// 献立提案 UI の取り得る状態。
/// 提案前 / 生成中 / 提案結果 / 在庫わずか（新規食材を含む案あり）/ エラー。
enum MealSuggestionStatus { before, generating, results, lowStock, error }

/// 在庫わずかと判定する在庫件数の上限（これ以下なら新規食材を含む提案を許可）。
const int kLowStockThreshold = 3;

/// 献立提案画面の状態スナップショット。
class MealSuggestionState {
  const MealSuggestionState({
    this.status = MealSuggestionStatus.before,
    this.recipes = const [],
    this.kind = MealKind.auto,
    this.error,
  });

  final MealSuggestionStatus status;

  /// 提案結果（results / lowStock のときのみ非空）。
  final List<SuggestedRecipe> recipes;

  /// 選択中の条件チップ。提案前でも保持する（提案実行時に反映）。
  final MealKind kind;

  /// エラー種別（error のときのみ）。
  final MealSuggestionError? error;

  MealSuggestionState copyWith({
    MealSuggestionStatus? status,
    List<SuggestedRecipe>? recipes,
    MealKind? kind,
    MealSuggestionError? error,
  }) =>
      MealSuggestionState(
        status: status ?? this.status,
        recipes: recipes ?? this.recipes,
        kind: kind ?? this.kind,
        error: error,
      );
}

/// エラーの種別。UI 側で文言を出し分ける。
enum MealSuggestionError {
  /// API キー未登録（設定への導線を出す）。
  noApiKey,

  /// 通信失敗・レスポンス異常（オフライン文言＋再試行）。
  network,
}

// ──────────────────────────────────────────────────────────────
// コントローラ
// ──────────────────────────────────────────────────────────────

/// 献立提案フローを管理する Notifier。
///
/// フロー:
/// 1. 在庫を inventory repository（[inventoryListProvider]）から取得
/// 2. 設定から appliances・outputLocale・selectedProvider を解決
/// 3. [recipeProviderProvider] の RecipeProvider で suggestRecipes を実行
///
/// 在庫件数が [kLowStockThreshold] 以下のときは新規食材を含む提案を許可し、
/// 状態を lowStock にしてバナーを出す。
class MealSuggestionController extends Notifier<MealSuggestionState> {
  @override
  MealSuggestionState build() => const MealSuggestionState();

  /// 条件チップを変更する（提案結果はそのまま保持）。
  void setKind(MealKind kind) => state = state.copyWith(kind: kind);

  /// 在庫から献立を提案する。
  Future<void> suggest() async {
    state = state.copyWith(status: MealSuggestionStatus.generating);

    // RecipeProvider 解決（API キー未登録なら null）。
    final RecipeProvider? provider;
    try {
      provider = await ref.read(recipeProviderProvider.future);
    } catch (_) {
      state = state.copyWith(
        status: MealSuggestionStatus.error,
        error: MealSuggestionError.network,
      );
      return;
    }
    if (provider == null) {
      state = state.copyWith(
        status: MealSuggestionStatus.error,
        error: MealSuggestionError.noApiKey,
      );
      return;
    }

    // 在庫と設定を取得。
    // 注意: StreamProvider の .future はリスナーがいないと解決せず、drift stream の
    // .first も FakeAsync（widget テスト）下では進まないため、リポジトリの
    // 一発クエリ（getInventory / get）で読む。
    final List<Ingredient> inventory;
    final List<dynamic> appliances;
    final String outputLocale;
    try {
      inventory = await ref.read(inventoryRepositoryProvider).getInventory();
      final settings = await ref.read(settingsRepositoryProvider).get();
      appliances = settings.appliances;
      // 出力言語: 'system' のときは日本語にフォールバック（プロンプトは ja/en のみ対応）。
      outputLocale = settings.localePref == 'en' ? 'en' : 'ja';
    } catch (_) {
      state = state.copyWith(
        status: MealSuggestionStatus.error,
        error: MealSuggestionError.network,
      );
      return;
    }

    final lowStock = inventory.length <= kLowStockThreshold;

    final constraints = RecipeConstraints(
      appliances: appliances.cast(),
      outputLocale: outputLocale,
      mealKind: state.kind,
      allowNewIngredients: lowStock,
    );

    try {
      final recipes = await provider.suggestRecipes(inventory, constraints);
      state = state.copyWith(
        status: lowStock
            ? MealSuggestionStatus.lowStock
            : MealSuggestionStatus.results,
        recipes: recipes,
      );
    } on RecipeProviderException {
      state = state.copyWith(
        status: MealSuggestionStatus.error,
        error: MealSuggestionError.network,
      );
    } catch (_) {
      state = state.copyWith(
        status: MealSuggestionStatus.error,
        error: MealSuggestionError.network,
      );
    }
  }
}

final mealSuggestionControllerProvider =
    NotifierProvider<MealSuggestionController, MealSuggestionState>(
  MealSuggestionController.new,
);

// ──────────────────────────────────────────────────────────────
// M5 への引き渡し口
// ──────────────────────────────────────────────────────────────

/// 「献立に決める」で決定された献立（複数可）。
/// title を同一性キーとしてトグルする（提案は一時オブジェクトで id を持たないため）。
class DecidedMealsNotifier extends Notifier<List<SuggestedRecipe>> {
  @override
  List<SuggestedRecipe> build() => const [];

  /// 決定済みなら解除、未決定なら追加する。
  void toggle(SuggestedRecipe recipe) {
    if (isDecided(recipe)) {
      state = state.where((m) => m.title != recipe.title).toList();
    } else {
      state = [...state, recipe];
    }
  }

  bool isDecided(SuggestedRecipe recipe) =>
      state.any((m) => m.title == recipe.title);

  void clear() => state = const [];
}

/// 決定済み献立のリスト（M5 の買い物リストが参照する）。
final decidedMealsProvider =
    NotifierProvider<DecidedMealsNotifier, List<SuggestedRecipe>>(
  DecidedMealsNotifier.new,
);

/// 「買い物リストへ」で M5 に渡す対象献立。
/// 決定済み献立があればそれを、なければ単発で渡された献立を保持する。
/// M5（買い物リスト 2ペイン）はこの Provider を入力に MissingIngredientsService を回す。
final mealsForShoppingProvider =
    NotifierProvider<MealsForShoppingNotifier, List<SuggestedRecipe>>(
  MealsForShoppingNotifier.new,
);

class MealsForShoppingNotifier extends Notifier<List<SuggestedRecipe>> {
  @override
  List<SuggestedRecipe> build() => const [];

  void set(List<SuggestedRecipe> recipes) => state = recipes;
  void clear() => state = const [];
}
