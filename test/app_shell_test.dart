import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/inventory/data/inventory_repository.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/shell/presentation/app_shell.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

void main() {
  late AppDatabase db;
  late InventoryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = InventoryRepository(db);
  });

  tearDown(() async => db.close());

  /// テストの最後に drift stream 購読を安全に解除するヘルパー
  /// （pending timer 検出の回避。inventory_list_screen_test.dart の unmountApp と同パターン）。
  Future<void> unmountApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  /// デスクトップ幅でシェルをレンダリングする共通ヘルパー。
  Future<void> pumpShell(WidgetTester tester) async {
    // デスクトップ幅（1280x800）に設定する
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
          home: AppShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // ─── テスト 1: シェルが表示されサイドバーに7項目が出る ───

  testWidgets('シェルが表示されサイドバーに7つのナビ項目が出る', (tester) async {
    await pumpShell(tester);

    // サイドバーの7項目が揃っているか確認
    // M2 以降: 「在庫」はサイドバー + ツールバータイトルで複数、
    //          「カメラ登録」はサイドバー + 在庫ツールバーボタンで複数。
    expect(find.text('在庫'), findsWidgets);
    expect(find.text('カメラ登録'), findsWidgets);  // M2: ツールバーボタンが追加
    expect(find.text('献立提案'), findsWidgets);    // M2: ツールバーボタンが追加
    expect(find.text('買い物リスト'), findsOneWidget);
    expect(find.text('設定アシスタント'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
    expect(find.text('ヘルプ'), findsOneWidget);

    // アプリアイコン領域の 🌿 が見えること
    expect(find.text('🌿'), findsOneWidget);

    // セクション見出し「メイン」「その他」が見えること
    expect(find.text('メイン'), findsOneWidget);
    expect(find.text('その他'), findsOneWidget);

    await unmountApp(tester);
  });

  // ─── テスト 2: ナビ項目クリックでコンテンツが切り替わる ───

  testWidgets('カメラ登録をタップするとドロップゾーンが表示される', (tester) async {
    await pumpShell(tester);

    // M2 以降、「カメラ登録」はサイドバーとツールバーボタンで2件ある。
    // サイドバー（左端）のほうをタップするため first を使う。
    await tester.tap(find.text('カメラ登録').first);
    await tester.pumpAndSettle();

    // M6 で実装済み: ドロップゾーンのキャッチコピーが表示される。
    expect(find.text('写真をドロップ、または クリックして選択'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('献立提案をタップすると献立提案ビューが表示される', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('献立提案'));
    await tester.pumpAndSettle();

    // M4 で実装済みの献立提案 2ペイン（提案前状態の案内とボタン）が出る。
    expect(find.text('在庫から提案する'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('買い物リストをタップすると買い物リストビューが表示される', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('買い物リスト'));
    // 非同期の initialize() が走るため pump を複数回行う。
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // M5 実装済み: 献立なし状態の案内テキストが表示される。
    expect(find.textContaining('献立を決めると'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('設定アシスタントをタップするとオンボーディングが表示される', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('設定アシスタント'));
    await tester.pumpAndSettle();

    // M7 実装済み: ようこそステップが表示される。
    expect(find.text('つかいきりへようこそ'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('ヘルプをタップするとヘルプビューが表示される', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('ヘルプ'));
    await tester.pumpAndSettle();

    // M8 実装済み: ヘルプビューの主要セクション見出しが表示される。
    expect(find.text('かんたんな使い方'), findsOneWidget);

    await unmountApp(tester);
  });

  // ─── テスト 3: 在庫件数バッジが DB の件数を反映する ───

  testWidgets('DB に食材が 0 件のとき「0品の食材」と表示される', (tester) async {
    await pumpShell(tester);

    expect(find.text('0品の食材'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('DB に食材が 3 件あると「3品の食材」と表示される', (tester) async {
    // 3件の食材を事前に登録する
    for (final name in ['豚肉', '牛乳', 'キャベツ']) {
      await repo.save(Ingredient(
        id: name,
        name: name,
        normalizedName: name,
        category: IngredientCategory.vegetable,
        quantity: 1,
        unit: '個',
        expiryDate: null,
        updatedAt: DateTime.now(),
      ));
    }

    await pumpShell(tester);

    expect(find.text('3品の食材'), findsOneWidget);

    await unmountApp(tester);
  });

  // ─── テスト 4: 初期セクションは在庫で、在庫一覧が表示される ───

  testWidgets('初期表示では在庫画面が表示される（空状態）', (tester) async {
    await pumpShell(tester);

    // 在庫が空なので空状態テキストが見える
    expect(find.text('在庫はまだ空っぽ'), findsOneWidget);

    await unmountApp(tester);
  });
}
