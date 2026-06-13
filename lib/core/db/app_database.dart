import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/inventory/domain/ingredient_category.dart';

part 'app_database.g.dart';

/// 在庫食材テーブル。
/// 主キーは将来のクラウド同期での競合回避のため UUID（String）。
class Ingredients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// 名寄せキー（言語非依存）。AI 連携前は name を流用し、AI 実装後にバックフィルする。
  TextColumn get normalizedName => text()();

  /// 列挙子名で保存（言語非依存の固定キー）。
  TextColumn get category => textEnum<IngredientCategory>()();

  /// 数量は小数許可。
  RealColumn get quantity => real()();

  /// 定義済み単位は [UnitOption] の列挙子名、カスタムは自由文字列。
  TextColumn get unit => text()();

  /// 賞味期限は任意。
  DateTimeColumn get expiryDate => dateTime().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// アプリ設定（単一レコード, id=0 固定）。
@DataClassName('AppSettings')
class SettingsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// 'ja' / 'en' / 'system'
  TextColumn get localePref => text().withDefault(const Constant('system'))();

  // ---- 買い物リスト連携 ----

  /// macOS/iOS=calendarIdentifier / Android=tasklist id
  TextColumn get shoppingListId => text().nullable()();

  /// UI 表示用リスト名（識別子で引き当てた現在名）
  TextColumn get shoppingListName => text().nullable()();

  // ---- AI プロバイダ ----

  /// 'gemini' / 'claude' / 'openai' / 'grok'
  TextColumn get selectedProvider =>
      text().withDefault(const Constant('gemini'))();

  /// プロバイダごとのモデル上書き（JSON オブジェクト）。
  /// {"gemini":"gemini-2.0-flash", ...} の形式。未指定のプロバイダは
  /// 実装側のフォールバック既定値を使う。選択肢は各社のモデル一覧 API から取得。
  TextColumn get modelOverridesJson =>
      text().withDefault(const Constant('{}'))();

  // ---- 同期 ----

  BoolColumn get syncEnabled =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  // ---- 所有家電 (JSON 配列) ----

  /// [{"type":"hotcook","capacity":"2.4L"}, ...] の形式で保存。
  TextColumn get appliancesJson =>
      text().withDefault(const Constant('[]'))();

  // ---- カメラ/同期 UX 基盤 ----
  // どちらも既定は現行挙動: カメラは途中状態を保持、同期は失敗しても ON 維持。
  BoolColumn get cameraPreserveState =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get syncKeepOnFailure =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Ingredients, SettingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'tsukaikiri'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(settingsTable, settingsTable.shoppingListId);
            await m.addColumn(settingsTable, settingsTable.shoppingListName);
            await m.addColumn(settingsTable, settingsTable.selectedProvider);
            await m.addColumn(settingsTable, settingsTable.syncEnabled);
            await m.addColumn(settingsTable, settingsTable.lastSyncedAt);
            await m.addColumn(settingsTable, settingsTable.appliancesJson);
          }
          if (from < 3) {
            await m.addColumn(settingsTable, settingsTable.modelOverridesJson);
          }
          if (from < 4) {
            await m.addColumn(settingsTable, settingsTable.cameraPreserveState);
            await m.addColumn(settingsTable, settingsTable.syncKeepOnFailure);
          }
        },
      );
}
