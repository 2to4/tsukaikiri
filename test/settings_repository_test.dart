import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/features/settings/data/settings_repository.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepository(db);
  });

  tearDown(() async => db.close());

  test('初期状態はモデル上書きなし・gemini 選択', () async {
    final settings = await repo.get();
    expect(settings.selectedProvider, 'gemini');
    expect(settings.modelOverrides, isEmpty);
  });

  test('setModelOverride で保存し null で解除できる', () async {
    await repo.setModelOverride('grok', 'grok-4.3');
    await repo.setModelOverride('gemini', 'gemini-2.5-pro');
    expect((await repo.get()).modelOverrides,
        {'grok': 'grok-4.3', 'gemini': 'gemini-2.5-pro'});

    await repo.setModelOverride('grok', null);
    expect((await repo.get()).modelOverrides, {'gemini': 'gemini-2.5-pro'});
  });

  test('setModelOverride は他の設定フィールドを壊さない', () async {
    await repo.setSelectedProvider('grok');
    await repo.setModelOverride('grok', 'grok-4.3');
    final settings = await repo.get();
    expect(settings.selectedProvider, 'grok');
    expect(settings.modelOverrides['grok'], 'grok-4.3');
  });

  test('カメラ途中保持・同期失敗時維持の既定は現行挙動（true）', () async {
    final settings = await repo.get();
    expect(settings.cameraPreserveState, isTrue);
    expect(settings.syncKeepOnFailure, isTrue);
  });

  test('setCameraPreserveState / setSyncKeepOnFailure が往復する', () async {
    await repo.setCameraPreserveState(false);
    await repo.setSyncKeepOnFailure(false);
    var settings = await repo.get();
    expect(settings.cameraPreserveState, isFalse);
    expect(settings.syncKeepOnFailure, isFalse);

    await repo.setCameraPreserveState(true);
    settings = await repo.get();
    expect(settings.cameraPreserveState, isTrue);
    // 片方の更新でもう片方が壊れない。
    expect(settings.syncKeepOnFailure, isFalse);
  });
}
