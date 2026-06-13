import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mobile_nav_buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../../inventory/presentation/inventory_providers.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../shopping/presentation/shopping_mobile_view.dart';
import '../../shopping/service/missing_ingredients_service.dart';
import '../domain/recipe_constraints.dart';
import '../domain/suggested_recipe.dart';
import 'meal_suggestion_controller.dart';

// ──────────────────────────────────────────────────────────────
// MealsMobileScreen（モバイル＝狭い幅の献立提案画面）
//
// mealsPhone.jsx を Flutter で再現した全画面（Navigator.push で開く）。
// 状態はすべて [mealSuggestionControllerProvider] / [decidedMealsProvider] を
// 再利用し、この view は表示とイベント転送のみを行う（ロジックの複製は禁止）。
//
// フェーズ（mealsPhone.jsx 準拠）:
//   提案前 → 生成中 → 結果カード一覧 / 在庫わずか → エラー
// レシピ詳細はデスクトップの 2ペインと違い、カードを展開（タップでトグル）して
// 材料・手順を見せる（単一 Scaffold を保つため）。
// ──────────────────────────────────────────────────────────────
class MealsMobileScreen extends ConsumerWidget {
  const MealsMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(mealSuggestionControllerProvider);
    final focus = st.focusIngredient;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            if (focus != null)
              _MobileFocusBanner(
                ingredient: focus,
                onClear: () => ref
                    .read(mealSuggestionControllerProvider.notifier)
                    .clearFocusIngredient(),
              ),
            Expanded(
              child: switch (st.status) {
                MealSuggestionStatus.before => _BeforeView(state: st),
                MealSuggestionStatus.generating => const _GeneratingView(),
                MealSuggestionStatus.error =>
                  _ErrorView(error: st.error ?? MealSuggestionError.network),
                MealSuggestionStatus.results ||
                MealSuggestionStatus.lowStock =>
                  _ResultsView(state: st),
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 共通ヘルパー
// ──────────────────────────────────────────────────────────────



/// 条件チップの (kind, label) 一覧（デスクトップ版と同じ l10n キーを再利用）。
List<(MealKind, String)> _kindLabels(AppLocalizations l10n) => [
      (MealKind.auto, l10n.mealsCondAuto),
      (MealKind.mainOnly, l10n.mealsCondMainOnly),
      (MealKind.oneMore, l10n.mealsCondOneMore),
      (MealKind.quick, l10n.mealsCondQuick),
    ];

/// 横スクロールする条件チップ列。
class _ConditionChips extends ConsumerWidget {
  const _ConditionChips({required this.selected});
  final MealKind selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final (kind, label) in _kindLabels(l10n))
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ConditionChip(
                label: label,
                selected: selected == kind,
                onTap: () => ref
                    .read(mealSuggestionControllerProvider.notifier)
                    .setKind(kind),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.green : AppColors.card,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: selected ? null : Border.all(color: AppColors.line),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? Colors.white : AppColors.sub,
            ),
          ),
        ),
      ),
    );
  }
}

/// 家電バッジ（デスクトップ版と同じ配色・l10n キー）。
Widget _applianceBadge(AppLocalizations l10n, String? appliance) =>
    switch (appliance) {
      'hotcook' => _Pill(
          label: l10n.mealsApplianceHotcook,
          bg: AppColors.greenSoft,
          fg: AppColors.greenInk,
        ),
      'healsio' => _Pill(
          label: l10n.mealsApplianceHealsio,
          bg: const Color(0xFFE8EEF8),
          fg: const Color(0xFF2A5CB8),
        ),
      _ => _Pill(
          label: l10n.mealsApplianceNormal,
          bg: AppColors.plentySoft,
          fg: AppColors.sub,
        ),
    };

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 1. 提案前（食事種別選択 + 提案ボタン）
// ──────────────────────────────────────────────────────────────
class _BeforeView extends ConsumerWidget {
  const _BeforeView({required this.state});
  final MealSuggestionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ヘッダー（戻る + タイトル）
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              const MobileNavBackButton(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.mealsTitle,
                        style: brandTextStyle(fontSize: 26, height: 1.1)),
                    const SizedBox(height: 2),
                    Text(l10n.mealsSubtitle,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sub)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
          child: Text(l10n.mealsConditionsPrompt,
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink)),
        ),
        _ConditionChips(selected: state.kind),
        const Spacer(),
        // 主要 CTA
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: _PrimaryButton(
            icon: Icons.auto_awesome,
            label: l10n.mealsSuggestButton,
            onTap: () =>
                ref.read(mealSuggestionControllerProvider.notifier).suggest(),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 2. 生成中（パルスアイコン + キャンセル）
// ──────────────────────────────────────────────────────────────
class _GeneratingView extends StatefulWidget {
  const _GeneratingView();

  @override
  State<_GeneratingView> createState() => _GeneratingViewState();
}

class _GeneratingViewState extends State<_GeneratingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: Tween(begin: 0.4, end: 1.0).animate(_ctrl),
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: AppColors.greenSoft,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.auto_awesome,
                          size: 42, color: AppColors.green),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(l10n.mealsGeneratingTitle,
                      style: brandTextStyle(fontSize: 21)),
                  const SizedBox(height: 8),
                  Text(l10n.mealsGenerating,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sub)),
                ],
              ),
            ),
          ),
        ),
        // 生成は60秒タイムアウト・キャンセル不可のため、画面を閉じる（戻る）導線にする。
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          child: TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(l10n.mealsCancel,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.sub)),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 3 / 4. 結果カード一覧（通常 + 在庫わずか）
// ──────────────────────────────────────────────────────────────
class _ResultsView extends ConsumerWidget {
  const _ResultsView({required this.state});
  final MealSuggestionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final low = state.status == MealSuggestionStatus.lowStock;
    final decided = ref.watch(decidedMealsProvider);

    // 在庫突き合わせ（デスクトップ版と同じく名前一致で不足判定）。
    final inventory = ref.watch(inventoryListProvider).maybeWhen(
          data: (l) => l,
          orElse: () => <Ingredient>[],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ヘッダー（戻る + タイトル + 再提案）
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              const MobileNavBackButton(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.mealsTitle,
                        style: brandTextStyle(fontSize: 22, height: 1.1)),
                    const SizedBox(height: 2),
                    Text(l10n.mealsResultCount(state.recipes.length),
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sub)),
                  ],
                ),
              ),
              MobileNavIconButton(
                icon: Icons.refresh,
                onTap: () => ref
                    .read(mealSuggestionControllerProvider.notifier)
                    .suggest(),
              ),
            ],
          ),
        ),
        // 案内バナー
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: low ? AppColors.nearSoft : AppColors.greenSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  low ? Icons.shopping_bag_outlined : Icons.auto_awesome,
                  size: 19,
                  color: low ? AppColors.near : AppColors.green,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    low ? l10n.mealsLowStockBanner : l10n.mealsResultBanner,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _ConditionChips(selected: state.kind),
        const SizedBox(height: 4),
        // カード一覧
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: state.recipes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final r = state.recipes[i];
              return _MealCard(
                recipe: r,
                inventory: inventory,
                decided: decided.any((m) => m.title == r.title),
              );
            },
          ),
        ),
        // 「買い物リストへ」CTA（決定済みがあるときのみ）
        if (decided.isNotEmpty)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: _PrimaryButton(
                icon: Icons.checklist,
                label: l10n.mealsToShoppingCount(decided.length),
                onTap: () => _goToShopping(context, ref, decided),
              ),
            ),
          ),
      ],
    );
  }

  void _goToShopping(
    BuildContext context,
    WidgetRef ref,
    List<SuggestedRecipe> decided,
  ) {
    // 決定済み献立を M5（買い物リスト）に引き渡してから遷移する。
    // ShoppingMobileScreen は initState で initialize() を呼び不足食材を計算する。
    ref.read(mealsForShoppingProvider.notifier).set(decided);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const ShoppingMobileScreen(),
    ));
  }
}

// ──────────────────────────────────────────────────────────────
// レシピカード（タップで材料・手順を展開）
// ──────────────────────────────────────────────────────────────
class _MealCard extends ConsumerStatefulWidget {
  const _MealCard({
    required this.recipe,
    required this.inventory,
    required this.decided,
  });

  final SuggestedRecipe recipe;
  final List<Ingredient> inventory;
  final bool decided;

  @override
  ConsumerState<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends ConsumerState<_MealCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = widget.recipe;

    // 不足食材（名前一致でデスクトップ版と同じ判定）。
    final missing = findMissingIngredients(recipes: [r], inventory: widget.inventory)
        .map((m) => m.name)
        .toSet();
    final shortageCount = r.ingredients.where((i) => missing.contains(i.name)).length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x0A282723), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── ヘッダー（タップで展開トグル） ──
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          r.title,
                          style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              height: 1.3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.decided)
                        const Icon(Icons.check_circle,
                            size: 18, color: AppColors.green),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: const Icon(Icons.expand_more,
                            size: 22, color: AppColors.faint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 7,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _applianceBadge(l10n, r.appliance),
                      if (r.cookMinutes != null)
                        _Pill(
                          label: l10n.mealsCookMinutes(r.cookMinutes!),
                          bg: AppColors.plentySoft,
                          fg: AppColors.sub,
                        ),
                      if (r.usesExpiringSoon)
                        _Pill(
                          label: l10n.mealsBadgeUseNear,
                          bg: AppColors.nearSoft,
                          fg: AppColors.near,
                        ),
                      if (shortageCount > 0)
                        _Pill(
                          label: l10n.mealsShortageCount(shortageCount),
                          bg: AppColors.plentySoft,
                          fg: AppColors.sub,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ── 展開部（材料 + 手順 + これ作るトグル） ──
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.line),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 材料
                  Text(l10n.mealsIngredientsHeading,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink)),
                  const SizedBox(height: 8),
                  for (final ing in r.ingredients)
                    _IngredientRow(
                      ingredient: ing,
                      inStock: !missing.contains(ing.name),
                    ),
                  const SizedBox(height: 16),
                  // 手順
                  Text(l10n.mealsStepsHeading,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink)),
                  const SizedBox(height: 10),
                  for (var i = 0; i < r.steps.length; i++)
                    _StepRow(index: i + 1, text: r.steps[i]),
                  const SizedBox(height: 6),
                  // 「これ作る」トグル
                  _DecideButton(
                    decided: widget.decided,
                    onTap: () =>
                        ref.read(decidedMealsProvider.notifier).toggle(r),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 材料1行（在庫=緑チェック / 不足=買い物バッグ）。
class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient, required this.inStock});
  final RecipeIngredient ingredient;
  final bool inStock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: inStock ? AppColors.greenSoft : AppColors.plentySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              inStock ? Icons.check : Icons.shopping_bag_outlined,
              size: 12,
              color: inStock ? AppColors.green : AppColors.sub,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ingredient.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: inStock ? AppColors.ink : AppColors.sub,
              ),
            ),
          ),
          if (ingredient.amount.isNotEmpty) ...[
            Text(
              ingredient.amount,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sub),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            inStock ? l10n.mealsIngInStock : l10n.mealsIngToBuy,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: inStock ? AppColors.green : AppColors.sub,
            ),
          ),
        ],
      ),
    );
  }
}

/// 番号付き手順ステップ（デスクトップ版と同じ見た目）。
class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});
  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.greenSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text('$index',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.greenInk)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                      height: 1.65)),
            ),
          ),
        ],
      ),
    );
  }
}

/// 「これ作る」トグルボタン（decidedMealsProvider.toggle）。
class _DecideButton extends StatelessWidget {
  const _DecideButton({required this.decided, required this.onTap});
  final bool decided;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: decided ? AppColors.green : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: decided ? null : Border.all(color: AppColors.green, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(decided ? Icons.check_circle : Icons.add,
                  size: 18, color: decided ? Colors.white : AppColors.greenInk),
              const SizedBox(width: 8),
              Text(
                decided ? l10n.mealsDecided : l10n.mealsDecide,
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: decided ? Colors.white : AppColors.greenInk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 5. エラー（メッセージ + 再試行 / 設定導線 + 在庫に戻る）
// ──────────────────────────────────────────────────────────────
class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.error});
  final MealSuggestionError error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isNoKey = error == MealSuggestionError.noApiKey;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.nearSoft,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isNoKey ? Icons.key_off_outlined : Icons.wifi_off_outlined,
                      size: 44,
                      color: AppColors.near,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isNoKey ? l10n.mealsErrorNoApiKeyTitle : l10n.mealsErrorTitle,
                    textAlign: TextAlign.center,
                    style: brandTextStyle(fontSize: 21),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isNoKey ? l10n.mealsErrorNoApiKey : l10n.mealsErrorNetwork,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.sub,
                        height: 1.7),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          child: Column(
            children: [
              _PrimaryButton(
                icon: isNoKey ? Icons.settings_outlined : Icons.refresh,
                label: isNoKey ? l10n.mealsOpenSettings : l10n.mealsRetry,
                onTap: () {
                  if (isNoKey) {
                    Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ));
                  } else {
                    ref
                        .read(mealSuggestionControllerProvider.notifier)
                        .suggest();
                  }
                },
              ),
              const SizedBox(height: 12),
              _SecondaryButton(
                label: l10n.mealsBackToInventory,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 共通ボタン
// ──────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.green,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 62,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 23),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
        ),
      ),
    );
  }
}

/// モバイル用 起点食材バナー（「レシピを見る」から来た場合）。
class _MobileFocusBanner extends StatelessWidget {
  const _MobileFocusBanner({
    required this.ingredient,
    required this.onClear,
  });

  final Ingredient ingredient;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, size: 18, color: AppColors.greenInk),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.mealsFocusBanner(ingredient.name),
              style: const TextStyle(fontSize: 13, color: AppColors.greenInk),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 18, color: AppColors.greenInk),
          ),
        ],
      ),
    );
  }
}
