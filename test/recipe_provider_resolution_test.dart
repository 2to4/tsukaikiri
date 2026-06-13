import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/recipe/service/on_device_recipe_provider.dart';
import 'package:tsukaikiri/features/recipe/service/gemini_provider.dart';
import 'package:tsukaikiri/features/recipe/service/on_device_ai_service.dart';
import 'package:tsukaikiri/features/settings/data/settings_repository.dart';

import 'fakes/fake_secure_storage.dart';

/// availability を固定で返すオンデバイスサービスのフェイク。
class _FakeOnDeviceAiService extends OnDeviceAiService {
  _FakeOnDeviceAiService(this._availability);
  final OnDeviceAiAvailability _availability;

  @override
  Future<OnDeviceAiAvailability> availability() async => _availability;

  @override
  Future<String> generate({
    required String prompt,
    List<Uint8List> images = const [],
  }) async =>
      '{}';
}

void main() {
  /// 設定とキーとオンデバイス可否を与えて recipeProviderProvider を解決する。
  Future<Object?> resolve({
    String? selectedProvider,
    Map<String, String> keys = const {},
    required OnDeviceAiAvailability availability,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    if (selectedProvider != null) {
      await SettingsRepository(db).setSelectedProvider(selectedProvider);
    }
    final storage = FakeSecureStorage()..store.addAll(keys);
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      secureStorageProvider.overrideWithValue(storage),
      onDeviceAiServiceProvider
          .overrideWithValue(_FakeOnDeviceAiService(availability)),
    ]);
    addTearDown(container.dispose);
    return container.read(recipeProviderProvider.future);
  }

  const available =
      OnDeviceAiAvailability(available: true, supportsVision: false);
  const unavailable = OnDeviceAiAvailability.unavailable;

  test('① クラウド選択＆キー有り → そのクラウドプロバイダ', () async {
    final p = await resolve(
      selectedProvider: 'gemini',
      keys: {'gemini': 'KEY'},
      availability: available,
    );
    expect(p, isA<GeminiProvider>());
  });

  test('② クラウド選択でキー無し → null（オンデバイスへ無言フォールバックしない）',
      () async {
    // オンデバイスが使えても、クラウド選択＋キー無しはオンデバイスに落とさない。
    final p = await resolve(
      selectedProvider: 'gemini',
      keys: const {},
      availability: available,
    );
    expect(p, isNull);
  });

  test('③ ondevice 選択 + オンデバイス可 → オンデバイス（vision を引き継ぐ）', () async {
    final p = await resolve(
      selectedProvider: 'ondevice',
      availability:
          const OnDeviceAiAvailability(available: true, supportsVision: true),
    );
    expect(p, isA<OnDeviceRecipeProvider>());
    expect((p as OnDeviceRecipeProvider).supportsVision, isTrue);
  });

  test('④ クラウド選択でキー無し + オンデバイス不可 → null', () async {
    final p = await resolve(
      selectedProvider: 'gemini',
      keys: const {},
      availability: unavailable,
    );
    expect(p, isNull);
  });

  test('⑤ ondevice 選択 + オンデバイス不可 → null', () async {
    final p = await resolve(
      selectedProvider: 'ondevice',
      availability: unavailable,
    );
    expect(p, isNull);
  });

  // ── AI 可否ゲーティング（aiAvailableProvider / aiVisionAvailableProvider） ──
  // カメラ入口は vision 対応で出し分ける（指摘 #1）。AI が使えても vision 非対応
  // （オンデバイス既定）の端末でカメラ入口を開かないことを守る。

  Future<({bool ai, bool vision, AiStatus status})> resolveGating({
    String? selectedProvider,
    Map<String, String> keys = const {},
    required OnDeviceAiAvailability availability,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    if (selectedProvider != null) {
      await SettingsRepository(db).setSelectedProvider(selectedProvider);
    }
    final storage = FakeSecureStorage()..store.addAll(keys);
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      secureStorageProvider.overrideWithValue(storage),
      onDeviceAiServiceProvider
          .overrideWithValue(_FakeOnDeviceAiService(availability)),
    ]);
    addTearDown(container.dispose);
    final ai = await container.read(aiAvailableProvider.future);
    final vision = await container.read(aiVisionAvailableProvider.future);
    final status = await container.read(aiStatusProvider.future);
    return (ai: ai, vision: vision, status: status);
  }

  test('⑥ オンデバイス可・vision 非対応 → AI 可だが vision 不可（カメラ入口を閉じる）',
      () async {
    final r = await resolveGating(
      selectedProvider: 'ondevice',
      availability: available, // supportsVision: false
    );
    expect(r.ai, isTrue);
    expect(r.vision, isFalse);
    expect(r.status, AiStatus.available);
  });

  test('⑦ オンデバイス可・vision 対応 → AI も vision も可', () async {
    final r = await resolveGating(
      selectedProvider: 'ondevice',
      availability:
          const OnDeviceAiAvailability(available: true, supportsVision: true),
    );
    expect(r.ai, isTrue);
    expect(r.vision, isTrue);
    expect(r.status, AiStatus.available);
  });

  test('⑧ オンデバイス不可・キー無し → AI も vision も不可（unavailable）', () async {
    final r = await resolveGating(
      selectedProvider: 'ondevice',
      availability: unavailable,
    );
    expect(r.ai, isFalse);
    expect(r.vision, isFalse);
    expect(r.status, AiStatus.unavailable);
  });

  test('⑨ クラウド選択＋キー無し → AI 不可・status は cloudKeyMissing', () async {
    // オンデバイスが使えても cloudKeyMissing（無言フォールバックしない）。
    final r = await resolveGating(
      selectedProvider: 'gemini',
      keys: const {},
      availability: available,
    );
    expect(r.ai, isFalse);
    expect(r.vision, isFalse);
    expect(r.status, AiStatus.cloudKeyMissing);
  });
}
