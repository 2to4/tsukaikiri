import 'package:drift/drift.dart' hide isNull, isNotNull;
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

  test('1. setSyncEnabled/getRow でロジック確認', () async {
    await repo.setSyncEnabled(true);
    final row = await repo.getRow();
    expect(row, isNotNull);
    expect(row!.syncEnabled, isTrue);

    await repo.setSyncEnabled(false);
    final row2 = await repo.getRow();
    expect(row2!.syncEnabled, isFalse);
  });

  test('2. replaceSettings で設定を上書きできる', () async {
    // 初期設定
    await repo.setSelectedProvider('gemini');
    await repo.setSyncEnabled(true);

    // 復元用の companion
    const companion = SettingsTableCompanion(
      id: Value(0),
      localePref: Value('en'),
      shoppingListId: Value(null),
      shoppingListName: Value(null),
      selectedProvider: Value('grok'),
      modelOverridesJson: Value('{}'),
      syncEnabled: Value(false),
      lastSyncedAt: Value(null),
      appliancesJson: Value('[]'),
    );

    await repo.replaceSettings(companion);
    final settings = await repo.get();

    expect(settings.localePref, 'en');
    expect(settings.selectedProvider, 'grok');
    expect(settings.syncEnabled, isFalse);
  });

  test('3. setLastSyncedAt で日時を保存できる', () async {
    final dt = DateTime(2026, 6, 11, 12, 0, 0);
    await repo.setLastSyncedAt(dt);

    final row = await repo.getRow();
    expect(row, isNotNull);
    // タイムゾーンによる差異を避けるため epochMilliseconds で比較
    expect(
      row!.lastSyncedAt?.millisecondsSinceEpoch,
      dt.millisecondsSinceEpoch,
    );
  });

  test('4. setLastSyncedAt(null) で null に戻せる', () async {
    await repo.setLastSyncedAt(DateTime(2026, 6, 11));
    await repo.setLastSyncedAt(null);

    final row = await repo.getRow();
    expect(row!.lastSyncedAt, isNull);
  });
}
