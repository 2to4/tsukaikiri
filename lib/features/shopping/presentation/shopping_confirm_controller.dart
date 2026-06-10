import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../recipe/domain/suggested_recipe.dart';
import '../../recipe/presentation/meal_suggestion_controller.dart';
import '../domain/missing_ingredient.dart';
import '../domain/shopping_list.dart';
import '../service/missing_ingredients_service.dart';

// ──────────────────────────────────────────────────────────────
// 買い物リスト確認画面の UI モデル（数量ステッパー付き）
// ──────────────────────────────────────────────────────────────

/// UI で扱う 1行分の不足食材エントリー。
///
/// [MissingIngredient] に UI 専用の状態（チェック・個数）を付加する。
/// 数量ステッパーは整数（個）で表現し、[ShoppingListItem.notes] に
/// 元の量文字列と由来献立を記録する設計とする。
class ShoppingItem {
  const ShoppingItem({
    required this.ingredient,
    required this.checked,
    required this.qty,
  });

  /// 元の不足食材情報（名前・由来献立リスト）。
  final MissingIngredient ingredient;

  /// チェックがONならリストへの追加対象。
  final bool checked;

  /// ステッパーで調整した個数（最小1）。
  final int qty;

  String get name => ingredient.name;

  /// 由来献立名のリスト（複数献立が同一食材を使う場合あり）。
  List<String> get sourceNames =>
      ingredient.sources.map((s) => s.recipeTitle).toList();

  ShoppingItem copyWith({bool? checked, int? qty}) => ShoppingItem(
        ingredient: ingredient,
        checked: checked ?? this.checked,
        qty: qty ?? this.qty,
      );

  /// 買い物リストへ渡すアイテムに変換する。
  /// タイトルは食材名のみ。由来献立と元の量は notes に記録する。
  ShoppingListItem toShoppingListItem() => ShoppingListItem(
        title: ingredient.name,
        notes: ingredient.sources
            .map((s) => '${s.recipeTitle}: ${s.amount}')
            .join(' / '),
      );
}

// ──────────────────────────────────────────────────────────────
// 画面状態（4 + 1状態）
// ──────────────────────────────────────────────────────────────

/// 買い物リスト確認画面の取り得るフェーズ。
enum ShoppingConfirmPhase {
  /// 対象献立なし（mealsForShopping も decidedMeals も空）。
  noTarget,

  /// 不足食材一覧を表示中（チェック・ステッパー操作可能）。
  listing,

  /// リストへの追加中。
  adding,

  /// 追加完了。
  done,

  /// エラー（addItems 失敗など）。
  error,
}

/// 画面全体のスナップショット。
class ShoppingConfirmState {
  const ShoppingConfirmState({
    this.phase = ShoppingConfirmPhase.noTarget,
    this.items = const [],
    this.availableLists = const [],
    this.selectedListId,
    this.selectedListName,
    this.listsLoading = false,
    this.listsError,
    this.addedCount = 0,
    this.errorMessage,
  });

  final ShoppingConfirmPhase phase;

  /// 不足食材の UI モデル一覧。
  final List<ShoppingItem> items;

  /// リマインダーから取得できたリスト一覧。
  final List<ShoppingList> availableLists;

  /// 右パネルで選択中のリスト ID。
  final String? selectedListId;

  /// 選択中リストの表示名。
  final String? selectedListName;

  /// リスト一覧の読み込み中。
  final bool listsLoading;

  /// リスト読み込みエラーメッセージ。
  final String? listsError;

  /// 完了時の追加件数。
  final int addedCount;

  /// エラーメッセージ（phase == error のとき）。
  final String? errorMessage;

  /// チェックが入った（追加対象の）アイテム。
  List<ShoppingItem> get checkedItems => items.where((i) => i.checked).toList();

  bool get allChecked => items.isNotEmpty && items.every((i) => i.checked);

  ShoppingConfirmState copyWith({
    ShoppingConfirmPhase? phase,
    List<ShoppingItem>? items,
    List<ShoppingList>? availableLists,
    String? selectedListId,
    String? selectedListName,
    bool? listsLoading,
    String? listsError,
    int? addedCount,
    String? errorMessage,
    bool clearListsError = false,
    bool clearSelectedList = false,
    bool clearError = false,
  }) =>
      ShoppingConfirmState(
        phase: phase ?? this.phase,
        items: items ?? this.items,
        availableLists: availableLists ?? this.availableLists,
        selectedListId:
            clearSelectedList ? null : (selectedListId ?? this.selectedListId),
        selectedListName: clearSelectedList
            ? null
            : (selectedListName ?? this.selectedListName),
        listsLoading: listsLoading ?? this.listsLoading,
        listsError:
            clearListsError ? null : (listsError ?? this.listsError),
        addedCount: addedCount ?? this.addedCount,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

// ──────────────────────────────────────────────────────────────
// コントローラ
// ──────────────────────────────────────────────────────────────

class ShoppingConfirmController extends Notifier<ShoppingConfirmState> {
  @override
  ShoppingConfirmState build() => const ShoppingConfirmState();

  // ---- 初期化: 対象献立から不足食材を計算 ----

  /// 対象献立を受け取り不足食材一覧を計算して [listing] 状態に遷移する。
  ///
  /// [mealsForShoppingProvider] が空なら [decidedMealsProvider] を参照し、
  /// それも空なら [noTarget] 状態にする。
  Future<void> initialize() async {
    // 対象献立を解決する。
    final mealsForShopping = ref.read(mealsForShoppingProvider);
    final decidedMeals = ref.read(decidedMealsProvider);
    await _initialize(mealsForShopping, decidedMeals);
  }

  Future<void> _initialize(
    List<SuggestedRecipe> mealsForShopping,
    List<SuggestedRecipe> decidedMeals,
  ) async {
    final List<SuggestedRecipe> targetMeals;
    if (mealsForShopping.isNotEmpty) {
      targetMeals = mealsForShopping;
    } else if (decidedMeals.isNotEmpty) {
      targetMeals = decidedMeals;
    } else {
      state = const ShoppingConfirmState(phase: ShoppingConfirmPhase.noTarget);
      return;
    }

    // 在庫を一発クエリで取得（stream.first を使わない規約に従う）。
    final inventory = await ref.read(inventoryRepositoryProvider).getInventory();

    // 不足食材の算出: RecipeProvider が解決できれば normalize 込みで行う。
    // API キー未登録・通信失敗時はフォールバックとして純関数のみで続行。
    List<MissingIngredient> missing;
    try {
      final recipeProvider = await ref.read(recipeProviderProvider.future);
      if (recipeProvider != null) {
        final service = MissingIngredientsService(recipeProvider);
        missing = await service.find(
          recipes: targetMeals,
          inventory: inventory,
        );
      } else {
        // API キー未登録 → normalize なしフォールバック。
        missing = findMissingIngredients(
          recipes: targetMeals,
          inventory: inventory,
        );
      }
    } catch (_) {
      // 通信失敗 → normalize なしフォールバック（買い物リスト作成を AI 必須にしない）。
      missing = findMissingIngredients(
        recipes: targetMeals,
        inventory: inventory,
      );
    }

    // UI アイテムに変換（初期: 全チェック ON・個数 1）。
    final items = missing
        .map((m) => ShoppingItem(ingredient: m, checked: true, qty: 1))
        .toList();

    // 設定の shoppingListId/Name を初期選択に使う。
    final settings = await ref.read(settingsRepositoryProvider).get();

    state = ShoppingConfirmState(
      phase: ShoppingConfirmPhase.listing,
      items: items,
      selectedListId: settings.shoppingListId,
      selectedListName: settings.shoppingListName,
    );

    // リスト一覧の先行読み込み（失敗してもリスト操作で再試行できる）。
    _loadLists();
  }

  // ---- チェック操作 ----

  void toggleItem(String name) {
    state = state.copyWith(
      items: state.items
          .map((i) => i.name == name ? i.copyWith(checked: !i.checked) : i)
          .toList(),
    );
  }

  void toggleAll() {
    final next = !state.allChecked;
    state = state.copyWith(
      items: state.items.map((i) => i.copyWith(checked: next)).toList(),
    );
  }

  // ---- 数量ステッパー ----

  void incrementQty(String name) {
    state = state.copyWith(
      items: state.items
          .map((i) => i.name == name ? i.copyWith(qty: i.qty + 1) : i)
          .toList(),
    );
  }

  void decrementQty(String name) {
    state = state.copyWith(
      items: state.items
          .map((i) => i.name == name ? i.copyWith(qty: (i.qty - 1).clamp(1, 999)) : i)
          .toList(),
    );
  }

  // ---- リスト選択 ----

  void selectList(String id, String name) {
    state = state.copyWith(selectedListId: id, selectedListName: name);
  }

  // ---- リスト一覧の読み込み ----

  Future<void> loadLists() => _loadLists();

  Future<void> _loadLists() async {
    state = state.copyWith(listsLoading: true, clearListsError: true);
    try {
      final service = ref.read(shoppingListServiceProvider);
      final lists = await service.getLists();
      state = state.copyWith(availableLists: lists, listsLoading: false);
    } catch (_) {
      state = state.copyWith(
        listsLoading: false,
        listsError: 'error', // UI 側で l10n 文言を使う
      );
    }
  }

  // ---- 新規リスト作成 ----

  Future<void> createList(String name) async {
    if (name.trim().isEmpty) return;
    state = state.copyWith(listsLoading: true, clearListsError: true);
    try {
      final service = ref.read(shoppingListServiceProvider);
      final created = await service.createList(name.trim());
      // 作成したリストを選択し、一覧を再読み込みする。
      state = state.copyWith(
        selectedListId: created.id,
        selectedListName: created.name,
        listsLoading: false,
      );
      _loadLists();
    } catch (_) {
      state = state.copyWith(
        listsLoading: false,
        listsError: 'error',
      );
    }
  }

  // ---- 追加実行 ----

  /// チェックされているアイテムを選択リストへ追加する。
  Future<void> addItems() async {
    final listId = state.selectedListId;
    final listName = state.selectedListName ?? '';
    if (listId == null) return;

    final checked = state.checkedItems;
    if (checked.isEmpty) return;

    state = state.copyWith(phase: ShoppingConfirmPhase.adding);

    try {
      final service = ref.read(shoppingListServiceProvider);
      final shoppingItems = checked.map((i) => i.toShoppingListItem()).toList();
      final added = await service.addItems(listId, shoppingItems);

      state = state.copyWith(
        phase: ShoppingConfirmPhase.done,
        addedCount: added,
        selectedListName: listName,
      );
    } catch (_) {
      state = state.copyWith(
        phase: ShoppingConfirmPhase.error,
        errorMessage: 'error', // UI 側で l10n 文言を使う
      );
    }
  }

  // ---- 完了後のリセット ----

  /// 在庫画面へ戻る際の後始末。mealsForShopping をクリアし状態をリセットする。
  void resetAfterDone() {
    ref.read(mealsForShoppingProvider.notifier).clear();
    state = const ShoppingConfirmState(phase: ShoppingConfirmPhase.noTarget);
  }

  /// エラーから一覧画面に戻る。
  void retryFromError() {
    state = state.copyWith(phase: ShoppingConfirmPhase.listing, clearError: true);
  }
}

final shoppingConfirmControllerProvider =
    NotifierProvider<ShoppingConfirmController, ShoppingConfirmState>(
  ShoppingConfirmController.new,
);
