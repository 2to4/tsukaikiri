import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'ai_unavailable_notice.dart';
import '../../inventory/presentation/inventory_providers.dart';
import '../../shell/presentation/shell_providers.dart';
import '../../shopping/service/missing_ingredients_service.dart';
import '../domain/recipe_constraints.dart';
import '../domain/suggested_recipe.dart';
import 'meal_suggestion_controller.dart';

// ──────────────────────────────────────────────────────────────
// 定数
// ──────────────────────────────────────────────────────────────
const double _kListPaneWidth = 360.0;

// ──────────────────────────────────────────────────────────────
// MealsDesktopView（メインウィジェット）
// macosApp.jsx の MealsScreen を Flutter で再現した 2ペイン献立提案ビュー。
// ──────────────────────────────────────────────────────────────
class MealsDesktopView extends ConsumerStatefulWidget {
  const MealsDesktopView({super.key});

  @override
  ConsumerState<MealsDesktopView> createState() => _MealsDesktopViewState();
}

class _MealsDesktopViewState extends ConsumerState<MealsDesktopView> {
  /// 右ペインで選択中の献立 title（提案は id を持たないため title を同一性キーにする）。
  String? _selectedTitle;

  void _suggest() {
    setState(() => _selectedTitle = null);
    ref.read(mealSuggestionControllerProvider.notifier).suggest();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(mealSuggestionControllerProvider);
    final recipes = st.recipes;

    // 提案結果が更新されたら先頭を自動選択する。
    final selected = recipes
        .where((r) => r.title == _selectedTitle)
        .cast<SuggestedRecipe?>()
        .firstOrNull;
    final effectiveSelected = selected ?? (recipes.isNotEmpty ? recipes.first : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 左: 条件 + 結果リスト ──
        _ListPane(
          state: st,
          selectedTitle: effectiveSelected?.title,
          onSuggest: _suggest,
          onSelect: (title) => setState(() => _selectedTitle = title),
        ),
        // ── 右: 詳細 ──
        Expanded(
          child: _DetailPane(recipe: effectiveSelected),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _ListPane: 左ペイン（条件チップ + 提案ボタン + 結果リスト）
// ──────────────────────────────────────────────────────────────
class _ListPane extends ConsumerWidget {
  const _ListPane({
    required this.state,
    required this.selectedTitle,
    required this.onSuggest,
    required this.onSelect,
  });

  final MealSuggestionState state;
  final String? selectedTitle;
  final VoidCallback onSuggest;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final generating = state.status == MealSuggestionStatus.generating;
    // この端末で AI が使えるか（オンデバイス対応 or 自前キー登録済み）。
    final aiAvailable = ref.watch(aiAvailableProvider).maybeWhen(data: (v) => v, orElse: () => true);

    return Container(
      width: _kListPaneWidth,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAF7),
        border: Border(right: BorderSide(color: AppColors.line, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 条件ヘッダー ──
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.mealsConditionsLabel,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.faint,
                    letterSpacing: 10.5 * 0.06,
                  ),
                ),
                const SizedBox(height: 8),
                // 条件チップ
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final (kind, label) in _kindLabels(l10n))
                      _ConditionChip(
                        label: label,
                        selected: state.kind == kind,
                        onTap: () => ref
                            .read(mealSuggestionControllerProvider.notifier)
                            .setKind(kind),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                // 「在庫から提案する」ボタン（⌘R 表記）
                _SuggestButton(
                  label: l10n.mealsSuggestButton,
                  shortcut: l10n.mealsSuggestShortcut,
                  disabled: generating || !aiAvailable,
                  onTap: (generating || !aiAvailable) ? null : onSuggest,
                ),
                // 起点食材バナー（詳細の「レシピを見る」から来た場合）
                if (state.focusIngredient != null)
                  _FocusIngredientBanner(
                    ingredient: state.focusIngredient!,
                    onClear: () => ref
                        .read(mealSuggestionControllerProvider.notifier)
                        .clearFocusIngredient(),
                  ),
              ],
            ),
          ),
          // ── 結果リスト（スクロール） ──
          Expanded(
            child: _ListBody(
              state: state,
              selectedTitle: selectedTitle,
              onSelect: onSelect,
              onRetry: onSuggest,
              aiAvailable: aiAvailable,
            ),
          ),
        ],
      ),
    );
  }

  List<(MealKind, String)> _kindLabels(AppLocalizations l10n) => [
        (MealKind.auto, l10n.mealsCondAuto),
        (MealKind.mainOnly, l10n.mealsCondMainOnly),
        (MealKind.oneMore, l10n.mealsCondOneMore),
        (MealKind.quick, l10n.mealsCondQuick),
      ];
}

// ──────────────────────────────────────────────────────────────
// _ListBody: 左ペイン下部（状態別の本体）
// ──────────────────────────────────────────────────────────────
class _ListBody extends ConsumerWidget {
  const _ListBody({
    required this.state,
    required this.selectedTitle,
    required this.onSelect,
    required this.onRetry,
    required this.aiAvailable,
  });

  final MealSuggestionState state;
  final String? selectedTitle;
  final ValueChanged<String> onSelect;
  final VoidCallback onRetry;
  final bool aiAvailable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    switch (state.status) {
      case MealSuggestionStatus.before:
        // AI 非対応端末（オンデバイス不可かつキー未登録）では入口を無効化し案内。
        if (!aiAvailable) return const AiUnavailableNotice();
        return _CenteredHint(emoji: '🍳', text: l10n.mealsBeforeBody);

      case MealSuggestionStatus.generating:
        return _GeneratingBody(text: l10n.mealsGenerating);

      case MealSuggestionStatus.error:
        return _ErrorBody(
          error: state.error ?? MealSuggestionError.network,
          onRetry: onRetry,
          onOpenSettings: () => ref
              .read(shellSectionProvider.notifier)
              .select(ShellSection.settings),
        );

      case MealSuggestionStatus.results:
      case MealSuggestionStatus.lowStock:
        return _ResultsList(
          state: state,
          selectedTitle: selectedTitle,
          onSelect: onSelect,
        );
    }
  }
}

// ──────────────────────────────────────────────────────────────
// _ResultsList: 提案結果の献立リスト（在庫わずかバナー付き）
// ──────────────────────────────────────────────────────────────
class _ResultsList extends ConsumerWidget {
  const _ResultsList({
    required this.state,
    required this.selectedTitle,
    required this.onSelect,
  });

  final MealSuggestionState state;
  final String? selectedTitle;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final decided = ref.watch(decidedMealsProvider);

    return ListView(
      children: [
        // 在庫わずか案内バナー
        if (state.status == MealSuggestionStatus.lowStock)
          Container(
            margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.nearSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 15, color: AppColors.near),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.mealsLowStockBanner,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.near,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        for (final recipe in state.recipes)
          _MealRow(
            recipe: recipe,
            selected: recipe.title == selectedTitle,
            decided: decided.any((m) => m.title == recipe.title),
            onTap: () => onSelect(recipe.title),
          ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _MealRow: 献立リストの1行
// ──────────────────────────────────────────────────────────────
class _MealRow extends StatefulWidget {
  const _MealRow({
    required this.recipe,
    required this.selected,
    required this.decided,
    required this.onTap,
  });

  final SuggestedRecipe recipe;
  final bool selected;
  final bool decided;
  final VoidCallback onTap;

  @override
  State<_MealRow> createState() => _MealRowState();
}

class _MealRowState extends State<_MealRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recipe = widget.recipe;

    Color bg;
    if (widget.selected) {
      bg = const Color(0xFFEDF5F1);
    } else if (_hovered) {
      bg = const Color(0x09282723);
    } else {
      bg = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
          decoration: BoxDecoration(
            color: bg,
            border: const Border(
              bottom: BorderSide(color: AppColors.line, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 料理名 + 期限近いバッジ + 決定済みチェック
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: widget.selected
                            ? AppColors.greenInk
                            : AppColors.ink,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (widget.decided) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.check_circle,
                        size: 15, color: AppColors.green),
                  ],
                  if (recipe.usesExpiringSoon) ...[
                    const SizedBox(width: 6),
                    _Pill(
                      label: l10n.mealsBadgeUseNear,
                      bg: AppColors.nearSoft,
                      fg: AppColors.near,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              // 家電バッジ + 調理時間
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _applianceBadge(l10n, recipe.appliance),
                  if (recipe.cookMinutes != null)
                    _Pill(
                      label: l10n.mealsCookMinutes(recipe.cookMinutes!),
                      bg: AppColors.plentySoft,
                      fg: AppColors.sub,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 家電バッジ（macosApp.jsx の device バッジ配色を踏襲）。
Widget _applianceBadge(AppLocalizations l10n, String? appliance) {
  return switch (appliance) {
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
}

// ──────────────────────────────────────────────────────────────
// _Pill: 角丸ピル型ラベル
// ──────────────────────────────────────────────────────────────
class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _ConditionChip: 条件チップ（ピル型・選択中 greenSoft + green ボーダー）
// ──────────────────────────────────────────────────────────────
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenSoft : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.line,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.greenInk : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

/// 「レシピを見る」などで指定された起点食材のバナー（クリア可能）。
class _FocusIngredientBanner extends StatelessWidget {
  const _FocusIngredientBanner({
    required this.ingredient,
    required this.onClear,
  });

  final Ingredient ingredient;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, size: 16, color: AppColors.greenInk),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.mealsFocusBanner(ingredient.name),
              style: const TextStyle(fontSize: 12, color: AppColors.greenInk),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 16, color: AppColors.greenInk),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _SuggestButton: 「在庫から提案する」primary ボタン（⌘R 表記）
// ──────────────────────────────────────────────────────────────
class _SuggestButton extends StatefulWidget {
  const _SuggestButton({
    required this.label,
    required this.shortcut,
    required this.disabled,
    required this.onTap,
  });

  final String label;
  final String shortcut;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  State<_SuggestButton> createState() => _SuggestButtonState();
}

class _SuggestButtonState extends State<_SuggestButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.disabled;
    final bg = disabled
        ? AppColors.faint
        : (_hovered ? AppColors.greenInk : AppColors.green);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(9),
            boxShadow: disabled
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x381F7A55),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_outlined,
                  size: 14, color: Colors.white),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.shortcut,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _CenteredHint: 中央の絵文字 + 案内テキスト（提案前）
// ──────────────────────────────────────────────────────────────
class _CenteredHint extends StatelessWidget {
  const _CenteredHint({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.faint,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _GeneratingBody: 生成中（パルスアイコン）
// ──────────────────────────────────────────────────────────────
class _GeneratingBody extends StatefulWidget {
  const _GeneratingBody({required this.text});

  final String text;

  @override
  State<_GeneratingBody> createState() => _GeneratingBodyState();
}

class _GeneratingBodyState extends State<_GeneratingBody>
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 0.4, end: 1.0).animate(_ctrl),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.auto_awesome_outlined,
                  size: 24, color: AppColors.green),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.sub,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _ErrorBody: エラー（メッセージ + 再試行 / 設定導線）
// ──────────────────────────────────────────────────────────────
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.error,
    required this.onRetry,
    required this.onOpenSettings,
  });

  final MealSuggestionError error;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isNoKey = error == MealSuggestionError.noApiKey;
    final message =
        isNoKey ? l10n.mealsErrorNoApiKey : l10n.mealsErrorNetwork;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNoKey ? Icons.key_off_outlined : Icons.wifi_off_outlined,
            size: 30,
            color: AppColors.over,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.sub,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          // API キー未登録 → 設定導線、それ以外 → 再試行
          OutlinedButton(
            onPressed: isNoKey ? onOpenSettings : onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.green,
              side: const BorderSide(color: AppColors.green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(isNoKey ? l10n.mealsOpenSettings : l10n.mealsRetry),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _DetailPane: 右ペイン（選択献立の詳細）
// ──────────────────────────────────────────────────────────────
class _DetailPane extends ConsumerWidget {
  const _DetailPane({required this.recipe});

  final SuggestedRecipe? recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (recipe == null) {
      // 未選択時のプレースホルダ
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥘', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 10),
            Text(
              l10n.mealsDetailEmpty,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.faint,
              ),
            ),
          ],
        ),
      );
    }

    final r = recipe!;
    final decided = ref.watch(decidedMealsProvider).any((m) => m.title == r.title);

    // 在庫突き合わせ（MissingIngredientsService のロジックを再利用）。
    // ここでは UI 描画のため同期処理にしたいので、名寄せキー無し（名前一致のみ）で判定する。
    final inventory =
        ref.watch(inventoryListProvider).maybeWhen(data: (l) => l, orElse: () => <Ingredient>[]);
    final missing = findMissingIngredients(recipes: [r], inventory: inventory)
        .map((m) => m.name)
        .toSet();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ヘッダー（料理名 + 調理時間 + アクション） ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.title,
                      style: brandTextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (r.cookMinutes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.mealsCookTime(r.cookMinutes!),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.sub,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 「買い物リストへ」secondary
              _DetailButton(
                icon: Icons.checklist_outlined,
                label: l10n.mealsToShopping,
                primary: false,
                onTap: () {
                  // 決定済みがあればそれを、なければこの献立を M5 へ渡す。
                  final decidedMeals = ref.read(decidedMealsProvider);
                  final target =
                      decidedMeals.isNotEmpty ? decidedMeals : [r];
                  ref.read(mealsForShoppingProvider.notifier).set(target);
                  // TODO(M5): 買い物リスト 2ペインビューを実装したら遷移先が機能する。
                  ref
                      .read(shellSectionProvider.notifier)
                      .select(ShellSection.shopping);
                },
              ),
              const SizedBox(width: 8),
              // 「献立に決める」primary（決定済みはトグル）
              _DetailButton(
                icon: decided ? Icons.check_circle : Icons.check,
                label: decided ? l10n.mealsDecided : l10n.mealsDecide,
                primary: true,
                onTap: () =>
                    ref.read(decidedMealsProvider.notifier).toggle(r),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // ── 材料 ──
          _SectionHeading(l10n.mealsIngredientsHeading),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final ing in r.ingredients)
                _IngredientChip(
                  ingredient: ing,
                  inStock: !missing.contains(ing.name),
                ),
            ],
          ),
          const SizedBox(height: 22),
          // ── 手順 ──
          _SectionHeading(l10n.mealsStepsHeading),
          const SizedBox(height: 10),
          for (var i = 0; i < r.steps.length; i++)
            _StepRow(index: i + 1, text: r.steps[i]),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _SectionHeading: 「材料」「手順」見出し
// ──────────────────────────────────────────────────────────────
class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.faint,
        letterSpacing: 12 * 0.06,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _IngredientChip: 材料チップ（在庫あり=greenSoft / 不足=nearSoft）
// ──────────────────────────────────────────────────────────────
class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.ingredient, required this.inStock});

  final RecipeIngredient ingredient;
  final bool inStock;

  @override
  Widget build(BuildContext context) {
    final bg = inStock ? AppColors.greenSoft : AppColors.nearSoft;
    final fg = inStock ? AppColors.greenInk : AppColors.near;
    // 絵文字は AI 出力に含まれないため省略（嘘のデータは作らない）。
    final text = ingredient.amount.isEmpty
        ? ingredient.name
        : '${ingredient.name} ${ingredient.amount}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _StepRow: 番号付きの手順ステップ
// ──────────────────────────────────────────────────────────────
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
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  height: 1.65,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _DetailButton: 詳細ヘッダーのアクションボタン（primary / secondary）
// ──────────────────────────────────────────────────────────────
class _DetailButton extends StatefulWidget {
  const _DetailButton({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  State<_DetailButton> createState() => _DetailButtonState();
}

class _DetailButtonState extends State<_DetailButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (widget.primary) {
      bg = _hovered ? AppColors.greenInk : AppColors.green;
      fg = Colors.white;
    } else {
      bg = _hovered ? Colors.white : const Color(0xD1FFFFFF);
      fg = AppColors.ink;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: widget.primary
                ? null
                : Border.all(color: AppColors.line, width: 1),
            boxShadow: widget.primary
                ? const [
                    BoxShadow(
                      color: Color(0x381F7A55),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,
                  size: 13, color: widget.primary ? Colors.white : AppColors.sub),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
