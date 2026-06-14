import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../camera/presentation/camera_mobile_view.dart';
import '../../recipe/presentation/meals_mobile_view.dart';
import '../../settings/presentation/settings_screen.dart';
import '../domain/ingredient_category.dart';
import 'expiry_status.dart';
import 'ingredient_form_screen.dart';
import 'inventory_providers.dart';
import 'widgets/ingredient_detail_view.dart';
import 'widgets/swipe_row.dart';

/// 二ペイン表示に切り替える画面幅のしきい値。
const double _tabletBreakpoint = 720;

/// 期限グルーピングの定義（Claude Design 案B）。
enum _Group { now, week, plenty, none }

extension on _Group {
  String title(AppLocalizations l10n) => switch (this) {
        _Group.now => l10n.groupNow,
        _Group.week => l10n.groupWeek,
        _Group.plenty => l10n.groupPlenty,
        _Group.none => l10n.groupNoDate,
      };

  Color get tone => switch (this) {
        _Group.now => AppColors.near,
        _Group.week => AppColors.green,
        _Group.plenty => AppColors.plenty,
        _Group.none => AppColors.faint,
      };

  bool test(int? daysLeft) => switch (this) {
        _Group.now => daysLeft != null && daysLeft <= 3,
        _Group.week => daysLeft != null && daysLeft >= 4 && daysLeft <= 9,
        _Group.plenty => daysLeft != null && daysLeft >= 10,
        _Group.none => daysLeft == null,
      };
}

class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() =>
      _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  /// スワイプで開いている行の id（同時に1つだけ）。
  String? _openId;

  /// 検索欄を開いているか。
  bool _searching = false;

  /// 検索クエリ（名前の部分一致・大文字小文字無視）。
  String _query = '';

  void _openSearch() => setState(() {
        _searching = true;
        _query = '';
      });

  void _closeSearch() => setState(() {
        _searching = false;
        _query = '';
      });

  void _openForm({Ingredient? ingredient}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => IngredientFormScreen(ingredient: ingredient),
    ));
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  void _openMeals() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MealsMobileScreen()),
    );
  }

  void _openCamera() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CameraMobileScreen()),
    );
  }

  void _openDetailNarrow(Ingredient ingredient) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _DetailNavBar(title: ingredient.name),
              Expanded(
                child: IngredientDetailView(
                  ingredientId: ingredient.id,
                  onGone: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ));
    // 詳細を開いたらスワイプを閉じる
    setState(() => _openId = null);
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(inventoryListProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: asyncList.when(
          loading: () => Column(
            children: [
              const _Header(count: null),
              const _CategoryChips(),
              const Expanded(child: _LoadingList()),
            ],
          ),
          error: (e, _) => Center(child: Text('$e')),
          data: (items) {
            if (items.isEmpty &&
                ref.watch(categoryFilterProvider) == null &&
                !_searching) {
              return _EmptyState(
                onCamera: _openCamera,
                onManual: () => _openForm(),
                onSettings: _openSettings,
              );
            }
            // 検索クエリで名前を絞り込む（デスクトップと同じ部分一致）。
            final q = _query.trim().toLowerCase();
            final filtered = q.isEmpty
                ? items
                : items
                    .where((i) => i.name.toLowerCase().contains(q))
                    .toList();
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= _tabletBreakpoint;
                if (!isWide) return _narrow(filtered);
                return _wide(filtered);
              },
            );
          },
        ),
      ),
    );
  }

  /// 検索中で一致がないとき専用メッセージ、それ以外は通常の一覧。
  Widget _listOrSearchEmpty(List<Ingredient> items,
      {bool selectable = false, String? selectedId, void Function(Ingredient)? onTap}) {
    if (_searching && _query.trim().isNotEmpty && items.isEmpty) {
      return _SearchEmpty(query: _query.trim());
    }
    return _GroupedList(
      items: items,
      openId: _openId,
      selectable: selectable,
      selectedId: selectedId,
      onOpenChanged: (id) => setState(() => _openId = id),
      onTap: onTap ?? _openDetailNarrow,
    );
  }

  Widget _narrow(List<Ingredient> items) {
    return Column(
      children: [
        _Header(
          count: items.length,
          onSettings: _openSettings,
          // 検索中はヘッダーの検索アイコンを隠す（再タップでクエリが消えるのを防ぐ）。
          onSearch: _searching ? null : _openSearch,
          onAdd: () => _openForm(),
        ),
        if (_searching)
          _SearchField(
            initial: _query,
            onChanged: (q) => setState(() => _query = q),
            onClose: _closeSearch,
          ),
        const _CategoryChips(),
        Expanded(child: _listOrSearchEmpty(items)),
        _BottomActions(
          onSuggest: _openMeals,
          onCamera: _openCamera,
        ),
      ],
    );
  }

  Widget _wide(List<Ingredient> items) {
    final selectedId = ref.watch(selectedIngredientIdProvider);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _Header(
                count: items.length,
                onSettings: _openSettings,
                // 検索中はヘッダーの検索アイコンを隠す。
                onSearch: _searching ? null : _openSearch,
                onAdd: () => _openForm(),
              ),
              if (_searching)
                _SearchField(
                  initial: _query,
                  onChanged: (q) => setState(() => _query = q),
                  onClose: _closeSearch,
                ),
              const _CategoryChips(),
              Expanded(
                child: _listOrSearchEmpty(
                  items,
                  selectable: true,
                  selectedId: selectedId,
                  onTap: (ing) => ref
                      .read(selectedIngredientIdProvider.notifier)
                      .set(ing.id),
                ),
              ),
              _BottomActions(onSuggest: _openMeals, onCamera: _openCamera),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: _DetailPane(items: items)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ヘッダー（日付＋在庫＋件数＋操作アイコン）
// ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    this.onSettings,
    this.onSearch,
    this.onAdd,
  });

  final int? count;
  final VoidCallback? onSettings;
  final VoidCallback? onSearch;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.MMMEd(locale).format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateLabel,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sub)),
                    const SizedBox(height: 2),
                    Text(l10n.inventoryTitle,
                        style: brandTextStyle(fontSize: 28, height: 1)),
                  ],
                ),
              ),
              if (onSearch != null)
                _HeaderBtn(icon: Icons.search, onTap: onSearch!),
              if (onSettings != null) ...[
                const SizedBox(width: 9),
                _HeaderBtn(icon: Icons.settings_outlined, onTap: onSettings!),
              ],
              if (onAdd != null) ...[
                const SizedBox(width: 9),
                _HeaderBtn(icon: Icons.add, onTap: onAdd!),
              ],
            ],
          ),
          if (count != null) ...[
            const SizedBox(height: 6),
            Text(l10n.inventoryCountLine(count!),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sub)),
          ],
        ],
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
          child: Icon(icon, size: 21, color: AppColors.ink),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 検索欄（モバイル）
// ─────────────────────────────────────────────────────────────
class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.initial,
    required this.onChanged,
    required this.onClose,
  });

  final String initial;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: l10n.inventorySearchHint,
                prefixIcon: const Icon(Icons.search,
                    size: 20, color: AppColors.sub),
                isDense: true,
                filled: true,
                fillColor: AppColors.card,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.line, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.line, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          _HeaderBtn(icon: Icons.close, onTap: widget.onClose),
        ],
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          l10n.inventorySearchEmpty(query),
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.faint, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _DetailNavBar extends StatelessWidget {
  const _DetailNavBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      child: Row(
        children: [
          _HeaderBtn(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.of(context).pop()),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: brandTextStyle(fontSize: 21)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// カテゴリチップ（すべて＋12種）
// ─────────────────────────────────────────────────────────────
class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(categoryFilterProvider);

    Widget chip(String label, bool on, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Material(
          color: on ? AppColors.green : AppColors.card,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: on
                    ? null
                    : Border.all(color: AppColors.line, width: 1),
              ),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: on ? FontWeight.w700 : FontWeight.w600,
                      color: on ? Colors.white : AppColors.sub)),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          chip(l10n.filterAll, selected == null,
              () => ref.read(categoryFilterProvider.notifier).set(null)),
          for (final c in IngredientCategory.values)
            chip(c.label(l10n), selected == c,
                () => ref.read(categoryFilterProvider.notifier).set(c)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// グルーピング一覧
// ─────────────────────────────────────────────────────────────
class _GroupedList extends StatelessWidget {
  const _GroupedList({
    required this.items,
    required this.openId,
    required this.onOpenChanged,
    required this.onTap,
    this.selectable = false,
    this.selectedId,
  });

  final List<Ingredient> items;
  final String? openId;
  final ValueChanged<String?> onOpenChanged;
  final void Function(Ingredient) onTap;
  final bool selectable;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(l10n.emptyInventory,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.faint, fontWeight: FontWeight.w600)),
        ),
      );
    }
    final now = DateTime.now();
    int? daysOf(Ingredient i) => expiryInfoFor(i.expiryDate, now).daysLeft;

    final children = <Widget>[];
    for (final g in _Group.values) {
      final list = items.where((it) => g.test(daysOf(it))).toList();
      if (list.isEmpty) continue;
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 9),
        child: Row(
          children: [
            Container(
                width: 9,
                height: 9,
                decoration:
                    BoxDecoration(color: g.tone, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(g.title(l10n),
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink)),
            const SizedBox(width: 8),
            Text('${list.length}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.faint)),
          ],
        ),
      ));
      for (final it in list) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: selectable && it.id == selectedId
              ? _SelectedWrap(
                  child: SwipeRow(
                    ingredient: it,
                    isOpen: openId == it.id,
                    onOpenChanged: (open) => onOpenChanged(open ? it.id : null),
                    onTap: () => onTap(it),
                    onUsedUp: () => _remove(context, it, l10n.toastUsedUp),
                    onDelete: () => _remove(context, it, l10n.toastDeleted),
                  ),
                )
              : SwipeRow(
                  ingredient: it,
                  isOpen: openId == it.id,
                  onOpenChanged: (open) => onOpenChanged(open ? it.id : null),
                  onTap: () => onTap(it),
                  onUsedUp: () => _remove(context, it, l10n.toastUsedUp),
                  onDelete: () => _remove(context, it, l10n.toastDeleted),
                ),
        ));
      }
      children.add(const SizedBox(height: 11));
    }
    children.add(Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      child: Text(l10n.swipeHint,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.faint)),
    ));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      children: children,
    );
  }
}

class _SelectedWrap extends StatelessWidget {
  const _SelectedWrap({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green, width: 2),
      ),
      child: child,
    );
  }
}

void _remove(BuildContext context, Ingredient item, String toast) {
  // 一覧側のスワイプ操作。詳細と同じく「元に戻す」で取り消せる。
  final container = ProviderScope.containerOf(context, listen: false);
  final l10n = AppLocalizations.of(context);
  final repo = container.read(inventoryRepositoryProvider);
  repo.deleteById(item.id);
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(toast),
      action: SnackBarAction(
        label: l10n.actionUndo,
        textColor: AppColors.greenSoft,
        onPressed: () => repo.save(item),
      ),
    ));
}

// ─────────────────────────────────────────────────────────────
// 右ペイン（広い画面）
// ─────────────────────────────────────────────────────────────
class _DetailPane extends ConsumerWidget {
  const _DetailPane({required this.items});
  final List<Ingredient> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedId = ref.watch(selectedIngredientIdProvider);
    final exists = items.any((e) => e.id == selectedId);

    if (selectedId == null || !exists) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.line, width: 1.5),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    size: 40, color: AppColors.faint),
              ),
              const SizedBox(height: 14),
              Text(l10n.selectIngredientPrompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.sub, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }
    return SafeArea(
      child: IngredientDetailView(
        ingredientId: selectedId,
        onGone: () =>
            ref.read(selectedIngredientIdProvider.notifier).set(null),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 下部アクション（献立提案バー＋カメラFAB）
// ─────────────────────────────────────────────────────────────
class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onSuggest, required this.onCamera});
  final VoidCallback onSuggest;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onSuggest,
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.suggestRecipes,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2)),
                            Text(l10n.suggestRecipesSub,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white
                                        .withValues(alpha: 0.82))),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onCamera,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.greenSoft, width: 1.5),
                ),
                child: const Icon(Icons.photo_camera_outlined,
                    color: AppColors.green, size: 27),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 空の状態
// ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onCamera,
    required this.onManual,
    required this.onSettings,
  });
  final VoidCallback onCamera;
  final VoidCallback onManual;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 14, 4),
          child: Row(
            children: [
              Expanded(
                  child: Text(l10n.inventoryTitle,
                      style: brandTextStyle(fontSize: 28))),
              _HeaderBtn(icon: Icons.settings_outlined, onTap: onSettings),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                  Text(l10n.emptyInventoryTitle,
                      style: brandTextStyle(fontSize: 21)),
                  const SizedBox(height: 8),
                  Text(l10n.emptyInventoryBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                          color: AppColors.sub)),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              FilledButton.icon(
                onPressed: onCamera,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.cameraRegister,
                    style: const TextStyle(
                        fontSize: 16.5, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onManual,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  backgroundColor: AppColors.card,
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: AppColors.line, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.manualAdd,
                    style: const TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 読み込み中スケルトン
// ─────────────────────────────────────────────────────────────
class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _skel(52, 52, 16),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _skel(140, 14, 7),
                  const SizedBox(height: 8),
                  _skel(90, 11, 7),
                ],
              ),
            ),
            _skel(58, 26, 999),
          ],
        ),
      ),
    );
  }

  Widget _skel(double w, double h, double r) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: AppColors.plentySoft,
          borderRadius: BorderRadius.circular(r),
        ),
      );
}
