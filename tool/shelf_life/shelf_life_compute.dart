// generate.dart のコア計算ロジック（純 Dart・テスト対象）。
// Flutter 非依存。test/ からも import される。

/// Metric 文字列 → 1単位あたりの日数。小文字で比較する。
/// 数値化できない Metric（"Package use-by date" / "When Ripe" /
/// "Indefinitely" / "Not Recommended" 等）はここに無いので null 扱いになる。
const Map<String, int> metricToDays = {
  'days': 1,
  'weeks': 7,
  'months': 30,
  'years': 365,
};

/// CSV 行の保存源（優先順）。Refrigerate を最優先し、無ければ
/// 購入日起算（DOP）→ 常温（Pantry）→ 常温 DOP の順にフォールバックする。
const List<String> sourcePrefixes = [
  'Refrigerate',
  'DOP_Refrigerate',
  'Pantry',
  'DOP_Pantry',
];

/// Min/Max/Metric の 1 組から日数を計算する。数値化できなければ null。
/// 中央値 = round((min+max)/2 * metricFactor)。下限 1 日。
int? daysFromSource(String? min, String? max, String? metric) {
  final factor = metricToDays[(metric ?? '').trim().toLowerCase()];
  if (factor == null) return null;
  final lo = double.tryParse((min ?? '').trim());
  final hi = double.tryParse((max ?? '').trim());
  if (lo == null || hi == null) return null;
  final mid = (lo + hi) / 2.0;
  final days = (mid * factor).round();
  return days < 1 ? 1 : days;
}

/// CSV 行（列名→値の Map）から保存日数を求める。優先源を順に試し、
/// 数値化できる最初のものを採用する。
int? daysForRow(Map<String, String> row) {
  for (final prefix in sourcePrefixes) {
    final days = daysFromSource(
      row['${prefix}_Min'],
      row['${prefix}_Max'],
      row['${prefix}_Metric'],
    );
    if (days != null) return days;
  }
  return null;
}

/// name（完全一致・大文字小文字/前後空白無視）と subtitle で行を絞り込む。
/// subtitle == null: name のみで一致。
/// subtitle == ''  : Name_subtitle が空の行のみ。
/// subtitle != ''  : Name_subtitle に部分一致（小文字）。
List<Map<String, String>> matchRows(
  List<Map<String, String>> rows,
  String name,
  String? subtitle,
) {
  final n = name.trim().toLowerCase();
  final cands =
      rows.where((r) => (r['Name'] ?? '').trim().toLowerCase() == n).toList();
  if (subtitle == null) return cands;
  if (subtitle.isEmpty) {
    return cands
        .where((r) => (r['Name_subtitle'] ?? '').trim().isEmpty)
        .toList();
  }
  final s = subtitle.trim().toLowerCase();
  return cands
      .where((r) => (r['Name_subtitle'] ?? '').toLowerCase().contains(s))
      .toList();
}

/// 最小 CSV パーサ。ダブルクォート囲み・"" エスケープ・改行を含む
/// フィールドに対応する。
List<List<String>> parseCsv(String input) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;
  final s = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  for (var i = 0; i < s.length; i++) {
    final ch = s[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < s.length && s[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(ch);
      }
    } else {
      if (ch == '"') {
        inQuotes = true;
      } else if (ch == ',') {
        row.add(field.toString());
        field.clear();
      } else if (ch == '\n') {
        row.add(field.toString());
        field.clear();
        rows.add(row);
        row = <String>[];
      } else {
        field.write(ch);
      }
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(row);
  }
  return rows;
}

Map<String, String> rowToMap(List<String> header, List<String> cells) {
  final map = <String, String>{};
  for (var i = 0; i < header.length; i++) {
    map[header[i]] = i < cells.length ? cells[i] : '';
  }
  return map;
}
