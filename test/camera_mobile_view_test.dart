// camera_mobile_view_test.dart
// カメラ登録モバイル（狭い幅）ビューの widget テスト。
// camera_desktop_view_test.dart と同じ流儀:
//   - インメモリ DB・モバイル幅（390×844）・unmountApp 必須
//   - analyzing の無限アニメーションを pumpAndSettle に通さない（pump を固定回数）
//   - ピッカーは UI 統合テスト不能のため、コントローラに直接 addImages を流す

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:drift/native.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/camera/presentation/camera_capture_controller.dart';
import 'package:tsukaikiri/features/camera/presentation/camera_mobile_view.dart';
import 'package:tsukaikiri/features/recipe/domain/detected_ingredient.dart';
import 'package:tsukaikiri/features/recipe/service/recipe_provider.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

import 'fakes/fake_recipe_provider.dart';

Uint8List _makeJpegBytes() {
  final image = img.Image(width: 4, height: 4);
  img.fill(image, color: img.ColorRgb8(100, 200, 100));
  final encoded = img.encodeJpg(image, quality: 80);
  return Uint8List.fromList(encoded);
}

DetectedIngredient _highConf(String name) => DetectedIngredient(
      name: name,
      estimatedQuantity: 1.0,
      unit: '個',
      confidence: 0.9,
    );

DetectedIngredient _lowConf(String name) => DetectedIngredient(
      name: name,
      estimatedQuantity: 1.0,
      unit: '袋',
      confidence: 0.2, // low: < 0.4
    );

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Future<void> pumpView(
    WidgetTester tester, {
    FakeRecipeProvider? fake,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          recipeProviderProvider.overrideWith((ref) async => fake),
        ],
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CameraMobileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  CameraCaptureController controllerOf(WidgetTester tester) {
    final container = ProviderScope.containerOf(
        tester.element(find.byType(CameraMobileScreen)));
    return container.read(cameraCaptureControllerProvider.notifier);
  }

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(
          tester.element(find.byType(CameraMobileScreen)));

  /// analyzing フェーズ通過後の安定待ち（無限アニメーションがあるため固定回数 pump）。
  Future<void> waitAfterAnalyze(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// drift stream 購読解除の Timer を消化するためアンマウントする。
  Future<void> unmountApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  // ═══════════════════════════════════════════════════════
  // ① capture 初期表示
  // ═══════════════════════════════════════════════════════
  testWidgets('capture 初期表示: タイトル・枚数チップ・追加導線が表示される', (tester) async {
    await pumpView(tester, fake: FakeRecipeProvider());

    expect(find.text('冷蔵庫を撮影'), findsOneWidget);
    expect(find.text('0 / 10 枚'), findsOneWidget);
    expect(find.text('写真を追加'), findsOneWidget);
    // 0 枚なので解析ボタンは無効（テキストは 0枚 表示）
    expect(find.text('0枚を解析する'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ② addImages → サムネイル + 枚数 + 解析ボタン
  // ═══════════════════════════════════════════════════════
  testWidgets('addImages 後: サムネイルと枚数・解析ボタンが更新される', (tester) async {
    await pumpView(tester, fake: FakeRecipeProvider());

    await controllerOf(tester).addImages([_makeJpegBytes()]);
    await tester.pump();

    expect(find.byType(Image), findsWidgets); // サムネイル
    expect(find.text('1 / 10 枚'), findsOneWidget);
    expect(find.text('1枚を解析する'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ③ analyze 成功 → review に候補が並び、低確信度は初期チェックOFF
  // ═══════════════════════════════════════════════════════
  testWidgets('analyze 成功: review に候補が並び低確信度は初期チェックOFF', (tester) async {
    final fake = FakeRecipeProvider(
      recognizeResult: [
        _highConf('牛乳'),
        _lowConf('葉物野菜？'),
      ],
      supportsVisionOverride: true,
    );
    await pumpView(tester, fake: fake);

    final notifier = controllerOf(tester);
    await notifier.addImages([_makeJpegBytes()]);
    await tester.pump();
    await notifier.analyze();
    await waitAfterAnalyze(tester);

    expect(find.text('認識された食材'), findsOneWidget);
    expect(find.text('牛乳'), findsOneWidget);
    expect(find.text('葉物野菜？'), findsOneWidget);
    // サマリ: 2件の候補 ・ 1件を採用（低確信度は初期チェックOFF）
    expect(find.text('2件の候補 ・ 1件を採用'), findsOneWidget);
    // 確定ボタンは checked 1 件
    expect(find.text('確定して追加（1件）'), findsOneWidget);

    // コントローラ状態でもチェック状態を確認する。
    final candidates =
        containerOf(tester).read(cameraCaptureControllerProvider).candidates;
    expect(candidates.first.checked, isTrue);
    expect(candidates.last.checked, isFalse);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ④ confirm → checked のみ在庫 DB に保存され capture に戻る
  // ═══════════════════════════════════════════════════════
  testWidgets('確定で checked の候補のみ在庫に保存され capture に戻る', (tester) async {
    final fake = FakeRecipeProvider(
      recognizeResult: [
        _highConf('牛乳'),
        _lowConf('葉物野菜？'),
      ],
      supportsVisionOverride: true,
    );
    await pumpView(tester, fake: fake);

    final notifier = controllerOf(tester);
    await notifier.addImages([_makeJpegBytes()]);
    await tester.pump();
    await notifier.analyze();
    await waitAfterAnalyze(tester);

    // 確定ボタンをタップする（UI 経由）。
    await tester.tap(find.text('確定して追加（1件）'));
    await waitAfterAnalyze(tester);

    final container = containerOf(tester);
    final saved =
        await container.read(inventoryRepositoryProvider).getInventory();
    expect(saved.length, 1);
    expect(saved.first.name, '牛乳');

    // confirm 後は capture フェーズに戻る。
    expect(
      container.read(cameraCaptureControllerProvider).phase,
      CameraCapturePhase.capture,
    );

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑤ エラー3種の出し分け
  // ═══════════════════════════════════════════════════════
  testWidgets('network エラー: 解析失敗文言と「あとで解析する」', (tester) async {
    final fake = FakeRecipeProvider(
      recognizeError: const RecipeProviderException('gemini', 503, 'error'),
      supportsVisionOverride: true,
    );
    await pumpView(tester, fake: fake);

    final notifier = controllerOf(tester);
    await notifier.addImages([_makeJpegBytes()]);
    await tester.pump();
    await notifier.analyze();
    await waitAfterAnalyze(tester);

    expect(find.text('写真の解析に失敗しました'), findsOneWidget);
    expect(find.text('もう一度試す'), findsOneWidget);
    expect(find.text('あとで解析する'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('noApiKey エラー: 専用文言と「設定を開く」', (tester) async {
    // recipeProviderProvider が null = API キー未登録
    await pumpView(tester, fake: null);

    final notifier = controllerOf(tester);
    await notifier.addImages([_makeJpegBytes()]);
    await tester.pump();
    await notifier.analyze();
    await waitAfterAnalyze(tester);

    expect(find.text('API キーが登録されていません'), findsOneWidget);
    expect(find.text('設定を開く'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('noVision エラー: Vision 非対応文言と「設定を開く」', (tester) async {
    final fake = FakeRecipeProvider(); // supportsVision=false
    await pumpView(tester, fake: fake);

    final notifier = controllerOf(tester);
    await notifier.addImages([_makeJpegBytes()]);
    await tester.pump();
    await notifier.analyze();
    await waitAfterAnalyze(tester);

    expect(find.text('このプロバイダは画像認識に対応していません'), findsOneWidget);
    expect(find.text('設定を開く'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑥ error フェーズで離脱→再入場すると自動リセットされ capture から始まる
  // ═══════════════════════════════════════════════════════
  testWidgets('error で離脱して再入場すると capture にリセットされる', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fake = FakeRecipeProvider(
      recognizeError: const RecipeProviderException('gemini', 503, 'error'),
      supportsVisionOverride: true,
    );
    // 同一コンテナ（= アプリ生存期間のコントローラ状態）を再入場間で共有する。
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      recipeProviderProvider.overrideWith((ref) async => fake),
    ]);
    addTearDown(container.dispose);

    Future<void> pumpScreen() async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('ja'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CameraMobileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // 1回目: 解析失敗で error フェーズに。
    await pumpScreen();
    final notifier =
        container.read(cameraCaptureControllerProvider.notifier);
    await notifier.addImages([_makeJpegBytes()]);
    await tester.pump();
    await notifier.analyze();
    await waitAfterAnalyze(tester);
    expect(container.read(cameraCaptureControllerProvider).phase,
        CameraCapturePhase.error);

    // 離脱（アンマウント）→ 再入場。
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await pumpScreen();

    // error は入場時にリセットされ capture 画面から始まる。
    expect(container.read(cameraCaptureControllerProvider).phase,
        CameraCapturePhase.capture);
    expect(find.text('冷蔵庫を撮影'), findsOneWidget);

    await unmountApp(tester);
  });
}
