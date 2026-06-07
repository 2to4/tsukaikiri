import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/inventory/domain/ingredient_category.dart';

part 'app_database.g.dart';

/// 在庫食材テーブル。生成されるデータクラスは [Ingredient]。
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

  /// 賞味期限は任意（カテゴリ目安で初期値、手動修正可、空のままも可）。
  DateTimeColumn get expiryDate => dateTime().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// アプリ設定（単一レコード, id=0 固定）。最小版は locale のみ。
@DataClassName('AppSettings')
class SettingsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// 'ja' / 'en' / 'system'
  TextColumn get localePref => text().withDefault(const Constant('system'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Ingredients, SettingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'tsukaikiri'));

  @override
  int get schemaVersion => 1;
}
