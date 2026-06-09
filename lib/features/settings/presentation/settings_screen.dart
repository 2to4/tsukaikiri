import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'locale_controller.dart';

/// 設定画面（Claude Design：リスト形式・カテゴリ別グループ）。
///
/// 言語のみ実機能。AI・連携・同期・サポートは後フェーズのため、
/// 行は表示しつつタップで「準備中」を案内する。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _comingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pref = ref.watch(localeControllerProvider.notifier).currentPref;
    ref.watch(localeControllerProvider); // 再描画
    final langLabel = switch (pref) {
      'ja' => l10n.languageJa,
      'en' => l10n.languageEn,
      _ => l10n.languageSystem,
    };
    final soon = l10n.settingsComingSoonValue;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _NavBar(title: l10n.settingsTitle),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                children: [
                  SettingsSection(
                    title: l10n.settingsSectionGeneral,
                    children: [
                      SettingsRow(
                        icon: Icons.language,
                        label: l10n.settingsLanguage,
                        value: langLabel,
                        last: true,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (_) => const LanguageDetailScreen()),
                        ),
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: l10n.settingsSectionAi,
                    children: [
                      SettingsRow(
                          icon: Icons.auto_awesome,
                          label: l10n.settingsAiProvider,
                          value: soon,
                          onTap: () => _comingSoon(context)),
                      SettingsRow(
                          icon: Icons.vpn_key_outlined,
                          label: l10n.settingsApiKey,
                          value: soon,
                          onTap: () => _comingSoon(context)),
                      SettingsRow(
                          icon: Icons.photo_camera_outlined,
                          label: l10n.settingsImageRecognition,
                          value: soon,
                          last: true,
                          onTap: () => _comingSoon(context)),
                    ],
                  ),
                  SettingsSection(
                    title: l10n.settingsSectionIntegration,
                    children: [
                      SettingsRow(
                          icon: Icons.checklist,
                          label: l10n.settingsShoppingList,
                          value: soon,
                          onTap: () => _comingSoon(context)),
                      SettingsRow(
                          icon: Icons.soup_kitchen_outlined,
                          label: l10n.settingsAppliances,
                          value: soon,
                          last: true,
                          onTap: () => _comingSoon(context)),
                    ],
                  ),
                  SettingsSection(
                    title: l10n.settingsSectionData,
                    note: l10n.settingsSyncOffNote,
                    children: [
                      SettingsRow(
                        icon: Icons.cloud_outlined,
                        label: l10n.settingsCloudSync,
                        last: true,
                        trailing: _Toggle(
                            on: false, onTap: () => _comingSoon(context)),
                        onTap: () => _comingSoon(context),
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: l10n.settingsSectionSupport,
                    children: [
                      SettingsRow(
                          icon: Icons.local_cafe_outlined,
                          iconBg: AppColors.coffeeSoft,
                          label: l10n.settingsSupportAuthor,
                          value: 'Buy Me a Coffee',
                          onTap: () => _comingSoon(context)),
                      SettingsRow(
                          icon: Icons.help_outline,
                          label: l10n.settingsHelp,
                          onTap: () => _comingSoon(context)),
                      SettingsRow(
                          icon: Icons.info_outline,
                          label: l10n.settingsAbout,
                          value: 'v1.0.0',
                          last: true,
                          onTap: () => _comingSoon(context)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      l10n.settingsVersionLine('1.0.0'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.faint),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 言語選択（ラジオ）。
class LanguageDetailScreen extends ConsumerWidget {
  const LanguageDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(localeControllerProvider.notifier);
    ref.watch(localeControllerProvider);
    final current = controller.currentPref;

    final opts = <(String, String)>[
      ('ja', l10n.languageJa),
      ('en', l10n.languageEn),
      ('system', l10n.languageSystem),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _NavBar(title: l10n.settingsLanguage),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  SettingsSection(
                    children: [
                      for (var i = 0; i < opts.length; i++)
                        SettingsRow(
                          label: opts[i].$2,
                          last: i == opts.length - 1,
                          onTap: () => controller.setPref(opts[i].$1),
                          trailing: _RadioMark(on: current == opts[i].$1),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 2, 6, 0),
                    child: Text(l10n.languageHint,
                        style: const TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            fontWeight: FontWeight.w600,
                            color: AppColors.faint)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 共通パーツ
// ─────────────────────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  const _NavBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Row(
        children: [
          Material(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line, width: 1.5),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: AppColors.ink),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(title, style: brandTextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}

/// グループ見出し付きの白カードセクション。
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, this.title, this.note, required this.children});
  final String? title;
  final String? note;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: Text(title!,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: AppColors.faint)),
            ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
              child: Text(note!,
                  style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                      color: AppColors.faint)),
            ),
        ],
      ),
    );
  }
}

/// 設定の 1 行。
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    this.icon,
    this.iconBg,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    this.last = false,
  });

  final IconData? icon;
  final Color? iconBg;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg ?? AppColors.greenSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: AppColors.green),
            ),
            const SizedBox(width: 13),
          ],
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink)),
          ),
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(value!,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sub)),
            ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
          if (onTap != null && trailing == null)
            const Padding(
              padding: EdgeInsets.only(left: 2),
              child: Icon(Icons.chevron_right, size: 18, color: AppColors.faint),
            ),
        ],
      ),
    );

    return Column(
      children: [
        if (onTap != null)
          InkWell(onTap: onTap, child: content)
        else
          content,
        if (!last) const Divider(height: 1, color: AppColors.line),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.on, required this.onTap});
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: on ? AppColors.green : const Color(0xFFDDD8CE),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.on});
  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: on ? AppColors.green : Colors.white,
        shape: BoxShape.circle,
        border: on ? null : Border.all(color: AppColors.line, width: 2),
      ),
      child: on
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );
  }
}
