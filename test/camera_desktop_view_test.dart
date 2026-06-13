// camera_desktop_view_test.dart
// M6 カメラ登録ビューの widget テスト。
// CLAUDE.md の規約に従い:
//   - インメモリ DB・1280×800・unmountApp 必須
//   - analyzing の無限アニメーションを pumpAndSettle に通さない（pump を固定回数）
//   - ピッカー/ドロップは UI 統合テスト不能のため、コントローラに直接 addImages を流す

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:drift/native.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/camera/presentation/camera_capture_controller.dart';
import 'package:tsukaikiri/features/camera/presentation/camera_desktop_view.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/recipe/domain/detected_ingredient.dart';
import 'package:tsukaikiri/features/recipe/service/recipe_provider.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

import 'fakes/fake_recipe_provider.dart';

// ──────────────────────────────────────────────────────────────
// ヘルパー: 4×4 px の最小 JPEG バイト列を生成する
// ──────────────────────────────────────────────────────────────

Uint8List _makeJpegBytes() {
  final image = img.Image(width: 4, height: 4);
  img.fill(image, color: img.ColorRgb8(100, 200, 100));
  final encoded = img.encodeJpg(image, quality: 80);
  return Uint8List.fromList(encoded);
}

// ──────────────────────────────────────────────────────────────
// テスト用 DetectedIngredient 候補
// ──────────────────────────────────────────────────────────────

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

  // ──────────────────────────────────────────────────────────────
  // pump ヘルパー
  // ──────────────────────────────────────────────────────────────

  Future<void> pumpView(
    WidgetTester tester,
    FakeRecipeProvider fake,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
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
          home: Scaffold(body: CameraDesktopView()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// analyzing フェーズを通過した後に状態が安定するまで待つ。
  /// 無限アニメーション（analyzing）があるため pumpAndSettle は analyze 完了後のみ使用。
  /// analyze() は非同期で Fake はすぐに返すため、固定回数 pump で十分に進む。
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
  testWidgets('capture 初期表示: ドロップゾーン文言が表示される', (tester) async {
    await pumpView(tester, FakeRecipeProvider());

    expect(find.text('写真をドロップ、または クリックして選択'), findsOneWidget);
    expect(find.text('冷蔵庫の写真を最大10枚追加できます'), findsOneWidget);
    // 解析ボタンは 0 枚なので表示されない
    expect(find.textContaining('枚を解析する'), findsNothing);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ①' AI 非対応端末（provider 解決不可）ではカメラ登録を無効化し案内
  // ═══════════════════════════════════════════════════════
  testWidgets('AI 非対応端末ではカメラ登録を無効化し案内を表示する', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          recipeProviderProvider.overrideWith((ref) async => null),
        ],
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CameraDesktopView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 案内が表示され、ドロップゾーンは出ない。
    expect(find.text('AI を利用できません'), findsOneWidget);
    expect(find.text('写真をドロップ、または クリックして選択'), findsNothing);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ② addImages → サムネイル + 解析ボタン表示
  // ═══════════════════════════════════════════════════════
  testWidgets('addImages 後: サムネイルと解析ボタンが表示される', (tester) async {
    await pumpView(tester, FakeRecipeProvider());

    // コントローラに直接画像を注入する。
    final container = ProviderScope.containerOf(tester.element(find.byType(CameraDesktopView)));
    await container.read(cameraCaptureControllerProvider.notifier).addImages([_makeJpegBytes()]);
    await tester.pump();

    // サムネイル（Image.memory）が1枚
    expect(find.byType(Image), findsWidgets);
    // 解析ボタン
    expect(find.text('1枚を解析する ⌘R'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ③ analyze 成功 → review フェーズで候補が並ぶ
  //    低確信度は初期チェック OFF
  // ═══════════════════════════════════════════════════════
  testWidgets('analyze 成功: review に候補が並び、低確信度は初期チェックOFF', (tester) async {
    final fake = FakeRecipeProvider(
      recognizeResult: [
        _highConf('牛乳'),
        _highConf('卵'),
        _lowConf('葉物野菜？'),
      ],
      supportsVisionOverride: true,
    );
    await pumpView(tester, fake);

    final container = ProviderScope.containerOf(tester.element(find.byType(CameraDesktopView)));
    await container.read(cameraCaptureControllerProvider.notifier).addImages([_makeJpegBytes()]);
    await tester.pump();

    // analyze を呼び出す（⌘R と同等）。
    await container.read(cameraCaptureControllerProvider.notifier).analyze();
    await waitAfterAnalyze(tester);

    // 候補リストヘッダー
    expect(find.textContaining('認識された食材'), findsOneWidget);
    // 各候補名
    expect(find.text('牛乳'), findsWidgets); // リスト行 + 編集ペイン
    expect(find.text('卵'), findsOneWidget);
    expect(find.text('葉物野菜？'), findsOneWidget);

    // チェック状態を Checkbox ウィジェットで確認する。
    // 高確信度（牛乳・卵）: checked=true、低確信度（葉物野菜？）: checked=false。
    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
    // 3候補 × 1 チェックボックス
    expect(checkboxes.length, 3);

    // 低確信度行（最後の行）は false
    expect(checkboxes.last.value, isFalse);
    // 高確信度行は true
    expect(checkboxes.first.value, isTrue);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ④ 候補編集が反映される
  // ═══════════════════════════════════════════════════════
  testWidgets('候補の名前編集がコントローラ状態に反映される', (tester) async {
    final fake = FakeRecipeProvider(
      recognizeResult: [_highConf('牛乳')],
      supportsVisionOverride: true,
    );
    await pumpView(tester, fake);

    final container = ProviderScope.containerOf(tester.element(find.byType(CameraDesktopView)));
    await container.read(cameraCaptureControllerProvider.notifier).addImages([_makeJpegBytes()]);
    await tester.pump();
    await container.read(cameraCaptureControllerProvider.notifier).analyze();
    await waitAfterAnalyze(tester);

    // 候補の名前を updateCandidate で直接変更する。
    final candidates = container.read(cameraCaptureControllerProvider).candidates;
    expect(candidates, isNotEmpty);
    final id = candidates.first.id;
    container.read(cameraCaptureControllerProvider.notifier).updateCandidate(
      id: id,
      name: '有機牛乳',
    );
    await tester.pump();

    // 変更が状態に反映されている。
    final updated = container.read(cameraCaptureControllerProvider).candidates.first;
    expect(updated.name, '有機牛乳');

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑤ confirm → 在庫 DB に checked 分だけ保存され capture に戻る
  //    normalizedName・期限自動セットの確認
  // ═══════════════════════════════════════════════════════
  testWidgets('confirm: checked の候補のみ在庫に保存され capture に戻る', (tester) async {
    final fake = FakeRecipeProvider(
      recognizeResult: [
        _highConf('牛乳'),   // high -> checked=true
        _lowConf('葉物野菜？'), // low  -> checked=false
      ],
      supportsVisionOverride: true,
    );
    await pumpView(tester, fake);

    final container = ProviderScope.containerOf(tester.element(find.byType(CameraDesktopView)));
    await container.read(cameraCaptureControllerProvider.notifier).addImages([_makeJpegBytes()]);
    await tester.pump();
    await container.read(cameraCaptureControllerProvider.notifier).analyze();
    await waitAfterAnalyze(tester);

    // confirm 実行。
    await container.read(cameraCaptureControllerProvider.notifier).confirm();
    await tester.pump();

    // 在庫 DB を直接確認する（stream ではなく getInventory 一発クエリ）。
    final repo = container.read(inventoryRepositoryProvider);
    final saved = await repo.getInventory();

    // 保存されたのは checked=true の牛乳のみ（低確信度は除外）。
    expect(saved.length, 1);
    expect(saved.first.name, '牛乳');

    // normalizedName は AI からのキー未提供のため name 流用。
    expect(saved.first.normalizedName, '牛乳');

    // expiryDate は category=other なので null（defaultExpiryFrom は other を返さない）。
    // ※ カテゴリ推測が other のため expiryDate は null 固定。
    expect(saved.first.expiryDate, isNull);

    // confirm 後は capture フェーズに戻る。
    final phase = container.read(cameraCaptureControllerProvider).phase;
    expect(phase, CameraCapturePhase.capture);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑤-b カテゴリを meat に変更してから confirm → 期限自動セット
  // ═══════════════════════════════════════════════════════
  testWidgets('confirm: meat カテゴリで期限自動セット（3日後）', (tester) async {
    final fake = FakeRecipeProvider(
      recognizeResult: [_highConf('鶏もも肉')],
      supportsVisionOverride: true,
    );
    await pumpView(tester, fake);

    final container = ProviderScope.containerOf(tester.element(find.byType(CameraDesktopView)));
    await container.read(cameraCaptureControllerProvider.notifier).addImages([_makeJpegBytes()]);
    await tester.pump();
    await container.read(cameraCaptureControllerProvider.notifier).analyze();
    await waitAfterAnalyze(tester);

    // カテゴリを meat に変更する。
    final id = container.read(cameraCaptureControllerProvider).candidates.first.id;
    container.read(cameraCaptureControllerProvider.notifier).updateCandidate(
      id: id,
      category: IngredientCategory.meat,
    );

    await container.read(cameraCaptureControllerProvider.notifier).confirm();
    await tester.pump();

    final repo = container.read(inventoryRepositoryProvider);
    final saved = await repo.getInventory();
    expect(saved.length, 1);

    // meat の期限目安は 3 日後。
    final expiry = saved.first.expiryDate;
    expect(expiry, isNotNull);
    final today = DateTime.now();
    final expectedExpiry = DateTime(today.year, today.month, today.day)
        .add(const Duration(days: 3));
    expect(expiry, expectedExpiry);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑥ recognizeError → エラーフェーズに遷移してエラー文言が表示
  // ═══════════════════════════════════════════════════════
  testWidgets('recognizeError: エラーフェーズに遷移しエラー文言が表示される', (tester) async {
    final fake = FakeRecipeProvider(
      recognizeError: const RecipeProviderException('gemini', 503, 'error'),
      supportsVisionOverride: true,
    );
    await pumpView(tester, fake);

    final container = ProviderScope.containerOf(tester.element(find.byType(CameraDesktopView)));
    await container.read(cameraCaptureControllerProvider.notifier).addImages([_makeJpegBytes()]);
    await tester.pump();
    await container.read(cameraCaptureControllerProvider.notifier).analyze();
    await waitAfterAnalyze(tester);

    // エラーフェーズに遷移している。
    final phase = container.read(cameraCaptureControllerProvider).phase;
    expect(phase, CameraCapturePhase.error);

    // ネットワークエラー文言が表示される。
    expect(find.text('写真の解析に失敗しました'), findsOneWidget);
    // 再試行ボタン
    expect(find.text('もう一度試す'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑦ noApiKey エラー: 適切なメッセージと設定ボタン
  // ═══════════════════════════════════════════════════════
  testWidgets('noApiKey: 専用エラーメッセージと設定を開くボタンが表示される', (tester) async {
    // recipeProviderProvider が null を返す = API キー未登録
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          recipeProviderProvider.overrideWith((ref) async => null),
        ],
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CameraDesktopView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(tester.element(find.byType(CameraDesktopView)));
    await container.read(cameraCaptureControllerProvider.notifier).addImages([_makeJpegBytes()]);
    await tester.pump();
    await container.read(cameraCaptureControllerProvider.notifier).analyze();
    await waitAfterAnalyze(tester);

    expect(find.text('API キーが登録されていません'), findsOneWidget);
    expect(find.text('設定を開く'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑧ noVision エラー: 適切なメッセージと設定ボタン
  // ═══════════════════════════════════════════════════════
  testWidgets('noVision: Vision 非対応エラーメッセージが表示される', (tester) async {
    // supportsVision=false (デフォルト)、recognizeResult=null
    final fake = FakeRecipeProvider(); // supportsVision=false
    await pumpView(tester, fake);

    final container = ProviderScope.containerOf(tester.element(find.byType(CameraDesktopView)));
    await container.read(cameraCaptureControllerProvider.notifier).addImages([_makeJpegBytes()]);
    await tester.pump();
    await container.read(cameraCaptureControllerProvider.notifier).analyze();
    await waitAfterAnalyze(tester);

    expect(find.text('このプロバイダは画像認識に対応していません'), findsOneWidget);
    expect(find.text('設定を開く'), findsOneWidget);

    await unmountApp(tester);
  });
}
