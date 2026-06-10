// inventory_desktop_view_test.dart
// M2 在庫 3ペインビューの widget テスト。
// CLAUDE.md の規約に従い unmountApp パターン必須。

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/inventory/data/inventory_repository.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/inventory/presentation/inventory_desktop_view.dart';
import 'package:tsukaikiri/features/inventory/presentation/inventory_providers.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

void main() {
  late AppDatabase db;
  late InventoryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = InventoryRepository(db);
  });

  tearDown(() async => db.close());

  // ─────────────────────────────────────────────────────────
  // ヘルパー: デスクトップ幅（1280×800）でウィジェットをレンダリングする
  // ─────────────────────────────────────────────────────────
  Future<void> pumpView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: InventoryDesktopView()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// drift の stream 購読解除が Timer(0) を予約するため、各テストの最後に
  /// 画面をアンマウントしてタイマーを消化させる（pending timer 検出の回避）。
  Future<void> unmountApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  // ─────────────────────────────────────────────────────────
  // 食材シード作成ヘルパー
  // ─────────────────────────────────────────────────────────
  Future<Ingredient> seedIngredient(
    String name, {
    DateTime? expiry,
    IngredientCategory category = IngredientCategory.vegetable,
    double quantity = 1,
    String unit = '個',
  }) async {
    final ing = Ingredient(
      id: name,
      name: name,
      normalizedName: name,
      category: category,
      quantity: quantity,
      unit: unit,
      expiryDate: expiry,
      updatedAt: DateTime.now(),
    );
    await repo.save(ing);
    return ing;
  }

  // ═══════════════════════════════════════════════════════
  // テスト ①: 期限グループの3区分表示
  // ═══════════════════════════════════════════════════════
  testWidgets('期限グルーピングの3区分が正しく表示される', (tester) async {
    final now = DateTime.now();
    // 今日・もうすぐ（1日後）
    await seedIngredient('豚肉', expiry: now.add(const Duration(days: 1)));
    // 今週のうちに（5日後）
    await seedIngredient('牛乳', expiry: now.add(const Duration(days: 5)));
    // まだ余裕（期限なし）
    await seedIngredient('米');

    await pumpView(tester);

    // グループ見出しが3つ表示されること
    expect(find.text('今日・もうすぐ'), findsOneWidget);
    expect(find.text('今週のうちに'), findsOneWidget);
    expect(find.text('まだ余裕'), findsOneWidget);

    // 各食材が見えること
    expect(find.text('豚肉'), findsOneWidget);
    expect(find.text('牛乳'), findsOneWidget);
    expect(find.text('米'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('期限超過の食材は「今日・もうすぐ」グループに表示される', (tester) async {
    final now = DateTime.now();
    // 2日前（超過）
    await seedIngredient('傷んだ野菜',
        expiry: now.subtract(const Duration(days: 2)));

    await pumpView(tester);

    expect(find.text('今日・もうすぐ'), findsOneWidget);
    expect(find.text('傷んだ野菜'), findsOneWidget);
    // 超過チップ
    expect(find.text('2日超過'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('期限8日以上の食材は「まだ余裕」グループに表示される', (tester) async {
    final now = DateTime.now();
    await seedIngredient('長持ち食材',
        expiry: now.add(const Duration(days: 10)));

    await pumpView(tester);

    expect(find.text('まだ余裕'), findsOneWidget);
    expect(find.text('長持ち食材'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // テスト ②: カテゴリフィルタで絞り込み
  // ═══════════════════════════════════════════════════════
  testWidgets('カテゴリフィルタを Provider 経由で適用すると絞り込まれる', (tester) async {
    await seedIngredient('豚肉', category: IngredientCategory.meat);
    await seedIngredient('ほうれん草', category: IngredientCategory.vegetable);

    // ProviderContainer を取得できるよう Consumer でラップ
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(
              locale: Locale('ja'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(body: InventoryDesktopView()),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 最初は両方表示
    expect(find.text('豚肉'), findsOneWidget);
    expect(find.text('ほうれん草'), findsOneWidget);

    // 肉カテゴリを Provider 経由で設定（UI タップは「肉」テキストが複数あり曖昧になるため）
    container
        .read(desktopCategoryFilterProvider.notifier)
        .set(IngredientCategory.meat);
    await tester.pumpAndSettle();

    // 豚肉のみ表示、野菜は消える
    expect(find.text('豚肉'), findsOneWidget);
    expect(find.text('ほうれん草'), findsNothing);

    // 「すべて」に戻す
    container.read(desktopCategoryFilterProvider.notifier).set(null);
    await tester.pumpAndSettle();

    expect(find.text('豚肉'), findsOneWidget);
    expect(find.text('ほうれん草'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // テスト ③: 行クリックで詳細ペイン表示
  // ═══════════════════════════════════════════════════════
  testWidgets('行をタップすると右ペインに食材詳細が表示される', (tester) async {
    await seedIngredient('豚バラ', category: IngredientCategory.meat,
        quantity: 300, unit: 'g');

    await pumpView(tester);

    // 未選択時はプレースホルダが表示される
    expect(find.text('食材を選択してください'), findsOneWidget);

    // 行をタップ
    await tester.tap(find.text('豚バラ'));
    await tester.pumpAndSettle();

    // 詳細ペインに食材名が表示される（ヘッダー + 明細行で複数あり得る）
    expect(find.text('豚バラ'), findsWidgets);
    // 詳細ペインのアクションボタンが表示される
    expect(find.text('この食材で献立を提案'), findsOneWidget);
    expect(find.text('使い切りにする'), findsOneWidget);
    expect(find.text('削除'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // テスト ④: 検索で絞り込み（Provider 直接操作）
  // ═══════════════════════════════════════════════════════
  testWidgets('desktopSearchQueryProvider を更新すると検索絞り込みが働く',
      (tester) async {
    await seedIngredient('豚肉');
    await seedIngredient('鶏肉');

    // ProviderScope を直接操作できるよう container を取得する
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(
              locale: Locale('ja'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(body: InventoryDesktopView()),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 最初は両方表示
    expect(find.text('豚肉'), findsOneWidget);
    expect(find.text('鶏肉'), findsOneWidget);

    // 検索クエリを「豚」に設定
    container.read(desktopSearchQueryProvider.notifier).update('豚');
    await tester.pumpAndSettle();

    // 豚肉のみ表示
    expect(find.text('豚肉'), findsOneWidget);
    expect(find.text('鶏肉'), findsNothing);

    // 0 件になる検索
    container.read(desktopSearchQueryProvider.notifier).update('存在しない');
    await tester.pumpAndSettle();

    expect(find.text('該当する食材がありません'), findsOneWidget);

    // クリア
    container.read(desktopSearchQueryProvider.notifier).clear();
    await tester.pumpAndSettle();

    expect(find.text('豚肉'), findsOneWidget);
    expect(find.text('鶏肉'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // テスト ⑤: 「使い切りにする」で行が消える
  // ═══════════════════════════════════════════════════════
  testWidgets('詳細ペインの「使い切りにする」をタップすると食材が一覧から消える',
      (tester) async {
    // 2品登録しておく（1品だと全部消えて空状態になるため、残る1品で詳細ペイン状態を確認）
    await seedIngredient('キャベツ', category: IngredientCategory.vegetable);
    await seedIngredient('にんじん', category: IngredientCategory.vegetable);

    await pumpView(tester);

    // 食材が表示されている
    expect(find.text('キャベツ'), findsOneWidget);
    expect(find.text('にんじん'), findsOneWidget);

    // 行をタップして詳細ペインを開く
    await tester.tap(find.text('キャベツ'));
    await tester.pumpAndSettle();

    // 詳細ペインが開いた
    expect(find.text('この食材で献立を提案'), findsOneWidget);

    // 「使い切りにする」をタップ
    await tester.tap(find.text('使い切りにする'));
    await tester.pumpAndSettle();

    // キャベツが一覧から消えること
    expect(find.text('キャベツ'), findsNothing);
    // にんじんはまだある
    expect(find.text('にんじん'), findsOneWidget);
    // 詳細ペインは未選択状態に戻る
    expect(find.text('食材を選択してください'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // テスト ⑥: 在庫が空のとき空状態が表示される
  // ═══════════════════════════════════════════════════════
  testWidgets('在庫が空のとき空状態ウィジェットが表示される', (tester) async {
    await pumpView(tester);

    expect(find.text('在庫はまだ空っぽ'), findsOneWidget);

    await unmountApp(tester);
  });
}
