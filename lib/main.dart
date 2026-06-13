import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/layout/breakpoints.dart';
import 'core/providers.dart';
import 'core/shelf_life/shelf_life_table.dart';
import 'core/theme/app_theme.dart';
import 'features/recipe/service/recipe_provider_factory.dart';
import 'features/inventory/presentation/inventory_list_screen.dart';
import 'features/settings/presentation/locale_controller.dart';
import 'features/shell/presentation/app_shell.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 日持ち目安テーブルを起動時に読み込む。失敗しても空テーブルで起動を続ける。
  ShelfLifeTable shelfLifeTable;
  try {
    shelfLifeTable = await ShelfLifeTable.load();
  } catch (_) {
    shelfLifeTable = ShelfLifeTable.empty();
  }

  final container = ProviderContainer(
    overrides: [
      shelfLifeTableProvider.overrideWithValue(shelfLifeTable),
    ],
  );

  // 初回起動時のみ、端末のオンデバイス AI 可否で既定プロバイダを決める。
  // 対応端末 → オンデバイス / 非対応 → Gemini。以降はユーザー選択を尊重。
  try {
    final availability =
        await container.read(onDeviceAiServiceProvider).availability();
    await container
        .read(settingsRepositoryProvider)
        .initializeDefaultProviderIfUnset(
          availability.available ? onDeviceProviderId : 'gemini',
        );
  } catch (_) {
    // 判定に失敗しても起動は続ける（既定はリポジトリの 'gemini' フォールバック）。
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TsukaikiriApp(),
    ),
  );
}

class TsukaikiriApp extends ConsumerWidget {
  const TsukaikiriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 自動バックアップウォッチャーをアプリ生存期間中常駐させる。
    ref.watch(autoBackupWatcherProvider);

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
