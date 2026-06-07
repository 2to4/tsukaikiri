import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

/// UI 言語設定。null = システムに従う。
/// DB の `localePref`（'ja' / 'en' / 'system'）と同期する。
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    _load();
    return null; // 読み込み完了までは system 扱い
  }

  Future<void> _load() async {
    final pref = await ref.read(settingsRepositoryProvider).getLocalePref();
    state = _toLocale(pref);
  }

  Future<void> setPref(String pref) async {
    await ref.read(settingsRepositoryProvider).setLocalePref(pref);
    state = _toLocale(pref);
  }

  /// 現在の設定値（UI のラジオ選択用）。
  String get currentPref => switch (state) {
        Locale(languageCode: 'ja') => 'ja',
        Locale(languageCode: 'en') => 'en',
        _ => 'system',
      };

  Locale? _toLocale(String pref) => switch (pref) {
        'ja' => const Locale('ja'),
        'en' => const Locale('en'),
        _ => null,
      };
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
