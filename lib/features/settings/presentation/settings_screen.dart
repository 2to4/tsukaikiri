import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import 'locale_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(localeControllerProvider.notifier);
    // 現在値の再描画のため watch する。
    ref.watch(localeControllerProvider);
    final current = controller.currentPref;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(l10n.settingsLanguage,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          RadioGroup<String>(
            groupValue: current,
            onChanged: (v) => controller.setPref(v!),
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'system',
                  title: Text(l10n.languageSystem),
                ),
                RadioListTile<String>(
                  value: 'ja',
                  title: Text(l10n.languageJa),
                ),
                RadioListTile<String>(
                  value: 'en',
                  title: Text(l10n.languageEn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
