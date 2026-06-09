import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/unit_option.dart';
import '../expiry_status.dart';
import 'cat_tile.dart';
import 'expiry_badge.dart';

/// 左スワイプでクイック操作（使い切った／削除）を出す在庫一覧の行。
///
/// タップで詳細へ。開閉状態は親が [isOpen]/[onOpenChanged] で一意に管理する
/// （同時に複数行が開かないように）。
class SwipeRow extends StatefulWidget {
  const SwipeRow({
    super.key,
    required this.ingredient,
    required this.isOpen,
    required this.onOpenChanged,
    required this.onTap,
    required this.onUsedUp,
    required this.onDelete,
  });

  final Ingredient ingredient;
  final bool isOpen;
  final ValueChanged<bool> onOpenChanged;
  final VoidCallback onTap;
  final VoidCallback onUsedUp;
  final VoidCallback onDelete;

  @override
  State<SwipeRow> createState() => _SwipeRowState();
}

class _SwipeRowState extends State<SwipeRow> {
  static const double _actionW = 84;
  static const double _revealW = _actionW * 2;

  double _dx = 0;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _dx = widget.isOpen ? -_revealW : 0;
  }

  @override
  void didUpdateWidget(SwipeRow old) {
    super.didUpdateWidget(old);
    if (old.isOpen != widget.isOpen && !_dragging) {
      _dx = widget.isOpen ? -_revealW : 0;
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _dragging = true;
    setState(() {
      _dx = (_dx + d.delta.dx).clamp(-_revealW, 0.0);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    _dragging = false;
    final willOpen = _dx < -_revealW / 2;
    setState(() => _dx = willOpen ? -_revealW : 0);
    widget.onOpenChanged(willOpen);
  }

  void _handleTap() {
    if (widget.isOpen || _dx != 0) {
      widget.onOpenChanged(false);
      setState(() => _dx = 0);
      return;
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ing = widget.ingredient;
    final stripe = expiryInfoFor(ing.expiryDate, DateTime.now()).stripeColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // 背後のクイック操作
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _action(
                  label: l10n.actionUsedUp,
                  icon: Icons.check,
                  bg: AppColors.green,
                  onTap: widget.onUsedUp,
                ),
                _action(
                  label: l10n.actionDelete,
                  icon: Icons.delete_outline,
                  bg: AppColors.over,
                  onTap: widget.onDelete,
                ),
              ],
            ),
          ),
          // 前面カード
          AnimatedContainer(
            duration: Duration(milliseconds: _dragging ? 0 : 220),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(_dx, 0, 0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleTap,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: Container(
                color: AppColors.card,
                padding: const EdgeInsets.fromLTRB(9, 9, 12, 9),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 44,
                      decoration: BoxDecoration(
                        color: stripe.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(width: 11),
                    CatTile(category: ing.category, size: 42),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ing.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${ing.category.label(l10n)} ・ ${_qty(ing, l10n)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.sub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ExpiryBadge(expiry: ing.expiryDate),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _action({
    required String label,
    required IconData icon,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: _actionW,
      child: Material(
        color: bg,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
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

String _qty(Ingredient ing, AppLocalizations l10n) =>
    '${formatQuantity(ing.quantity)}${unitLabel(ing.unit, l10n)}';
