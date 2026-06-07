import '../../../core/db/app_database.dart';

/// アプリ設定（単一レコード）へのアクセス。最小版は locale のみ。
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const _rowId = 0;

  Future<String> getLocalePref() async {
    final row = await (_db.select(_db.settingsTable)
          ..where((t) => t.id.equals(_rowId)))
        .getSingleOrNull();
    return row?.localePref ?? 'system';
  }

  Future<void> setLocalePref(String pref) async {
    await _db.into(_db.settingsTable).insertOnConflictUpdate(
          AppSettings(id: _rowId, localePref: pref),
        );
  }
}
