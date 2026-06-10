import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/inventory/data/inventory_repository.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/inventory/presentation/inventory_list_screen.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

void main() {
  late AppDatabase db;
  late InventoryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = InventoryRepository(db);
  });

  tearDown(() async => db.close());

  Future<void> seed(String name, {DateTime? expiry}) => repo.save(Ingredient(
        id: name,
        name: name,
        normalizedName: name,
        category: IngredientCategory.vegetable,
        quantity: 1,
        unit: 'piece',
        expiryDate: expiry,
        updatedAt: DateTime.now(),
      ));

  Future<void> pumpApp(WidgetTester tester) async {
    // スマホ幅（単一ペイン）で描画する。
    tester.view.physicalSize = const Size(390, 844);
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
          home: InventoryListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// drift の stream 購読解除が Timer(0) を予約するため、各テストの最後に
  /// 画面をアンマウントしてタイマーを消化させる（pending timer 検出の回避）。
  /// addTearDown では不変条件チェックに間に合わないので本体末尾で呼ぶこと。
  Future<void> unmountApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    // 引数なしの pump() は fake クロックを進めず Timer が発火しないため、
    // 明示的に時間を進めて破棄時の Timer(0) を消化する。
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('在庫が空のとき空状態を表示する', (tester) async {
    await pumpApp(tester);
    expect(find.text('在庫はまだ空っぽ'), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('期限グループごとに食材が表示される', (tester) async {
    final now = DateTime.now();
    await seed('豚肉', expiry: now.add(const Duration(days: 1))); // 今日・もうすぐ
    await seed('牛乳', expiry: now.add(const Duration(days: 5))); // 今週のうちに
    await seed('米'); // 期限なし

    await pumpApp(tester);

    expect(find.text('今日・もうすぐ使い切りたい'), findsOneWidget);
    expect(find.text('今週のうちに'), findsOneWidget);
    expect(find.text('賞味期限なし'), findsOneWidget);
    expect(find.text('豚肉'), findsOneWidget);
    expect(find.text('牛乳'), findsOneWidget);
    expect(find.text('米'), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('左スワイプで「使い切った」「削除」アクションが現れる', (tester) async {
    await seed('豚肉', expiry: DateTime.now().add(const Duration(days: 1)));
    await pumpApp(tester);

    await tester.drag(find.text('豚肉'), const Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(find.text('使い切った'), findsOneWidget);
    expect(find.text('削除'), findsOneWidget);
    await unmountApp(tester);
  });
}
