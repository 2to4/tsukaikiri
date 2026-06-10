import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/layout/breakpoints.dart';
import 'core/theme/app_theme.dart';
import 'features/inventory/presentation/inventory_list_screen.dart';
import 'features/settings/presentation/locale_controller.dart';
import 'features/shell/presentation/app_shell.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: TsukaikiriApp()));
}

class TsukaikiriApp extends ConsumerWidget {
  const TsukaikiriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: locale, // null = 端末ロケールに追従
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _RootPage(),
    );
  }
}

/// 画面幅に応じてシェルとモバイルレイアウトを切り替えるルートページ。
///
/// 幅 >= [kDesktopBreakpoint]（1000px）→ [AppShell]（macOS デスクトップシェル）
/// 幅 < [kDesktopBreakpoint] → [InventoryListScreen]（モバイルフロー）
class _RootPage extends StatelessWidget {
  const _RootPage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= kDesktopBreakpoint) {
          return const AppShell();
        }
        return const InventoryListScreen();
      },
    );
  }
}
