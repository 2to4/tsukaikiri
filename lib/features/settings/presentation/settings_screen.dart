import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/appliance.dart';
import 'ai_settings_screen.dart';
import 'data_settings_screen.dart';
import 'integration_settings_screens.dart';
import 'locale_controller.dart';

/// 設定画面（Claude Design：リスト形式・カテゴリ別グループ）。
///
/// 一般・AI・連携・データはサブ画面に遷移する実機能。
/// サポート（ドネーション・ヘルプ・About）のみ後フェーズで、
/// タップで「準備中」を案内する。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _comingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }

  void _openAi(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AiSettingsScreen()),
    );
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
    // 選択中の AI プロバイダ（行の現在値表示用）。
    final settings = ref.watch(userSettingsProvider).value;
    final aiInfo =
        settings != null ? providerInfo(settings.selectedProvider) : null;
    final aiVisionLabel = aiInfo == null
        ? null
        : (aiInfo.supportsVision
            ? l10n.settingsAiVisionYes
            : l10n.settingsAiVisionNo);
    // 所有家電の現在値（行の表示用）。未所有なら「持っていない」。
    final applianceLabel = settings == null
        ? null
        : settings.appliances.isEmpty
            ? l10n.settingsApplianceNotOwned
            : settings.appliances
                .map((a) => switch (a.type) {
                      ApplianceType.hotcook => l10n.settingsApplianceHotcook,
                      ApplianceType.healsio => l10n.settingsApplianceHealsio,
                    })
                .join(' ・ ');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SettingsNavBar(title: l10n.settingsTitle),
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
                          value: aiInfo?.displayName,
                          onTap: () => _openAi(context)),
                      SettingsRow(
                          icon: Icons.vpn_key_outlined,
                          label: l10n.settingsApiKey,
                          onTap: () => _openAi(context)),
                      SettingsRow(
                          icon: Icons.photo_camera_outlined,
                          label: l10n.settingsImageRecognition,
                          value: aiVisionLabel,
                          last: true,
                          onTap: () => _openAi(context)),
                    ],
                  ),
                  SettingsSection(
                    title: l10n.settingsSectionIntegration,
                    children: [
                      SettingsRow(
                          icon: Icons.checklist,
                          label: l10n.settingsShoppingList,
                          value: settings?.shoppingListName,
                          onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const ShoppingSettingsScreen()),
                              )),
                      SettingsRow(
                          icon: Icons.soup_kitchen_outlined,
                          label: l10n.settingsAppliances,
                          value: applianceLabel,
                          last: true,
                          onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const ApplianceSettingsScreen()),
                              )),
                    ],
                  ),
                  SettingsSection(
                    title: l10n.settingsSectionData,
                    note: (settings?.syncEnabled ?? false)
                        ? null
                        : l10n.settingsSyncOffNote,
                    children: [
                      SettingsRow(
                        icon: Icons.cloud_outlined,
                        label: l10n.settingsCloudSync,
                        value: (settings?.syncEnabled ?? false)
                            ? l10n.settingsDataSyncEnabledLabel
                            : null,
                        last: true,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (_) => const DataSettingsScreen()),
                        ),
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
            SettingsNavBar(title: l10n.settingsLanguage),
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
                          trailing: SettingsRadioMark(on: current == opts[i].$1),
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
class SettingsNavBar extends StatelessWidget {
  const SettingsNavBar({super.key, required this.title});
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

class SettingsRadioMark extends StatelessWidget {
  const SettingsRadioMark({super.key, required this.on});
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
