import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

// ──────────────────────────────────────────────────────────────
// ToolbarButton
// macosShell.jsx の TBtn を Flutter で再現した汎用ツールバーボタン。
// primary: 緑背景・白文字・影、secondary: 白背景・line ボーダー。
// ──────────────────────────────────────────────────────────────

class ToolbarButton extends StatefulWidget {
  const ToolbarButton({
    super.key,
    required this.label,
    this.icon,
    this.shortcutLabel,
    this.primary = false,
    this.onPressed,
    this.small = false,
  });

  final String label;
  final IconData? icon;

  /// ⌘N などのショートカット表記（null なら非表示）。
  final String? shortcutLabel;

  /// true: 緑塗りつぶし、false: 白背景＋ line ボーダー。
  final bool primary;

  final VoidCallback? onPressed;

  /// true: パディングを少し小さくする。
  final bool small;

  @override
  State<ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<ToolbarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final padding = widget.small
        ? const EdgeInsets.symmetric(horizontal: 9, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 5);

    // 背景色
    Color bgColor;
    if (disabled) {
      bgColor = const Color(0x0A282723); // rgba(40,39,35,0.04)
    } else if (widget.primary) {
      bgColor = AppColors.green;
    } else {
      bgColor = _hovered
          ? Colors.white
          : const Color(0xD1FFFFFF); // rgba(255,255,255,0.82)
    }

    // 前景色（アイコン・ショートカットチップ）
    final fgColor = disabled
        ? AppColors.faint
        : widget.primary
            ? Colors.white
            : AppColors.sub;

    // テキスト色
    final textColor = disabled
        ? AppColors.faint
        : widget.primary
            ? Colors.white
            : AppColors.ink;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: disabled
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(7),
            border: widget.primary
                ? null
                : Border.all(color: AppColors.line, width: 1),
            boxShadow: widget.primary && !disabled
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
                Icon(
                  widget.icon,
                  size: widget.small ? 11 : 12,
                  color: fgColor,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.small ? 12 : 12.5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              if (widget.shortcutLabel != null) ...[
                const SizedBox(width: 4),
                _KbdChip(label: widget.shortcutLabel!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _KbdChip: ⌘N などのショートカット表記チップ
// macosShell.jsx の Kbd に相当。
// ──────────────────────────────────────────────────────────────
class _KbdChip extends StatelessWidget {
  const _KbdChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0x17282723), // rgba(40,39,35,0.09)
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.faint,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// ToolbarDivider: 縦区切り線（VDiv 相当）
// ──────────────────────────────────────────────────────────────
class ToolbarDivider extends StatelessWidget {
  const ToolbarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 1,
      height: 18,
      child: ColoredBox(color: AppColors.line),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// ToolbarSearchField: 検索フィールド（MacSearch 相当）
// macosShell.jsx の MacSearch を Flutter で再現。
// 高さ30・角丸7・フォーカスで緑ボーダー。
// ──────────────────────────────────────────────────────────────
class ToolbarSearchField extends StatefulWidget {
  const ToolbarSearchField({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.minWidth = 150,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final double minWidth;

  @override
  State<ToolbarSearchField> createState() => _ToolbarSearchFieldState();
}

class _ToolbarSearchFieldState extends State<ToolbarSearchField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      height: 30,
      constraints: BoxConstraints(minWidth: widget.minWidth),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search, size: 12, color: AppColors.faint),
          const SizedBox(width: 6),
          Flexible(
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
