import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../recipe/presentation/meal_suggestion_controller.dart';
import '../../shell/presentation/shell_providers.dart';
import 'shopping_confirm_controller.dart';

// ──────────────────────────────────────────────────────────────
// 定数
// ──────────────────────────────────────────────────────────────
const double _kRightPanelWidth = 340.0;

// ──────────────────────────────────────────────────────────────
// ShoppingDesktopView（メインウィジェット）
// macosApp.jsx の ShoppingScreen を Flutter で再現した 2ペインビュー。
// ──────────────────────────────────────────────────────────────

class ShoppingDesktopView extends ConsumerStatefulWidget {
  const ShoppingDesktopView({super.key});

  @override
  ConsumerState<ShoppingDesktopView> createState() =>
      _ShoppingDesktopViewState();
}

class _ShoppingDesktopViewState extends ConsumerState<ShoppingDesktopView> {
  /// 新規リスト名の入力フィールド用コントローラ。
  final _newListNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ProviderScope が確立された後に initialize を実行する。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(shoppingConfirmControllerProvider.notifier).initialize();
      }
    });
  }

  @override
  void dispose() {
    _newListNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shoppingConfirmControllerProvider);

    // mealsForShoppingProvider の変化を検知して再初期化する。
    // 献立画面から「買い物リストへ」ボタンで遷移した際にリストが更新される。
    ref.listen<List>(mealsForShoppingProvider, (prev, next) {
      if (next.isNotEmpty) {
        ref.read(shoppingConfirmControllerProvider.notifier).initialize();
      }
    });

    return switch (state.phase) {
      ShoppingConfirmPhase.noTarget => _NoTargetView(
          onGoToMeals: () => ref
              .read(shellSectionProvider.notifier)
              .select(ShellSection.meals),
        ),
      ShoppingConfirmPhase.done => _DoneView(
          addedCount: state.addedCount,
          listName: state.selectedListName ?? '',
          onOpenReminders: _openReminders,
          onBackToInventory: () {
            ref
                .read(shoppingConfirmControllerProvider.notifier)
                .resetAfterDone();
            ref
                .read(shellSectionProvider.notifier)
                .select(ShellSection.inventory);
          },
        ),
      _ => _MainView(
          state: state,
          newListNameCtrl: _newListNameCtrl,
        ),
    };
  }

  void _openReminders() {
    // TODO(M6): url_launcher で x-apple-reminderkit:// を試み、
    // 失敗時は何もしない。（現在は url_launcher 未追加のため未実装）
  }
}

// ──────────────────────────────────────────────────────────────
// _MainView: 2ペインメイン（listing / adding / error）
// ──────────────────────────────────────────────────────────────

class _MainView extends ConsumerWidget {
  const _MainView({
    required this.state,
    required this.newListNameCtrl,
  });

  final ShoppingConfirmState state;
  final TextEditingController newListNameCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 左: 不足食材チェックリスト ──
        Expanded(
          child: _ItemListPane(state: state),
        ),
        const VerticalDivider(width: 1, thickness: 1, color: AppColors.line),
        // ── 右: 追加先パネル ──
        SizedBox(
          width: _kRightPanelWidth,
          child: _RightPanel(
            state: state,
            newListNameCtrl: newListNameCtrl,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _ItemListPane: 左ペイン（不足食材一覧）
// ──────────────────────────────────────────────────────────────

class _ItemListPane extends ConsumerWidget {
  const _ItemListPane({required this.state});

  final ShoppingConfirmState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(shoppingConfirmControllerProvider.notifier);

    // adding 中はオーバーレイ。
    if (state.phase == ShoppingConfirmPhase.adding) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      );
    }

    // error 状態。
    if (state.phase == ShoppingConfirmPhase.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_outlined,
                  size: 36, color: AppColors.over),
              const SizedBox(height: 12),
              Text(
                l10n.shoppingErrorNetwork,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sub,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: notifier.retryFromError,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(l10n.shoppingRetry),
              ),
            ],
          ),
        ),
      );
    }

    // listing 状態。
    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🛒', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              Text(
                l10n.shoppingEmptyTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.faint,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.shoppingEmptyBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.faint,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── ヘッダー（件数 + すべて選択/解除） ──
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Text(
                l10n.shoppingMissingCount(state.items.length),
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.faint,
                  letterSpacing: 10.5 * 0.07,
                ),
              ),
              const Spacer(),
              _ToggleAllButton(
                allChecked: state.allChecked,
                onToggle: notifier.toggleAll,
              ),
            ],
          ),
        ),
        // ── 食材リスト ──
        Expanded(
          child: ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _ItemRow(
                item: item,
                onToggle: () => notifier.toggleItem(item.name),
                onIncrement: () => notifier.incrementQty(item.name),
                onDecrement: () => notifier.decrementQty(item.name),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _ToggleAllButton: すべて選択 / すべて解除ボタン
// ──────────────────────────────────────────────────────────────

class _ToggleAllButton extends StatefulWidget {
  const _ToggleAllButton({
    required this.allChecked,
    required this.onToggle,
  });

  final bool allChecked;
  final VoidCallback onToggle;

  @override
  State<_ToggleAllButton> createState() => _ToggleAllButtonState();
}

class _ToggleAllButtonState extends State<_ToggleAllButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0x0D282723)
                : Colors.white,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.allChecked ? l10n.shoppingDeselectAll : l10n.shoppingSelectAll,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _ItemRow: 食材 1 行（チェック・カテゴリタイル・名前・献立タグ・ステッパー）
// ──────────────────────────────────────────────────────────────

class _ItemRow extends StatefulWidget {
  const _ItemRow({
    required this.item,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
  });

  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 80),
        opacity: item.checked ? 1.0 : 0.55,
        child: Container(
          color: _hovered ? const Color(0x09282723) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // チェックボックス
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: item.checked,
                  onChanged: (_) => widget.onToggle(),
                  activeColor: AppColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(color: AppColors.line, width: 1.5),
                ),
              ),
              const SizedBox(width: 10),
              // カテゴリタイル（34×34、緑ソフト背景）
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.plentySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text('🛒', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              // 名前 + 由来献立
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    if (item.sourceNames.isNotEmpty)
                      Text(
                        l10n.shoppingForLabel(item.sourceNames.first),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sub,
                        ),
                      ),
                  ],
                ),
              ),
              // 数量ステッパー（plentySoft 背景・±ボタン）
              _QtyStepperWidget(
                qty: item.qty,
                onIncrement: widget.onIncrement,
                onDecrement: widget.onDecrement,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _QtyStepperWidget: 数量 ± ステッパー
// ──────────────────────────────────────────────────────────────

class _QtyStepperWidget extends StatelessWidget {
  const _QtyStepperWidget({
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.plentySoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onTap: onDecrement,
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$qty個',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatefulWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 28,
          height: 30,
          child: Icon(
            widget.icon,
            size: 12,
            color: _hovered ? AppColors.greenInk : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _RightPanel: 右パネル（追加先リスト選択 + 追加ボタン）
// ──────────────────────────────────────────────────────────────

class _RightPanel extends ConsumerStatefulWidget {
  const _RightPanel({
    required this.state,
    required this.newListNameCtrl,
  });

  final ShoppingConfirmState state;
  final TextEditingController newListNameCtrl;

  @override
  ConsumerState<_RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends ConsumerState<_RightPanel> {
  bool _showNewListField = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final st = widget.state;
    final notifier = ref.read(shoppingConfirmControllerProvider.notifier);
    final checkedCount = st.checkedItems.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 見出し
          Text(
            l10n.shoppingRightPanelTitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.faint,
              letterSpacing: 12 * 0.07,
            ),
          ),
          const SizedBox(height: 16),
          // 白カード: アプリ名 + リスト一覧
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // アプリ表示行
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.greenSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.checklist,
                            size: 17, color: AppColors.green),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.shoppingAppLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.faint,
                            ),
                          ),
                          Text(
                            l10n.shoppingRemindersApp,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.line),
                // リスト一覧（エラー / 読み込み中 / 一覧）
                if (st.listsError != null)
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      l10n.shoppingListLoadError,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.over,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (st.listsLoading && st.availableLists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  )
                else
                  ...st.availableLists.asMap().entries.map((entry) {
                    final i = entry.key;
                    final list = entry.value;
                    final selected = st.selectedListId == list.id;
                    return _ListRadioRow(
                      list: list,
                      selected: selected,
                      isLast: i == st.availableLists.length - 1,
                      onTap: () => notifier.selectList(list.id, list.name),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // 「リストを読み込む」ボタン
          _TextLinkButton(
            icon: Icons.refresh,
            label: st.listsLoading
                ? l10n.shoppingLoadingLists
                : l10n.shoppingLoadLists,
            onTap: st.listsLoading ? null : notifier.loadLists,
          ),
          const SizedBox(height: 4),
          // 新規リスト作成トグル
          _TextLinkButton(
            icon: Icons.add,
            label: l10n.shoppingNewListName,
            onTap: () => setState(() => _showNewListField = !_showNewListField),
          ),
          // 新規リスト名入力フィールド
          if (_showNewListField) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: widget.newListNameCtrl,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        hintText: l10n.shoppingNewListName,
                        hintStyle: const TextStyle(
                            color: AppColors.faint,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _PrimarySmallButton(
                  label: l10n.shoppingCreateList,
                  onTap: () {
                    notifier.createList(widget.newListNameCtrl.text);
                    widget.newListNameCtrl.clear();
                    setState(() => _showNewListField = false);
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          // 追加ボタン
          _AddButton(
            listName: st.selectedListName,
            count: checkedCount,
            disabled: checkedCount == 0 || st.selectedListId == null,
            onTap: ref.read(shoppingConfirmControllerProvider.notifier).addItems,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _ListRadioRow: リスト選択ラジオ行
// ──────────────────────────────────────────────────────────────

class _ListRadioRow extends StatefulWidget {
  const _ListRadioRow({
    required this.list,
    required this.selected,
    required this.isLast,
    required this.onTap,
  });

  final dynamic list; // ShoppingList
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;

  @override
  State<_ListRadioRow> createState() => _ListRadioRowState();
}

class _ListRadioRowState extends State<_ListRadioRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? AppColors.greenSoft
                : (_hovered ? const Color(0x06282723) : Colors.transparent),
            border: widget.isLast
                ? null
                : const Border(
                    bottom:
                        BorderSide(color: AppColors.line, width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              // ラジオドット
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.green : Colors.white,
                  border: selected
                      ? null
                      : Border.all(color: AppColors.line, width: 2),
                ),
                alignment: Alignment.center,
                child: selected
                    ? const Icon(Icons.check,
                        size: 10, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                widget.list.name as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
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
// _AddButton: primary 追加ボタン
// ──────────────────────────────────────────────────────────────

class _AddButton extends StatefulWidget {
  const _AddButton({
    required this.listName,
    required this.count,
    required this.disabled,
    required this.onTap,
  });

  final String? listName;
  final int count;
  final bool disabled;
  final VoidCallback onTap;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final disabled = widget.disabled;
    final label = widget.listName != null
        ? l10n.shoppingAddButton(widget.listName!, widget.count)
        : l10n.shoppingAddButtonNoList;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor:
          disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: disabled ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: disabled
                ? AppColors.faint
                : (_hovered ? AppColors.greenInk : AppColors.green),
            borderRadius: BorderRadius.circular(10),
            boxShadow: disabled
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x381F7A55),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _TextLinkButton: テキストリンク（ロード / 作成 などの導線）
// ──────────────────────────────────────────────────────────────

class _TextLinkButton extends StatefulWidget {
  const _TextLinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_TextLinkButton> createState() => _TextLinkButtonState();
}

class _TextLinkButtonState extends State<_TextLinkButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor:
          enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          children: [
            Icon(widget.icon,
                size: 13,
                color: _hovered && enabled
                    ? AppColors.greenInk
                    : AppColors.sub),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _hovered && enabled
                    ? AppColors.greenInk
                    : AppColors.sub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _PrimarySmallButton: 小さい primary ボタン（リスト作成）
// ──────────────────────────────────────────────────────────────

class _PrimarySmallButton extends StatefulWidget {
  const _PrimarySmallButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_PrimarySmallButton> createState() => _PrimarySmallButtonState();
}

class _PrimarySmallButtonState extends State<_PrimarySmallButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.greenInk : AppColors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _NoTargetView: 対象なし状態（「献立提案へ」ボタン）
// ──────────────────────────────────────────────────────────────

class _NoTargetView extends StatelessWidget {
  const _NoTargetView({required this.onGoToMeals});

  final VoidCallback onGoToMeals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 14),
            Text(
              l10n.shoppingEmptyBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.faint,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _GoToMealsButton(onTap: onGoToMeals),
          ],
        ),
      ),
    );
  }
}

class _GoToMealsButton extends StatefulWidget {
  const _GoToMealsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_GoToMealsButton> createState() => _GoToMealsButtonState();
}

class _GoToMealsButtonState extends State<_GoToMealsButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.greenInk : AppColors.green,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x381F7A55),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_outlined,
                  size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                l10n.shoppingGoToMeals,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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
// _DoneView: 完了状態（大チェック + 件数 + 戻るボタン）
// ──────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  const _DoneView({
    required this.addedCount,
    required this.listName,
    required this.onOpenReminders,
    required this.onBackToInventory,
  });

  final int addedCount;
  final String listName;
  final VoidCallback onOpenReminders;
  final VoidCallback onBackToInventory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 緑チェックアイコン（80px）
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4C1F7A55),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.shoppingDoneTitle(addedCount),
              style: brandTextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.shoppingDoneBody(listName),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.sub,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 「リマインダーを開く」secondary
                _DoneButton(
                  icon: Icons.open_in_new,
                  label: l10n.shoppingOpenReminders,
                  primary: false,
                  onTap: onOpenReminders,
                ),
                const SizedBox(width: 12),
                // 「在庫に戻る」primary
                _DoneButton(
                  icon: Icons.check,
                  label: l10n.shoppingBackToInventory,
                  primary: true,
                  onTap: onBackToInventory,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneButton extends StatefulWidget {
  const _DoneButton({
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
  State<_DoneButton> createState() => _DoneButtonState();
}

class _DoneButtonState extends State<_DoneButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (widget.primary) {
      bg = _hovered ? AppColors.greenInk : AppColors.green;
      fg = Colors.white;
    } else {
      bg = _hovered ? AppColors.line : Colors.white;
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: widget.primary ? null : Border.all(color: AppColors.line),
            boxShadow: widget.primary
                ? const [
                    BoxShadow(
                      color: Color(0x381F7A55),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: fg),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
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
