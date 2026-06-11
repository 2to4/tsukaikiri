// 賞味期限目安データ生成スクリプト（純 Dart CLI・Flutter 非依存）。
//
//   dart run tool/shelf_life/generate.dart
//
// 入力:
//   tool/shelf_life/foodkeeper_ingredients.csv  … FoodKeeper ミラー CSV
//   tool/shelf_life/ja_mapping.json             … 日本語マッピング + 和食材補完
// 出力:
//   assets/shelf_life/shelf_life_rules.json     … 実行時に同梱・参照する目安データ
//
// 冪等: 同じ入力に対しては常に同じ出力（再実行で git diff なし）。
//
// 公式 FoodKeeper 最新版への差し替え手順は tool/shelf_life/README.md を参照。
import 'dart:convert';
import 'dart:io';

import 'shelf_life_compute.dart';

void main(List<String> args) {
  final root = _repoRoot();
  final csvPath = '$root/tool/shelf_life/foodkeeper_ingredients.csv';
  final mappingPath = '$root/tool/shelf_life/ja_mapping.json';
  final outPath = '$root/assets/shelf_life/shelf_life_rules.json';

  final csvRows = parseCsv(File(csvPath).readAsStringSync());
  final header = csvRows.first;
  final dataRows = csvRows
      .skip(1)
      .map((cells) => rowToMap(header, cells))
      .toList(growable: false);

  final mapping = jsonDecode(File(mappingPath).readAsStringSync())
      as Map<String, dynamic>;

  final rules = <Map<String, Object>>[];
  final warnings = <String>[];

  // --- FoodKeeper 由来 ---
  for (final raw in (mapping['foodkeeper'] as List)) {
    final entry = raw as Map<String, dynamic>;
    final key = entry['normalizedKey'] as String;
    final match = entry['match'] as Map<String, dynamic>;
    final matched = matchRows(
      dataRows,
      match['name'] as String,
      match['subtitle'] as String?,
    );
    if (matched.length != 1) {
      warnings.add(
        'foodkeeper "$key": match が ${matched.length} 行（期待 1）'
        ' name=${match['name']} subtitle=${match['subtitle']}',
      );
      continue;
    }
    final days = daysForRow(matched.single);
    if (days == null) {
      warnings.add('foodkeeper "$key": 数値化できる保存日数が無いためスキップ');
      continue;
    }
    rules.add(_rule(
      normalizedKey: key,
      aliases: (entry['aliases'] as List).cast<String>(),
      category: entry['category'] as String,
      days: days,
      source: 'foodkeeper',
    ));
  }

  // --- 和食材補完 ---
  for (final raw in (mapping['supplement'] as List)) {
    final entry = raw as Map<String, dynamic>;
    rules.add(_rule(
      normalizedKey: entry['normalizedKey'] as String,
      aliases: (entry['aliases'] as List).cast<String>(),
      category: entry['category'] as String,
      days: entry['days'] as int,
      source: 'supplement',
    ));
  }

  // 安定した順序（normalizedKey 昇順）でソートし冪等にする。
  rules.sort((a, b) =>
      (a['normalizedKey'] as String).compareTo(b['normalizedKey'] as String));

  final output = <String, Object>{
    'schemaVersion': 1,
    'source': 'USDA FoodKeeper (2019-06 mirror) + Japanese supplement',
    'generatedBy': 'tool/shelf_life/generate.dart',
    'rules': rules,
  };

  final outFile = File(outPath);
  outFile.parent.createSync(recursive: true);
  outFile.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(output)}\n');

  stdout.writeln('生成: $outPath');
  stdout.writeln('  ルール数: ${rules.length}'
      ' (foodkeeper ${rules.where((r) => r['source'] == 'foodkeeper').length}'
      ' + supplement ${rules.where((r) => r['source'] == 'supplement').length})');
  for (final w in warnings) {
    stdout.writeln('  warning: $w');
  }
}

/// 1 ルールを生成する（キー順を安定させるため明示的に構築）。
Map<String, Object> _rule({
  required String normalizedKey,
  required List<String> aliases,
  required String category,
  required int days,
  required String source,
}) {
  return {
    'normalizedKey': normalizedKey,
    'aliases': aliases,
    'category': category,
    'days': days,
    'source': source,
  };
}

/// このスクリプトの位置からリポジトリルートを求める（tool/shelf_life の 2 つ上）。
String _repoRoot() {
  final scriptDir = File(Platform.script.toFilePath()).parent; // tool/shelf_life
  return scriptDir.parent.parent.path;
}
