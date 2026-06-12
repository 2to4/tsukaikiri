import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mobile_nav_buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/shopping_list.dart';
import 'shopping_confirm_controller.dart';

// ──────────────────────────────────────────────────────────────
// ShoppingMobileScreen（モバイル＝狭い幅の買い物リスト確認画面）
//
// shoppingPhone.jsx を Flutter で再現した全画面（Navigator.push で開く）。
// 状態はすべて [shoppingConfirmControllerProvider] を再利用し、この view は
// 表示とイベント転送のみを行う（ロジックの複製は禁止）。
//
// フェーズ（ShoppingConfirmPhase）:
//   listing（不足食材 + 追加先選択）→ adding（送信中）→ done / error
//   noTarget は献立画面からの遷移では発生しない想定だが念のため扱う。
// ──────────────────────────────────────────────────────────────
class ShoppingMobileScreen extends ConsumerStatefulWidget {
  const ShoppingMobileScreen({super.key});

  @override
  ConsumerState<ShoppingMobileScreen> createState() =>
      _ShoppingMobileScreenState();
}

class _ShoppingMobileScreenState extends ConsumerState<ShoppingMobileScreen> {
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
  Widget build(BuildContext context) {
    final st = ref.watch(shoppingConfirmControllerProvider);

    // 入場時の初期化は initState の postFrameCallback で行う。
    // mealsForShoppingProvider への set() は常にこの画面の push 前に完了している
    // （この画面の生存中に変化することはない）ため、listen による再初期化は不要。

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: switch (st.phase) {
          ShoppingConfirmPhase.adding => _AddingView(state: st),
          ShoppingConfirmPhase.done => _DoneView(state: st),
          ShoppingConfirmPhase.error => const _ErrorView(),
          // noTarget / listing は一覧画面を出す（noTarget は空表示になる）。
          _ => _ListView(state: st),
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 共通ヘルパー
// ──────────────────────────────────────────────────────────────

/// 在庫（ルート）に戻る。push したルートを全て pop して最初の画面まで戻す。
void _popToRoot(BuildContext context) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}


// ──────────────────────────────────────────────────────────────
// 1. 一覧（不足食材チェック + 追加先選択 + 追加ボタン）
// ──────────────────────────────────────────────────────────────
class _ListView extends ConsumerWidget {
  const _ListView({required this.state});
  final ShoppingConfirmState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(shoppingConfirmControllerProvider.notifier);
    final chosen = state.checkedItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── ヘッダー（戻る + タイトル） ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const MobileNavBackButton(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.shoppingMobileTitle,
                        style: brandTextStyle(fontSize: 22, height: 1.1)),
                    const SizedBox(height: 2),
                    Text(l10n.shoppingMobileSubtitle,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sub)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── 件数サマリー + すべて選択/解除 ──
        if (state.items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.shoppingMobileSummary(state.items.length, chosen),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.sub),
                  ),
                ),
                _ToggleAllButton(
                  allChecked: state.allChecked,
                  onTap: notifier.toggleAll,
                ),
              ],
            ),
          ),
        // ── 不足食材リスト ──
        Expanded(
          child: state.items.isEmpty
              ? _EmptyList()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (_, i) {
                    final item = state.items[i];
                    return _ItemRow(
                      item: item,
                      onToggle: () => notifier.toggleItem(item.name),
                      onIncrement: () => notifier.incrementQty(item.name),
                      onDecrement: () => notifier.decrementQty(item.name),
                    );
                  },
                ),
        ),
        // ── 追加先 + 追加ボタン ──
        if (state.items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DestCard(state: state),
                const SizedBox(height: 12),
                _AddButton(
                  listName: state.selectedListName,
                  count: chosen,
                  disabled: chosen == 0 || state.selectedListId == null,
                  onTap: notifier.addItems,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// 不足食材なし（または対象なし）の空表示。
class _EmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 40)),
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
          ],
        ),
      ),
    );
  }
}

/// すべて選択 / 解除 ピル。
class _ToggleAllButton extends StatelessWidget {
  const _ToggleAllButton({required this.allChecked, required this.onTap});
  final bool allChecked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
          child: Text(
            allChecked ? l10n.shoppingDeselectAll : l10n.shoppingSelectAll,
            style: const TextStyle(
              fontSize: 12.5,
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
// 不足食材 1 行（チェック・名前・由来献立・数量ステッパー）
// ──────────────────────────────────────────────────────────────
class _ItemRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final off = !item.checked;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: off ? 0.7 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: off ? const Color(0xFFFBFAF7) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A282723), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: Row(
          children: [
            _Check(on: item.checked, onTap: onToggle),
            const SizedBox(width: 12),
            // カテゴリタイル
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.plentySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text('🛒', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            // 名前 + 由来献立
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.2),
                  ),
                  if (item.sourceNames.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n.shoppingForLabel(item.sourceNames.first),
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.faint),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 数量ステッパー
            _QtyStepper(
              qty: item.qty,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ],
        ),
      ),
    );
  }
}

/// 緑チェックボタン。
class _Check extends StatelessWidget {
  const _Check({required this.on, required this.onTap});
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: on ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: on ? null : Border.all(color: AppColors.line, width: 2),
        ),
        alignment: Alignment.center,
        child: on
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

/// 数量 ± ステッパー。
class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
  });
  final int qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.plentySoft,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(icon: Icons.remove, onTap: onDecrement),
          SizedBox(
            width: 44,
            child: Text(
              l10n.shoppingQtyUnit(qty),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink),
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 34,
        height: 36,
        child: Icon(icon, size: 16, color: AppColors.ink),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 追加先カード（タップで展開してリスト選択 / 新規作成）
// ──────────────────────────────────────────────────────────────
class _DestCard extends ConsumerStatefulWidget {
  const _DestCard({required this.state});
  final ShoppingConfirmState state;

  @override
  ConsumerState<_DestCard> createState() => _DestCardState();
}

class _DestCardState extends ConsumerState<_DestCard> {
  bool _open = false;
  bool _showNewField = false;
  final _newListCtrl = TextEditingController();

  @override
  void dispose() {
    _newListCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final st = widget.state;
    final notifier = ref.read(shoppingConfirmControllerProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A282723), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── ヘッダー行（追加先 + 変更トグル） ──
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.checklist,
                        size: 21, color: AppColors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.shoppingDest,
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.faint)),
                        const SizedBox(height: 1),
                        Text(
                          st.selectedListName ?? l10n.shoppingAddButtonNoList,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink),
                        ),
                      ],
                    ),
                  ),
                  Text(l10n.shoppingChange,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sub)),
                  AnimatedRotation(
                    turns: _open ? 0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: const Icon(Icons.chevron_right,
                        size: 18, color: AppColors.sub),
                  ),
                ],
              ),
            ),
          ),
          // ── 展開部（リスト選択 + ロード + 新規作成） ──
          if (_open) ...[
            const Divider(height: 1, thickness: 1, color: AppColors.line),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (st.listsError != null)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        l10n.shoppingListLoadError,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.over),
                      ),
                    )
                  else if (st.listsLoading && st.availableLists.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.green),
                        ),
                      ),
                    )
                  else
                    for (final list in st.availableLists)
                      _DestRadioRow(
                        list: list,
                        selected: st.selectedListId == list.id,
                        onTap: () {
                          notifier.selectList(list.id, list.name);
                          setState(() => _open = false);
                        },
                      ),
                  // リスト再読み込み
                  _TextLink(
                    icon: Icons.refresh,
                    label: st.listsLoading
                        ? l10n.shoppingLoadingLists
                        : l10n.shoppingLoadLists,
                    onTap: st.listsLoading ? null : notifier.loadLists,
                  ),
                  // 新規リスト作成
                  _TextLink(
                    icon: Icons.add,
                    label: l10n.shoppingNewListName,
                    onTap: () =>
                        setState(() => _showNewField = !_showNewField),
                  ),
                  if (_showNewField)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.line),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: _newListCtrl,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  hintText: l10n.shoppingNewListName,
                                  hintStyle: const TextStyle(
                                      color: AppColors.faint,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              notifier.createList(_newListCtrl.text);
                              _newListCtrl.clear();
                              setState(() {
                                _showNewField = false;
                                _open = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                l10n.shoppingCreateList,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
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

/// 追加先リスト選択行（ラジオ）。
class _DestRadioRow extends StatelessWidget {
  const _DestRadioRow({
    required this.list,
    required this.selected,
    required this.onTap,
  });
  final ShoppingList list;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.greenSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.green : Colors.white,
                  border: selected
                      ? null
                      : Border.all(color: AppColors.line, width: 2),
                ),
                alignment: Alignment.center,
                child: selected
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  list.name,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// テキストリンク（ロード / 新規作成導線）。
class _TextLink extends StatelessWidget {
  const _TextLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = enabled ? AppColors.sub : AppColors.faint;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// primary 追加ボタン。
class _AddButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = listName != null
        ? l10n.shoppingAddButton(listName!, count)
        : l10n.shoppingAddButtonNoList;

    return Material(
      color: disabled ? const Color(0xFFD8D4CB) : AppColors.green,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: disabled ? null : onTap,
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.checklist, color: Colors.white, size: 21),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
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
// 2. 追加中（パルスアイコン + 進捗）
// ──────────────────────────────────────────────────────────────
class _AddingView extends StatefulWidget {
  const _AddingView({required this.state});
  final ShoppingConfirmState state;

  @override
  State<_AddingView> createState() => _AddingViewState();
}

class _AddingViewState extends State<_AddingView>
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
    final st = widget.state;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
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
                child: const Icon(Icons.checklist,
                    size: 40, color: AppColors.green),
              ),
            ),
            const SizedBox(height: 18),
            Text(l10n.shoppingAdding, style: brandTextStyle(fontSize: 21)),
            const SizedBox(height: 8),
            Text(
              l10n.shoppingAddingDetail(
                  st.selectedListName ?? '', st.checkedItems.length),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sub),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 3. 完了（大チェック + 件数 + 在庫にもどる）
// ──────────────────────────────────────────────────────────────
class _DoneView extends ConsumerWidget {
  const _DoneView({required this.state});
  final ShoppingConfirmState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x521F7A55),
                            blurRadius: 30,
                            offset: Offset(0, 14)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.check, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  Text(l10n.shoppingDoneTitle(state.addedCount),
                      style: brandTextStyle(fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(
                    l10n.shoppingDoneBody(state.selectedListName ?? ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
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
          child: _PrimaryWideButton(
            icon: Icons.check,
            label: l10n.shoppingBackToInventory,
            onTap: () {
              ref
                  .read(shoppingConfirmControllerProvider.notifier)
                  .resetAfterDone();
              _popToRoot(context);
            },
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 4. エラー（メッセージ + もう一度試す / もどる）
// ──────────────────────────────────────────────────────────────
class _ErrorView extends ConsumerWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(shoppingConfirmControllerProvider.notifier);

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
                    child: const Icon(Icons.error_outline,
                        size: 44, color: AppColors.near),
                  ),
                  const SizedBox(height: 18),
                  Text(l10n.shoppingErrorTitle,
                      textAlign: TextAlign.center,
                      style: brandTextStyle(fontSize: 21)),
                  const SizedBox(height: 10),
                  Text(
                    l10n.shoppingErrorNetwork,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.sub,
                        height: 1.7),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.shoppingErrorRetainNotice,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.faint),
                    ),
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
              _PrimaryWideButton(
                icon: Icons.refresh,
                label: l10n.shoppingTryAgain,
                onTap: notifier.retryFromError,
              ),
              const SizedBox(height: 12),
              // 「もどる」は買い物フローから離脱する（エラー状態は解除して
              // 次回入場時に listing から始められるようにする）。
              _SecondaryWideButton(
                label: l10n.shoppingBack,
                onTap: () {
                  notifier.retryFromError();
                  Navigator.of(context).maybePop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 共通ワイドボタン
// ──────────────────────────────────────────────────────────────
class _PrimaryWideButton extends StatelessWidget {
  const _PrimaryWideButton({
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
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 21),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryWideButton extends StatelessWidget {
  const _SecondaryWideButton({required this.label, required this.onTap});
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
