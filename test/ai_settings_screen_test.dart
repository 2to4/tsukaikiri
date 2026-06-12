// ai_settings_screen_test.dart
// AI 設定（モバイル）の widget テスト。
// settings_desktop_view_test.dart の AI セクションテストと同じ観点:
// プロバイダ選択・API キー保存/マスク・モデル取得のキー前提。

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/core/secure_storage/secure_storage_service.dart';
import 'package:tsukaikiri/features/settings/presentation/ai_settings_screen.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

class _FakeSecureStorage extends SecureStorageService {
  _FakeSecureStorage() : super();
  final Map<String, String> store = {};

  @override
  Future<String?> getApiKey(String provider) async => store[provider];

  @override
  Future<void> setApiKey(String provider, String apiKey) async =>
      store[provider] = apiKey;

  @override
  Future<void> deleteApiKey(String provider) async => store.remove(provider);

  @override
  Future<bool> hasApiKey(String provider) async {
    final k = store[provider];
    return k != null && k.isNotEmpty;
  }
}

void main() {
  late AppDatabase db;
  late _FakeSecureStorage secure;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    secure = _FakeSecureStorage();
  });

  tearDown(() async => db.close());

  Future<ProviderContainer> pumpView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          secureStorageProvider.overrideWithValue(secure),
        ],
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AiSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
        tester.element(find.byType(AiSettingsScreen)));
  }

  Future<void> unmountApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('プロバイダ4社が表示され、タップで選択が切り替わる', (tester) async {
    final container = await pumpView(tester);

    expect(find.text('Gemini'), findsWidgets); // 行 + 取得リンク内
    expect(find.text('Grok'), findsOneWidget);
    expect(find.text('OpenAI'), findsOneWidget);
    expect(find.text('Claude'), findsOneWidget);

    // Claude をタップすると設定が切り替わる。
    await tester.tap(find.text('Claude'));
    await tester.pumpAndSettle();

    final settings = await container.read(settingsRepositoryProvider).get();
    expect(settings.selectedProvider, 'claude');

    await unmountApp(tester);
  });

  testWidgets('API キーを保存するとマスク表示になり SecureStorage に書かれる', (tester) async {
    await pumpView(tester);

    await tester.enterText(
        find.byType(TextField), 'sk-test-1234567890abcd');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 既定プロバイダ（gemini）のキーとして保存される。
    expect(secure.store['gemini'], 'sk-test-1234567890abcd');
    // マスク表示（先頭6+末尾4）
    expect(find.textContaining('sk-tes…abcd'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('キー未登録: モデルセクションはキーが必要の案内を出す', (tester) async {
    await pumpView(tester);

    expect(
      find.text('モデルを取得するには先に APIキーを保存してください。'),
      findsOneWidget,
    );

    await unmountApp(tester);
  });

  testWidgets('キー登録済み: 保存済みマスクとモデル取得ボタンが出る', (tester) async {
    secure.store['gemini'] = 'AIzaSyTest1234567890';
    await pumpView(tester);

    expect(find.textContaining('保存済み'), findsOneWidget);
    expect(find.text('モデルを取得'), findsOneWidget);

    await unmountApp(tester);
  });
}
