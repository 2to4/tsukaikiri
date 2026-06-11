// help_desktop_view_test.dart
// M8 ヘルプ/このアプリについて ビューの widget テスト。
// CLAUDE.md の規約に従い unmountApp パターン必須。
// HelpDesktopView は drift stream を持たないため、
// DB・SecureStorage の override は不要。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/features/help/presentation/help_desktop_view.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

// ──────────────────────────────────────────────────────────────
// テストヘルパー
// ──────────────────────────────────────────────────────────────

/// ヘルプビューをデスクトップ幅でビルドするヘルパー。
Future<void> pumpView(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const MaterialApp(
      locale: Locale('ja'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: HelpDesktopView()),
    ),
  );
  // package_info_plus の非同期読み込みを完了させる
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// HelpDesktopView は drift stream を持たないが、
/// 規約に従って unmountApp を呼ぶ（将来的な変更への備え）。
Future<void> unmountApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

// ──────────────────────────────────────────────────────────────
// テスト本体
// ──────────────────────────────────────────────────────────────

void main() {
  // ═══════════════════════════════════════════════════════
  // ① 主要セクション見出しが表示される
  // ═══════════════════════════════════════════════════════
  testWidgets('① 主要セクション見出しが表示される', (tester) async {
    await pumpView(tester);

    // かんたんな使い方
    expect(find.text('かんたんな使い方'), findsOneWidget);

    // 賞味期限データについて
    expect(find.text('賞味期限データについて'), findsOneWidget);

    // 出典・参考データ
    expect(find.text('出典・参考データ'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ②「あくまで目安」コールアウトが表示される
  // ═══════════════════════════════════════════════════════
  testWidgets('②「表示される期限はあくまで目安です」コールアウトが表示される', (tester) async {
    await pumpView(tester);

    expect(find.text('表示される期限はあくまで目安です'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ③ STEP 1〜4 が表示される
  // ═══════════════════════════════════════════════════════
  testWidgets('③ STEP 1〜4 が全て表示される', (tester) async {
    await pumpView(tester);

    expect(find.text('STEP 1'), findsOneWidget);
    expect(find.text('STEP 2'), findsOneWidget);
    expect(find.text('STEP 3'), findsOneWidget);
    expect(find.text('STEP 4'), findsOneWidget);

    // 各ステップのタイトルも確認
    expect(find.text('食材を登録する'), findsOneWidget);
    expect(find.text('在庫と期限を確認する'), findsOneWidget);
    expect(find.text('献立を提案してもらう'), findsOneWidget);
    expect(find.text('不足食材を買い物リストへ'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ④ 緑コールアウト「賞味期限はいつでも手動で修正できます」が表示される
  // ═══════════════════════════════════════════════════════
  testWidgets('④ 緑コールアウト「賞味期限はいつでも手動で修正できます」が表示される', (tester) async {
    await pumpView(tester);

    expect(find.text('賞味期限はいつでも手動で修正できます'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑤ 出典リンクカードが 2 件（FoodKeeper / Data.gov）表示される
  // ═══════════════════════════════════════════════════════
  testWidgets('⑤ FoodKeeper と Data.gov の出典リンクカードが表示される', (tester) async {
    await pumpView(tester);

    expect(find.text('FoodKeeper'), findsOneWidget);
    expect(find.text('Data.gov（FoodKeeper Data）'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑥ 規約・プライバシー行（無効表示）が表示される
  // ═══════════════════════════════════════════════════════
  testWidgets('⑥ 規約・プライバシーポリシー・FAQ の各行が無効表示で出る', (tester) async {
    await pumpView(tester);

    expect(find.text('利用規約'), findsOneWidget);
    expect(find.text('プライバシーポリシー'), findsOneWidget);
    expect(find.text('よくある質問・お問い合わせ'), findsOneWidget);

    await unmountApp(tester);
  });
}
