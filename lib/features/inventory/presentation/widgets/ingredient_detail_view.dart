import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shopping/domain/shopping_list.dart';
import '../../domain/category_style.dart';
import '../../domain/unit_option.dart';
import '../expiry_status.dart';
import '../ingredient_form_screen.dart';
import '../inventory_providers.dart';
import 'expiry_badge.dart';

/// 食材の詳細・編集。狭い画面では詳細ページ本体、広い画面では右ペインに置く。
///
/// [ingredientId] から在庫ストリームの最新値を引き当てて表示するため、
/// 数量ステッパー等の変更が即座に反映される。対象が消えたら [onGone] を呼ぶ。
class IngredientDetailView extends ConsumerWidget {
  const IngredientDetailView({
    super.key,
    required this.ingredientId,
    this.onGone,
  });

  final String ingredientId;

  /// 対象が在庫から消えた（使い切った／削除）ときに呼ばれる。
  final VoidCallback? onGone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncList = ref.watch(inventoryListProvider);
    final ing = asyncList.maybeWhen(
      data: (items) =>
          items.where((e) => e.id == ingredientId).cast<Ingredient?>().firstOrNull,
      orElse: () => null,
    );

    if (ing == null) {
      // ストリーム更新で消えたら通知（ビルド後に実行）。
      if (asyncList.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onGone?.call());
      }
      return const SizedBox.shrink();
    }

    final repo = ref.read(inventoryRepositoryProvider);
    final dateFmt = DateFormat.yMMMEd(Localizations.localeOf(context).toString());
    final info = expiryInfoFor(ing.expiryDate, DateTime.now());

    Future<void> remove(String toast) async {
      final snapshot = ing;
      // メッセンジャはルートより上に存在するため、詳細画面を pop した後も使える。
      final messenger = ScaffoldMessenger.of(context);
      await repo.deleteById(ing.id);
      onGone?.call();
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(toast),
          action: SnackBarAction(
            label: l10n.actionUndo,
            textColor: AppColors.greenSoft,
            onPressed: () => repo.save(snapshot),
          ),
        ));
    }

    void toast(String message) => ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));

    // この食材1件を設定済みの買い物リストへ追加する。
    // リスト未設定なら設定への誘導、通信失敗ならオフライン文言を出す。
    Future<void> addToShoppingList() async {
      final messenger = ScaffoldMessenger.of(context);
      final settings = await ref.read(settingsRepositoryProvider).get();
      final listId = settings.shoppingListId;
      if (listId == null || listId.isEmpty) {
        messenger
          ..clearSnackBars()
          ..showSnackBar(
              SnackBar(content: Text(l10n.detailShoppingListNotConfigured)));
        return;
      }
      try {
        final service = ref.read(shoppingListServiceProvider);
        await service.addItems(listId, [ShoppingListItem(title: ing.name)]);
        messenger
          ..clearSnackBars()
          ..showSnackBar(
              SnackBar(content: Text(l10n.detailAddedToShoppingList)));
      } catch (_) {
        messenger
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(l10n.settingsNetworkError)));
      }
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            children: [
              // ヒーロー
              Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: ing.category.style.tile,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    alignment: Alignment.center,
                    child: Text(ing.category.style.emoji,
                        style: const TextStyle(fontSize: 52)),
                  ),
                  const SizedBox(height: 14),
                  Text(ing.name,
                      textAlign: TextAlign.center,
                      style: brandTextStyle(fontSize: 24)),
                  const SizedBox(height: 10),
                  ExpiryBadge(expiry: ing.expiryDate, large: true),
                ],
              ),
              const SizedBox(height: 16),
              // 情報カード
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _StepRow(
                      label: l10n.fieldQuantity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _stepBtn(Icons.remove,
                              () => repo.decrement(ing.id)),
                          SizedBox(
                            width: 64,
                            child: Text(
                              '${formatQuantity(ing.quantity)}${unitLabel(ing.unit, l10n)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                          ),
                          _stepBtn(
                              Icons.add, () => repo.increment(ing.id)),
                        ],
                      ),
                    ),
                    _divider(),
                    _StepRow(
                      label: l10n.fieldCategory,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: ing.category.style.tile,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(ing.category.label(l10n),
                            style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink)),
                      ),
                    ),
                    _divider(),
                    _StepRow(
                      label: l10n.fieldExpiry,
                      child: Text(
                        ing.expiryDate != null
                            ? dateFmt.format(ing.expiryDate!)
                            : l10n.expiryNone,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: ing.expiryDate != null
                                ? info.badgeColor
                                : AppColors.faint),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // 副アクション（レシピ提案は後フェーズ機能）
              Row(
                children: [
                  Expanded(
                    child: _secondary(context, Icons.shopping_bag_outlined,
                        l10n.detailAddToShoppingList, addToShoppingList),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _secondary(context, Icons.menu_book_outlined,
                        l10n.detailViewRecipe, () => toast(l10n.comingSoon)),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 主アクション
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => remove(l10n.toastUsedUp),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.check),
                  label: Text(l10n.actionUsedUp,
                      style: const TextStyle(
                          fontSize: 16.5, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              _iconBtn(Icons.edit_outlined, AppColors.ink, () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => IngredientFormScreen(ingredient: ing),
                ));
              }),
              const SizedBox(width: 10),
              // 削除はスナックバーの「元に戻す」で取り消せる（使い切ったと同じ扱い）。
              _iconBtn(Icons.delete_outline, AppColors.over,
                  () => remove(l10n.toastDeleted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Material(
          color: const Color(0xFFF4F1EB),
          borderRadius: BorderRadius.circular(11),
          child: InkWell(
            borderRadius: BorderRadius.circular(11),
            onTap: onTap,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(icon, size: 18, color: AppColors.ink),
            ),
          ),
        ),
      );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) => Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: color == AppColors.over
                      ? AppColors.overSoft
                      : AppColors.line,
                  width: 1.5),
            ),
            child: Icon(icon, color: color),
          ),
        ),
      );

  Widget _secondary(BuildContext context, IconData icon, String label,
          VoidCallback onPressed) =>
      OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.card,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.line, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: Icon(icon, size: 18, color: AppColors.green),
        label: Text(label,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
      );

  Widget _divider() => const Divider(height: 1, color: AppColors.line);
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sub)),
          child,
        ],
      ),
    );
  }
}
