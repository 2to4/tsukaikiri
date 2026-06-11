import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/camera/presentation/camera_capture_controller.dart';
import '../../../features/camera/presentation/camera_desktop_view.dart';
import '../../../features/inventory/presentation/inventory_desktop_view.dart';
import '../../../features/inventory/presentation/inventory_providers.dart';
import '../../../features/help/presentation/help_desktop_view.dart';
import '../../../features/onboarding/presentation/onboarding_desktop_view.dart';
import '../../../features/recipe/presentation/meal_suggestion_controller.dart';
import '../../../features/recipe/presentation/meals_desktop_view.dart';
import '../../../features/settings/presentation/settings_desktop_view.dart';
import '../../../features/shopping/presentation/shopping_desktop_view.dart';
import '../../../l10n/app_localizations.dart';
import 'shell_providers.dart';

// ─────────────────────────────────────────────────────────────
// サイドバーの幅定数
// ─────────────────────────────────────────────────────────────
const double _kSidebarWidth = 216.0;
const double _kToolbarHeight = 50.0;

// ─────────────────────────────────────────────────────────────
// macOS デスクトップシェル
// ─────────────────────────────────────────────────────────────

/// macOS 向けデスクトップシェル。
///
/// 構成: Row[ AppSidebar(216px) | Column[ ShellToolbar(50px) | コンテンツ ] ]
///
/// ナビ状態は [shellSectionProvider] で管理し、⌘1〜⌘4 / ⌘, の
/// キーボードショートカットでも切替可能。
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(shellSectionProvider);

    // ⌘1〜⌘4 / ⌘, のショートカット定義（macOS は meta キー）
    // ⌘N（追加フォーム）・⌘K（camera）・⌘R（meals）は在庫セクション表示中に有効化。
    // ⌘1〜⌘4 / ⌘, と衝突しないよう注意すること。
    final shortcuts = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.digit1, meta: true): () =>
          ref.read(shellSectionProvider.notifier).select(ShellSection.inventory),
      const SingleActivator(LogicalKeyboardKey.digit2, meta: true): () =>
          ref.read(shellSectionProvider.notifier).select(ShellSection.camera),
      const SingleActivator(LogicalKeyboardKey.digit3, meta: true): () =>
          ref.read(shellSectionProvider.notifier).select(ShellSection.meals),
      const SingleActivator(LogicalKeyboardKey.digit4, meta: true): () =>
          ref.read(shellSectionProvider.notifier).select(ShellSection.shopping),
      const SingleActivator(LogicalKeyboardKey.comma, meta: true): () =>
          ref.read(shellSectionProvider.notifier).select(ShellSection.settings),
      // 在庫セクション専用ショートカット
      const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () {
        if (ref.read(shellSectionProvider) == ShellSection.inventory) {
          showIngredientFormDialog(context);
        }
      },
      const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
        if (ref.read(shellSectionProvider) == ShellSection.inventory) {
          ref
              .read(shellSectionProvider.notifier)
              .select(ShellSection.camera);
        }
      },
      const SingleActivator(LogicalKeyboardKey.keyR, meta: true): () {
        final current = ref.read(shellSectionProvider);
        if (current == ShellSection.inventory) {
          // 在庫セクションでは献立提案へ切替。
          ref.read(shellSectionProvider.notifier).select(ShellSection.meals);
        } else if (current == ShellSection.meals) {
          // 献立セクション表示中は提案を実行する。
          ref.read(mealSuggestionControllerProvider.notifier).suggest();
        } else if (current == ShellSection.camera) {
          // カメラセクション表示中かつ画像が1枚以上あれば解析を実行する。
          final camState = ref.read(cameraCaptureControllerProvider);
          if (camState.phase == CameraCapturePhase.capture &&
              camState.images.isNotEmpty) {
            ref.read(cameraCaptureControllerProvider.notifier).analyze();
          }
        }
      },
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: Row(
            children: [
              _AppSidebar(currentSection: section),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: Column(
                  children: [
                    ShellToolbar(section: section),
                    Expanded(
                      child: _ContentArea(section: section),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// サイドバー
// ─────────────────────────────────────────────────────────────

/// macOS スタイルのナビゲーションサイドバー。
///
/// macosShell.jsx の [AppSidebar] を忠実に再現。
/// 背景は #EEEAE2 相当の単色（Flutter ではぼかし効果を省略）。
class _AppSidebar extends ConsumerWidget {
  const _AppSidebar({required this.currentSection});

  final ShellSection currentSection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // 在庫件数をリアルタイムで取得する
    final inventoryAsync = ref.watch(inventoryListProvider);
    final count = inventoryAsync.maybeWhen(data: (list) => list.length, orElse: () => 0);

    return SizedBox(
      width: _kSidebarWidth,
      child: ColoredBox(
        // macosShell.jsx の `rgba(238,234,226,0.82)` に相当する単色
        color: const Color(0xFFEEEAE2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // アプリアイコン＋名前＋食材数
            _SidebarHeader(count: count),
            // ナビ項目（メイン）
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionLabel(l10n.shellSectionMain),
                    _NavItem(
                      icon: Icons.inventory_2_outlined,
                      label: l10n.shellNavInventory,
                      shortcut: '⌘1',
                      selected: currentSection == ShellSection.inventory,
                      onTap: () => ref
                          .read(shellSectionProvider.notifier)
                          .select(ShellSection.inventory),
                    ),
                    _NavItem(
                      icon: Icons.photo_camera_outlined,
                      label: l10n.shellNavCamera,
                      shortcut: '⌘2',
                      selected: currentSection == ShellSection.camera,
                      onTap: () => ref
                          .read(shellSectionProvider.notifier)
                          .select(ShellSection.camera),
                    ),
                    _NavItem(
                      icon: Icons.auto_awesome_outlined,
                      label: l10n.shellNavMeals,
                      shortcut: '⌘3',
                      selected: currentSection == ShellSection.meals,
                      onTap: () => ref
                          .read(shellSectionProvider.notifier)
                          .select(ShellSection.meals),
                    ),
                    _NavItem(
                      icon: Icons.checklist_outlined,
                      label: l10n.shellNavShopping,
                      shortcut: '⌘4',
                      selected: currentSection == ShellSection.shopping,
                      onTap: () => ref
                          .read(shellSectionProvider.notifier)
                          .select(ShellSection.shopping),
                    ),
                    _SectionLabel(l10n.shellSectionOther),
                    _NavItem(
                      icon: Icons.settings_suggest_outlined,
                      label: l10n.shellNavOnboarding,
                      shortcut: '',
                      selected: currentSection == ShellSection.onboarding,
                      onTap: () => ref
                          .read(shellSectionProvider.notifier)
                          .select(ShellSection.onboarding),
                    ),
                    _NavItem(
                      icon: Icons.settings_outlined,
                      label: l10n.shellNavSettings,
                      shortcut: '⌘,',
                      selected: currentSection == ShellSection.settings,
                      onTap: () => ref
                          .read(shellSectionProvider.notifier)
                          .select(ShellSection.settings),
                    ),
                    _NavItem(
                      icon: Icons.help_outline,
                      label: l10n.shellNavHelp,
                      shortcut: '',
                      selected: currentSection == ShellSection.help,
                      onTap: () => ref
                          .read(shellSectionProvider.notifier)
                          .select(ShellSection.help),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// サイドバー上部ヘッダー（アイコン＋アプリ名＋在庫数）
// ─────────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      child: Row(
        children: [
          // アプリアイコン: 34px 角丸10 の緑タイル + 🌿
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x471F7A55),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text('🌿', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'つかいきり',
                  style: brandTextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 1),
                Text(
                  l10n.shellInventoryCount(count),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sub,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// セクション見出し
// ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: AppColors.faint,
          letterSpacing: 0.08 * 9.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ナビ項目
// ─────────────────────────────────────────────────────────────

/// macosShell.jsx の [MacNavItem] に相当。
///
/// 選択時: 背景 greenSoft・アイコンタイル green・文字 greenInk。
/// ホバー時: rgba(40,39,35,0.05) の薄い背景。
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.shortcut,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String shortcut;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    Color bgColor;
    if (selected) {
      bgColor = AppColors.greenSoft;
    } else if (_hovered) {
      bgColor = const Color(0x0D282723); // rgba(40,39,35,0.05)
    } else {
      bgColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // アイコンタイル 26×26 角丸7
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: selected ? AppColors.green : const Color(0x14282723),
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.icon,
                  size: 13,
                  color: selected ? Colors.white : AppColors.sub,
                ),
              ),
              const SizedBox(width: 8),
              // ラベル
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? AppColors.greenInk : AppColors.ink,
                  ),
                ),
              ),
              // ショートカット表記
              if (widget.shortcut.isNotEmpty)
                Text(
                  widget.shortcut,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.faint,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ツールバー
// ─────────────────────────────────────────────────────────────

/// 汎用ツールバー。セクションに応じて在庫専用ツールバーか汎用タイトルを表示する。
class ShellToolbar extends ConsumerWidget {
  const ShellToolbar({
    super.key,
    required this.section,
    this.actions = const [],
  });

  final ShellSection section;

  /// ツールバーに並べるアクションウィジェット（在庫以外のセクション向け）。
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: _kToolbarHeight,
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          bottom: BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      // 在庫セクションは専用ツールバーを使用（ボタン・検索フィールドあり）
      child: section == ShellSection.inventory
          ? const InventoryDesktopToolbar()
          : _DefaultToolbarContent(section: section, actions: actions),
    );
  }
}

class _DefaultToolbarContent extends StatelessWidget {
  const _DefaultToolbarContent({
    required this.section,
    required this.actions,
  });

  final ShellSection section;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _titleFor(section, l10n);

    return Row(
      children: [
        Text(
          title,
          style: brandTextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: 8),
          ...actions,
        ],
      ],
    );
  }

  String _titleFor(ShellSection section, AppLocalizations l10n) =>
      switch (section) {
        ShellSection.inventory => l10n.shellNavInventory,
        ShellSection.camera => l10n.shellNavCamera,
        ShellSection.meals => l10n.shellNavMeals,
        ShellSection.shopping => l10n.shellNavShopping,
        ShellSection.onboarding => l10n.shellNavOnboarding,
        ShellSection.settings => l10n.shellNavSettings,
        ShellSection.help => l10n.shellNavHelp,
      };
}

// ─────────────────────────────────────────────────────────────
// コンテンツエリア
// ─────────────────────────────────────────────────────────────

/// セクションに応じたコンテンツを表示する。
///
/// - [ShellSection.inventory]: macOS 専用 3ペイン在庫ビュー [InventoryDesktopView]。
/// - [ShellSection.settings]: macOS 専用 2ペイン設定ビュー [SettingsDesktopView]。
/// - その他: 中央寄せプレースホルダ。
class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.section});

  final ShellSection section;

  @override
  Widget build(BuildContext context) {
    return switch (section) {
      ShellSection.inventory => const InventoryDesktopView(),
      ShellSection.camera => const CameraDesktopView(),
      ShellSection.meals => const MealsDesktopView(),
      ShellSection.shopping => const ShoppingDesktopView(),
      ShellSection.settings => const SettingsDesktopView(),
      ShellSection.onboarding => const OnboardingDesktopView(),
      ShellSection.help => const HelpDesktopView(),
    };
  }
}

// _Placeholder は全セクションが実装済みになったため削除。
// 将来的に未実装セクションを追加する場合は _ContentArea の switch に
// デフォルト分岐を追加し、このファイルにプレースホルダを再定義すること。
