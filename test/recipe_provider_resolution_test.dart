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

  test('② クラウド選択でキー無し + オンデバイス可 → オンデバイス', () async {
    final p = await resolve(
      selectedProvider: 'gemini',
      keys: const {},
      availability: available,
    );
    expect(p, isA<OnDeviceRecipeProvider>());
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
}
