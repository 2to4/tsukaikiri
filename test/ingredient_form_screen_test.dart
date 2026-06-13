import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/inventory/data/inventory_repository.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/inventory/presentation/ingredient_form_screen.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

void main() {
  late AppDatabase db;
  late InventoryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = InventoryRepository(db);
  });

  tearDown(() async => db.close());

  Future<List<Ingredient>> allRows() => db.select(db.ingredients).get();

  /// フォームをホスト画面から push して開く（保存時の pop を成立させるため）。
  Future<void> pumpForm(WidgetTester tester, {Ingredient? ingredient}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          locale: const Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          IngredientFormScreen(ingredient: ingredient),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
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

  testWidgets('名前が空のまま保存するとエラーを表示し保存しない', (tester) async {
    await pumpForm(tester);

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('名前を入力してください'), findsOneWidget);
    expect(find.byType(IngredientFormScreen), findsOneWidget); // 閉じない
    expect(await allRows(), isEmpty);
    await unmountApp(tester);
  });

  testWidgets('数量が 0 以下だとエラーを表示し保存しない', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'トマト');
    await tester.enterText(find.byType(TextFormField).at(1), '0');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('0 より大きい数値を入力してください'), findsOneWidget);
    expect(await allRows(), isEmpty);
    await unmountApp(tester);
  });

  testWidgets('カスタム単位が空のまま保存すると SnackBar を表示し保存しない',
      (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'トマト');

    // 単位ドロップダウンで「カスタム…」を選び、入力欄は空のままにする。
    await tester.tap(find.text('個'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('カスタム…').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('単位を入力してください'), findsOneWidget);
    expect(await allRows(), isEmpty);

    // SnackBar の自動クローズタイマーを消化してから終了する。
    await tester.pumpAndSettle(const Duration(seconds: 5));
    await unmountApp(tester);
  });

  testWidgets('正常入力で保存すると DB に登録され画面が閉じる', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'トマト');
    await tester.enterText(find.byType(TextFormField).at(1), '2.5');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.byType(IngredientFormScreen), findsNothing); // pop された

    final rows = await allRows();
    expect(rows, hasLength(1));
    expect(rows.single.name, 'トマト');
    expect(rows.single.quantity, 2.5);
    expect(rows.single.unit, 'piece');
    expect(rows.single.category, IngredientCategory.vegetable);
    // 新規作成時はカテゴリ目安（野菜=5日）の期限が自動セットされる。
    expect(rows.single.expiryDate, isNotNull);
    await unmountApp(tester);
  });

  testWidgets('編集時は既存値を表示し、変更が上書き保存される', (tester) async {
    final existing = Ingredient(
      id: 'id-1',
      name: '豚肉',
      normalizedName: 'pork',
      category: IngredientCategory.meat,
      quantity: 1,
      unit: 'gram',
      expiryDate: DateTime(2026, 6, 12),
      updatedAt: DateTime(2026, 6, 10),
    );
    await repo.save(existing);
    await pumpForm(tester, ingredient: existing);

    expect(find.text('食材を編集'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '豚肉'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '鶏肉');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    final rows = await allRows();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'id-1');
    expect(rows.single.name, '鶏肉');
    expect(rows.single.normalizedName, 'pork'); // 名寄せキーは維持
    await unmountApp(tester);
  });
}
