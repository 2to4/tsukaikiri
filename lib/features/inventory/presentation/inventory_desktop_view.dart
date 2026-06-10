import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/quantity_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../shell/presentation/shell_providers.dart';
import '../domain/category_style.dart';
import '../domain/ingredient_category.dart';
import 'expiry_status.dart';
import 'ingredient_form_screen.dart';
import 'inventory_providers.dart';
import 'widgets/cat_tile.dart';

// ──────────────────────────────────────────────────────────────
// デスクトップ定数
// ──────────────────────────────────────────────────────────────
const double _kFilterRailWidth = 168.0;
const double _kDetailPaneWidth = 300.0;

// ──────────────────────────────────────────────────────────────
// 期限グループ定義（macosApp.jsx の InventoryScreen に対応）
// ──────────────────────────────────────────────────────────────

enum _DesktopGroup {
  /// 今日・もうすぐ: 残り 3 日以下（超過含む）
  now,

  /// 今週のうちに: 4〜7 日
  week,

  /// まだ余裕: 8 日以上 or 期限なし
  plenty,
}

extension _DesktopGroupX on _DesktopGroup {
  String title(AppLocalizations l10n) => switch (this) {
        _DesktopGroup.now => l10n.desktopGroupNow,
        _DesktopGroup.week => l10n.desktopGroupWeek,
        _DesktopGroup.plenty => l10n.desktopGroupPlenty,
      };

  Color get headColor => switch (this) {
        _DesktopGroup.now => AppColors.near,
        _DesktopGroup.week => AppColors.ink,
        _DesktopGroup.plenty => AppColors.sub,
      };

  bool test(int? daysLeft) => switch (this) {
        // 期限なし（daysLeft == null）は plenty に含める
        _DesktopGroup.now => daysLeft != null && daysLeft <= 3,
        _DesktopGroup.week => daysLeft != null && daysLeft >= 4 && daysLeft <= 7,
        _DesktopGroup.plenty => daysLeft == null || daysLeft >= 8,
      };
}

// ──────────────────────────────────────────────────────────────
// InventoryDesktopView（メインウィジェット）
// macosApp.jsx の InventoryScreen を Flutter で忠実に再現した
// 3ペイン構成のデスクトップ在庫ビュー。
// ──────────────────────────────────────────────────────────────

/// 食材フォームをデスクトップスタイルのダイアログ（480×640 角丸カード）で開く。
/// ツールバー・行ホバー・詳細ペイン・シェルの ⌘N から共通で使う。
Future<void> showIngredientFormDialog(
  BuildContext context, {
  Ingredient? ingredient,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: 480,
        height: 640,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IngredientFormScreen(ingredient: ingredient),
        ),
      ),
    ),
  );
}

class InventoryDesktopView extends ConsumerStatefulWidget {
  const InventoryDesktopView({super.key});

  @override
  ConsumerState<InventoryDesktopView> createState() =>
      _InventoryDesktopViewState();
}

class _InventoryDesktopViewState extends ConsumerState<InventoryDesktopView> {
  /// 選択中の食材 id（詳細ペイン表示用）。
  String? _selectedId;

  void _openForm({Ingredient? ingredient}) {
    showIngredientFormDialog(context, ingredient: ingredient);
  }

  // ──────────────────────────────────────────────────────
  // 食材を削除する（使い切り・削除ともに同じ処理。Undo あり）
  // ──────────────────────────────────────────────────────
  Future<void> _removeIngredient(Ingredient ing, String toast) async {
    final repo = ref.read(inventoryRepositoryProvider);
    await repo.deleteById(ing.id);
    // 削除した食材が選択中だったら選択解除
    if (_selectedId == ing.id) {
      setState(() => _selectedId = null);
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(toast),
          action: SnackBarAction(
            label: AppLocalizations.of(context).actionUndo,
            textColor: AppColors.greenSoft,
            onPressed: () => repo.save(ing),
          ),
        ));
    }
  }

  // ──────────────────────────────────────────────────────
  // ビルド
  // ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(inventoryListProvider);
    final catFilter = ref.watch(desktopCategoryFilterProvider);
    final searchQuery = ref.watch(desktopSearchQueryProvider);

    return asyncList.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (allItems) {
        // フィルタ適用（カテゴリ + 検索）
        var items = allItems;
        if (catFilter != null) {
          items = items.where((i) => i.category == catFilter).toList();
        }
        if (searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          items = items.where((i) => i.name.toLowerCase().contains(q)).toList();
        }

        // 在庫が完全に0件のとき（フィルタ前）
        if (allItems.isEmpty) {
          return _EmptyState(onAdd: () => _openForm());
        }

        final selectedItem = items
            .where((i) => i.id == _selectedId)
            .cast<Ingredient?>()
            .firstOrNull;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 左: カテゴリフィルタレール ──
            _FilterRail(
              selectedCategory: catFilter,
              onSelect: (cat) => ref
                  .read(desktopCategoryFilterProvider.notifier)
                  .set(cat),
            ),
            // ── 中央: 食材リスト ──
            Expanded(
              child: _ItemList(
                items: items,
                selectedId: _selectedId,
                onSelect: (id) => setState(() => _selectedId = id),
                onEdit: (ing) => _openForm(ingredient: ing),
                onDelete: (ing) => _removeIngredient(
                    ing, AppLocalizations.of(context).toastDeleted),
              ),
            ),
            // ── 右: 詳細ペイン ──
            _DetailPane(
              item: selectedItem,
              onEdit: (ing) => _openForm(ingredient: ing),
              onUsedUp: (ing) => _removeIngredient(
                  ing, AppLocalizations.of(context).toastUsedUp),
              onDelete: (ing) => _removeIngredient(
                  ing, AppLocalizations.of(context).toastDeleted),
              onSuggestMeals: () {
                // TODO(M4): 選択食材をコンテキストとして献立提案に渡す
                ref
                    .read(shellSectionProvider.notifier)
                    .select(ShellSection.meals);
              },
            ),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _FilterRail: 左ペイン（カテゴリフィルタ）
// macosApp.jsx の FilterRow 群 + カテゴリレール
// ──────────────────────────────────────────────────────────────
class _FilterRail extends StatelessWidget {
  const _FilterRail({
    required this.selectedCategory,
    required this.onSelect,
  });

  final IngredientCategory? selectedCategory;
  final ValueChanged<IngredientCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: _kFilterRailWidth,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAF7),
        border: Border(
          right: BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 見出し「カテゴリ」
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(
                l10n.desktopCategoryLabel.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.faint,
                  letterSpacing: 9.5 * 0.08,
                ),
              ),
            ),
            const SizedBox(height: 1),
            // 「すべて」
            _FilterRow(
              label: l10n.filterAll,
              selected: selectedCategory == null,
              onTap: () => onSelect(null),
            ),
            // カテゴリ全種
            for (final cat in IngredientCategory.values)
              _FilterRow(
                label: cat.label(l10n),
                emoji: cat.style.emoji,
                selected: selectedCategory == cat,
                onTap: () => onSelect(cat),
              ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _FilterRow: カテゴリフィルタの1行（macosApp.jsx の FilterRow）
// ──────────────────────────────────────────────────────────────
class _FilterRow extends StatefulWidget {
  const _FilterRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? emoji;

  @override
  State<_FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<_FilterRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    if (widget.selected) {
      bgColor = AppColors.greenSoft;
    } else if (_hovered) {
      bgColor = const Color(0x0D282723);
    } else {
      bgColor = Colors.transparent;
    }
    final textColor = widget.selected ? AppColors.greenInk : AppColors.ink;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          margin: const EdgeInsets.only(bottom: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              // 絵文字またはプレースホルダ
              if (widget.emoji != null)
                Text(
                  widget.emoji!,
                  style: const TextStyle(fontSize: 13),
                )
              else
                const SizedBox(width: 13),
              const SizedBox(width: 7),
              // ラベル
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        widget.selected ? FontWeight.w700 : FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              // 選択時チェックアイコン
              if (widget.selected)
                const Icon(
                  Icons.check,
                  size: 11,
                  color: AppColors.green,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _ItemList: 中央ペイン（食材一覧）
// macosApp.jsx の InventoryScreen 中央カラム
// ──────────────────────────────────────────────────────────────
class _ItemList extends StatelessWidget {
  const _ItemList({
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Ingredient> items;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final void Function(Ingredient) onEdit;
  final void Function(Ingredient) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (items.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 12),
          Text(
            l10n.desktopNoResults,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.faint,
            ),
          ),
        ],
      );
    }

    final now = DateTime.now();
    int? daysOf(Ingredient i) => expiryInfoFor(i.expiryDate, now).daysLeft;

    // グループごとにウィジェットリストを構築する
    final children = <Widget>[];
    for (final group in _DesktopGroup.values) {
      final list =
          items.where((it) => group.test(daysOf(it))).toList();
      if (list.isEmpty) continue;

      // グループ見出し（GroupHead）
      children.add(_GroupHead(
        label: group.title(l10n),
        color: group.headColor,
        count: list.length,
      ));

      // 行（ItemRow）
      for (final item in list) {
        children.add(_ItemRow(
          item: item,
          selected: item.id == selectedId,
          daysLeft: daysOf(item),
          onTap: () => onSelect(item.id),
          onEdit: () => onEdit(item),
          onDelete: () => onDelete(item),
        ));
      }
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      child: ListView(
        children: children,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _GroupHead: 期限グループ見出し（macosApp.jsx の GroupHead）
// ──────────────────────────────────────────────────────────────
class _GroupHead extends StatelessWidget {
  const _GroupHead({
    required this.label,
    required this.color,
    required this.count,
  });

  final String label;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 5),
      color: const Color(0xF5F7F5F0), // rgba(247,245,240,0.96)
      child: Row(
        children: [
          // カラードット
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          // グループ名
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          // 件数
          Text(
            l10n.desktopCountSuffix(count),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.faint,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _ItemRow: 食材の1行（macosApp.jsx の ItemRow）
// ──────────────────────────────────────────────────────────────
class _ItemRow extends StatefulWidget {
  const _ItemRow({
    required this.item,
    required this.selected,
    required this.daysLeft,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Ingredient item;
  final bool selected;
  final int? daysLeft;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = widget.item;

    Color bgColor;
    if (widget.selected) {
      bgColor = const Color(0xFFEDF5F1);
    } else if (_hovered) {
      bgColor = const Color(0x09282723);
    } else {
      bgColor = Colors.transparent;
    }

    final nameColor =
        widget.selected ? AppColors.greenInk : AppColors.ink;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          color: bgColor,
          child: Row(
            children: [
              // カテゴリ色タイル 34px
              CatTile(category: item.category, size: 34),
              const SizedBox(width: 10),
              // 名前 + カテゴリ名
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: nameColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.category.label(l10n),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sub,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // 数量＋単位
              Text(
                '${formatQuantity(item.quantity)}${item.unit}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sub,
                ),
              ),
              const SizedBox(width: 6),
              // 期限チップ
              _ExpiryChip(daysLeft: widget.daysLeft),
              // ホバー or 選択時: 編集・削除ボタン
              if (_hovered || widget.selected) ...[
                const SizedBox(width: 4),
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  danger: false,
                  onTap: () {
                    widget.onEdit();
                  },
                ),
                const SizedBox(width: 2),
                _ActionBtn(
                  icon: Icons.delete_outline,
                  danger: true,
                  onTap: widget.onDelete,
                ),
              ] else
                const SizedBox(width: 56), // 幅を予約してレイアウトを安定させる
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _ExpiryChip: 賞味期限チップ（macosApp.jsx の ExpiryChip）
// ──────────────────────────────────────────────────────────────
class _ExpiryChip extends StatelessWidget {
  const _ExpiryChip({required this.daysLeft});

  final int? daysLeft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String text;
    Color fg;
    Color bg;

    if (daysLeft == null) {
      // 期限なし → plenty 扱い
      text = l10n.expiryNone;
      fg = AppColors.faint;
      bg = AppColors.plentySoft;
    } else if (daysLeft! < 0) {
      text = l10n.desktopExpiryDaysOver(daysLeft!.abs());
      fg = AppColors.over;
      bg = AppColors.overSoft;
    } else if (daysLeft == 0) {
      text = l10n.desktopExpiryToday;
      fg = AppColors.near;
      bg = AppColors.nearSoft;
    } else if (daysLeft! <= 3) {
      text = l10n.desktopExpiryDaysLeft(daysLeft!);
      fg = AppColors.near;
      bg = AppColors.nearSoft;
    } else {
      text = l10n.desktopExpiryDaysLeft(daysLeft!);
      fg = AppColors.faint;
      bg = AppColors.plentySoft;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
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
// _ActionBtn: ホバー時のアクションアイコンボタン（ActionBtn 相当）
// ──────────────────────────────────────────────────────────────
class _ActionBtn extends StatefulWidget {
  const _ActionBtn({
    required this.icon,
    required this.danger,
    required this.onTap,
  });

  final IconData icon;
  final bool danger;
  final VoidCallback onTap;

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hovered
        ? (widget.danger ? AppColors.overSoft : AppColors.greenSoft)
        : Colors.transparent;
    final iconColor = _hovered
        ? (widget.danger ? AppColors.over : AppColors.green)
        : AppColors.sub;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Icon(widget.icon, size: 12, color: iconColor),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _DetailPane: 右ペイン（食材詳細）
// macosApp.jsx の ItemDetail に相当
// ──────────────────────────────────────────────────────────────
class _DetailPane extends StatelessWidget {
  const _DetailPane({
    required this.item,
    required this.onEdit,
    required this.onUsedUp,
    required this.onDelete,
    required this.onSuggestMeals,
  });

  final Ingredient? item;
  final void Function(Ingredient) onEdit;
  final void Function(Ingredient) onUsedUp;
  final void Function(Ingredient) onDelete;
  final VoidCallback onSuggestMeals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (item == null) {
      // 未選択時のプレースホルダ
      return SizedBox(
        width: _kDetailPaneWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🥗', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 10),
            Text(
              l10n.desktopSelectPrompt,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.faint,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.desktopSelectBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.faint,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final ing = item!;
    final tileColor = ing.category.style.tile;
    final now = DateTime.now();
    final info = expiryInfoFor(ing.expiryDate, now);
    final daysLeft = info.daysLeft;

    // 期限テキスト
    String expiryText;
    if (daysLeft == null) {
      expiryText = l10n.expiryNone;
    } else if (daysLeft < 0) {
      expiryText = l10n.desktopExpiryDaysOver(daysLeft.abs());
    } else if (daysLeft == 0) {
      expiryText = l10n.desktopExpiryToday;
    } else {
      expiryText = l10n.desktopExpiryDaysLeft(daysLeft);
    }

    return Container(
      width: _kDetailPaneWidth,
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ヘッダー: カテゴリ色背景 + 60px タイル絵文字 + 名前 + カテゴリ
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            decoration: BoxDecoration(
              // tileColor + alpha 40% (#66)
              color: tileColor.withValues(alpha: 0.4),
              border: const Border(
                bottom: BorderSide(color: AppColors.line, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ing.category.style.emoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ing.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ing.category.label(l10n),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 明細行 + アクションボタン
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 数量
                  _DetailRow(
                    label: l10n.desktopDetailQty,
                    value: '${formatQuantity(ing.quantity)} ${ing.unit}',
                  ),
                  // カテゴリ
                  _DetailRow(
                    label: l10n.desktopDetailCategory,
                    value: ing.category.label(l10n),
                  ),
                  // 賞味期限まで
                  _DetailRow(
                    label: l10n.desktopDetailExpiry,
                    value: expiryText,
                    valueColor: info.badgeColor,
                  ),
                  const SizedBox(height: 18),
                  // アクションボタン縦並び
                  // 「この食材で献立を提案」
                  _DetailActionButton(
                    icon: Icons.auto_awesome_outlined,
                    label: l10n.desktopSuggestWithIngredient,
                    primary: true,
                    onTap: onSuggestMeals,
                  ),
                  const SizedBox(height: 8),
                  // 「使い切りにする」
                  _DetailActionButton(
                    icon: Icons.check_circle_outline,
                    label: l10n.desktopUsedUp,
                    onTap: () => onUsedUp(ing),
                  ),
                  const SizedBox(height: 8),
                  // 「編集」
                  _DetailActionButton(
                    icon: Icons.edit_outlined,
                    label: l10n.editIngredient,
                    onTap: () => onEdit(ing),
                  ),
                  const SizedBox(height: 8),
                  // 「削除」
                  _DetailActionButton(
                    icon: Icons.delete_outline,
                    label: l10n.desktopDelete,
                    danger: true,
                    onTap: () => onDelete(ing),
                  ),
                  const SizedBox(height: 16),
                  // ヒントボックス（嘘の案内を出さないよう「編集ボタン」の案内に変更）
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.desktopEditHint,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greenInk,
                        height: 1.65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _DetailRow: 詳細ペインの1行（ラベル + 値）
// ──────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.sub,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _DetailActionButton: 詳細ペインのアクションボタン
// ──────────────────────────────────────────────────────────────
class _DetailActionButton extends StatefulWidget {
  const _DetailActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool danger;

  @override
  State<_DetailActionButton> createState() => _DetailActionButtonState();
}

class _DetailActionButtonState extends State<_DetailActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color iconColor;
    Border? border;

    if (widget.primary) {
      bgColor = _hovered ? AppColors.greenInk : AppColors.green;
      textColor = Colors.white;
      iconColor = Colors.white;
    } else if (widget.danger) {
      bgColor = _hovered ? AppColors.overSoft : AppColors.card;
      textColor = AppColors.over;
      iconColor = AppColors.over;
      border = Border.all(
        color: _hovered ? AppColors.over : AppColors.overSoft,
        width: 1,
      );
    } else {
      bgColor = _hovered ? AppColors.plentySoft : AppColors.card;
      textColor = AppColors.ink;
      iconColor = AppColors.sub;
      border = Border.all(color: AppColors.line, width: 1);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: border,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 14, color: iconColor),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
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
// _EmptyState: 在庫が完全に 0 件のとき
// ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius: BorderRadius.circular(32),
            ),
            alignment: Alignment.center,
            child: const Text('🧺', style: TextStyle(fontSize: 46)),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyInventoryTitle,
            style: brandTextStyle(fontSize: 21),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emptyInventoryBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.7,
              fontWeight: FontWeight.w500,
              color: AppColors.sub,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onAdd,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.green,
              side: const BorderSide(color: AppColors.green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n.addIngredient),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// InventoryDesktopToolbar: 在庫画面のツールバーコンテンツ
// app_shell.dart の ShellToolbar に組み込む想定。
// SettingsScreen の import を避けるため独立させている。
// ──────────────────────────────────────────────────────────────

/// 在庫セクション専用のツールバーウィジェット。
///
/// [AppShell] の ShellToolbar の代わりに在庫セクション選択時に使用する。
class InventoryDesktopToolbar extends ConsumerStatefulWidget {
  const InventoryDesktopToolbar({super.key});

  @override
  ConsumerState<InventoryDesktopToolbar> createState() =>
      _InventoryDesktopToolbarState();
}

class _InventoryDesktopToolbarState
    extends ConsumerState<InventoryDesktopToolbar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddForm(BuildContext context) {
    showIngredientFormDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // 検索クエリの変化を監視して TextEditingController と同期する
    final searchQuery = ref.watch(desktopSearchQueryProvider);
    if (_searchController.text != searchQuery) {
      _searchController.text = searchQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: searchQuery.length),
      );
    }

    return Row(
      children: [
        // タイトル
        Text(
          l10n.shellNavInventory,
          style: brandTextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 10),
        // 縦区切り
        const SizedBox(
          width: 1,
          height: 18,
          child: ColoredBox(color: AppColors.line),
        ),
        const SizedBox(width: 8),
        // 「+ 食材を追加」ボタン
        _ToolbarBtn(
          icon: Icons.add,
          label: l10n.desktopAddIngredient,
          shortcut: l10n.desktopAddIngredientShortcut,
          primary: false,
          onTap: () => _openAddForm(context),
        ),
        const SizedBox(width: 6),
        // 「カメラ登録」ボタン
        _ToolbarBtn(
          icon: Icons.photo_camera_outlined,
          label: l10n.desktopCameraRegister,
          shortcut: l10n.desktopCameraShortcut,
          primary: false,
          onTap: () => ref
              .read(shellSectionProvider.notifier)
              .select(ShellSection.camera),
        ),
        const SizedBox(width: 6),
        // 縦区切り
        const SizedBox(
          width: 1,
          height: 18,
          child: ColoredBox(color: AppColors.line),
        ),
        const SizedBox(width: 6),
        // 「献立を提案」ボタン（primary）
        _ToolbarBtn(
          icon: Icons.auto_awesome_outlined,
          label: l10n.desktopSuggestMeals,
          shortcut: l10n.desktopSuggestMealsShortcut,
          primary: true,
          onTap: () => ref
              .read(shellSectionProvider.notifier)
              .select(ShellSection.meals),
        ),
        // フレックスで右に寄せる
        const Spacer(),
        // 検索フィールド
        _SearchField(
          controller: _searchController,
          placeholder: l10n.desktopSearchPlaceholder,
          onChanged: (q) =>
              ref.read(desktopSearchQueryProvider.notifier).update(q),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _ToolbarBtn: ツールバー用ボタン（TBtn 相当のインライン版）
// ──────────────────────────────────────────────────────────────
class _ToolbarBtn extends StatefulWidget {
  const _ToolbarBtn({
    required this.label,
    required this.primary,
    required this.onTap,
    this.icon,
    this.shortcut,
  });
  final String label;
  final bool primary;
  final VoidCallback onTap;
  final IconData? icon;
  final String? shortcut;

  @override
  State<_ToolbarBtn> createState() => _ToolbarBtnState();
}

class _ToolbarBtnState extends State<_ToolbarBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.primary
        ? AppColors.green
        : (_hovered ? Colors.white : const Color(0xD1FFFFFF));

    final textColor = widget.primary ? Colors.white : AppColors.ink;
    final iconColor = widget.primary ? Colors.white : AppColors.sub;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(7),
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
                : const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 12, color: iconColor),
                const SizedBox(width: 5),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              if (widget.shortcut != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.primary
                        ? const Color(0x33FFFFFF)
                        : const Color(0x17282723),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.shortcut!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: widget.primary
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.faint,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _SearchField: ツールバー用検索フィールド（MacSearch 相当）
// ──────────────────────────────────────────────────────────────
class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.controller,
    required this.placeholder,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      height: 30,
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: _focused ? Colors.white : const Color(0xB3FFFFFF),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: _focused ? AppColors.green : AppColors.line,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 12, color: AppColors.faint),
          const SizedBox(width: 6),
          Expanded(
            child: Focus(
              onFocusChange: (f) => setState(() => _focused = f),
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.faint,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
