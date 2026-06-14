import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/sync/domain/backup_codec.dart';

void main() {
  // サンプル食材
  Ingredient sampleIngredient({
    String id = 'ing-1',
    String name = 'にんじん',
  }) =>
      Ingredient(
        id: id,
        name: name,
        normalizedName: name,
        category: IngredientCategory.vegetable,
        quantity: 2.0,
        unit: '本',
        expiryDate: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 6, 11),
      );

  // サンプル設定
  AppSettings sampleSettings() => const AppSettings(
        id: 0,
        localePref: 'ja',
        shoppingListId: null,
        shoppingListName: null,
        selectedProvider: 'gemini',
        modelOverridesJson: '{}',
        syncEnabled: true,
        lastSyncedAt: null,
        appliancesJson: '[]',
        cameraPreserveState: false,
        syncKeepOnFailure: true,
      );

  test('1. ラウンドトリップ（encode → decode → 同じデータ）', () {
    final ingredients = [sampleIngredient()];
    final settings = sampleSettings();

    final json = BackupCodec.encodeBackup(
      ingredients: ingredients,
      settings: settings,
    );
    final data = BackupCodec.decodeBackup(json);

    expect(data.ingredients.length, 1);
    expect(data.ingredients.first.id, 'ing-1');
    expect(data.ingredients.first.name, 'にんじん');
    expect(data.ingredients.first.category, IngredientCategory.vegetable);
    expect(data.settingsCompanion.localePref.value, 'ja');
    expect(data.settingsCompanion.selectedProvider.value, 'gemini');
  });

  test('1b. 未知/旧版の selectedProvider は gemini にフォールバックして復元する', () {
    // 旧版・破損バックアップ由来の未知 providerId を復元してもクラッシュせず、
    // 既知のプロバイダ（gemini）に縮退する（restore 耐性・c9235b4 の回帰防止）。
    const settings = AppSettings(
      id: 0,
      localePref: 'ja',
      shoppingListId: null,
      shoppingListName: null,
      selectedProvider: 'legacy_unknown_xyz',
      modelOverridesJson: '{}',
      syncEnabled: false,
      lastSyncedAt: null,
      appliancesJson: '[]',
      cameraPreserveState: true,
      syncKeepOnFailure: true,
    );
    final json = BackupCodec.encodeBackup(
      ingredients: [sampleIngredient()],
      settings: settings,
    );
    final data = BackupCodec.decodeBackup(json);
    expect(data.settingsCompanion.selectedProvider.value, 'gemini');
  });

  test('2. API キー非含有（encode 結果に "api_key" が含まれない）', () {
    final json = BackupCodec.encodeBackup(
      ingredients: [sampleIngredient()],
      settings: sampleSettings(),
    );
    expect(json.contains('api_key'), isFalse);
  });

  test('3. formatVersion 不一致 → newer_version エラー', () {
    // formatVersion を現在のバージョンより大きい値に設定
    const invalidJson = '{'
        '"formatVersion": 9999,'
        '"appDbSchemaVersion": 3,'
        '"exportedAt": "2026-06-11T00:00:00.000Z",'
        '"ingredients": [],'
        '"settings": {'
        '"localePref": "ja",'
        '"shoppingListId": null,'
        '"shoppingListName": null,'
        '"selectedProvider": "gemini",'
        '"modelOverridesJson": "{}",'
        '"syncEnabled": false,'
        '"lastSyncedAt": null,'
        '"appliancesJson": "[]"'
        '}'
        '}';

    expect(
      () => BackupCodec.decodeBackup(invalidJson),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.code,
          'code',
          'newer_version',
        ),
      ),
    );
  });

  test('4. formatVersion 欠落 → invalid_format エラー', () {
    const invalidJson = '{'
        '"appDbSchemaVersion": 3,'
        '"exportedAt": "2026-06-11T00:00:00.000Z",'
        '"ingredients": [],'
        '"settings": {}'
        '}';

    expect(
      () => BackupCodec.decodeBackup(invalidJson),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.code,
          'code',
          'invalid_format',
        ),
      ),
    );
  });

  test('5. ingredients フィールド欠落 → missing_field エラー', () {
    const invalidJson = '{'
        '"formatVersion": 1,'
        '"appDbSchemaVersion": 3,'
        '"exportedAt": "2026-06-11T00:00:00.000Z",'
        '"settings": {}'
        '}';

    expect(
      () => BackupCodec.decodeBackup(invalidJson),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.code,
          'code',
          'missing_field',
        ),
      ),
    );
  });
}
