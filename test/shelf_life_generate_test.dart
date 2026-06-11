// generate.dart のコアロジック（純 Dart）のテスト。
// tool/shelf_life/shelf_life_compute.dart を直接 import する。
import 'package:flutter_test/flutter_test.dart';

import '../tool/shelf_life/shelf_life_compute.dart';

void main() {
  group('daysFromSource (Metric 換算・中央値)', () {
    test('Days: 中央値をそのまま日数にする', () {
      expect(daysFromSource('1', '2', 'Days'), 2); // round(1.5)=2
      expect(daysFromSource('3', '4', 'Days'), 4); // round(3.5)=4
      expect(daysFromSource('3', '5', 'Days'), 4); // round(4.0)=4
    });

    test('Weeks: 7 倍', () {
      expect(daysFromSource('1', '2', 'Weeks'), 11); // round(1.5*7)=11
      expect(daysFromSource('2', '2', 'Weeks'), 14);
    });

    test('Months: 30 倍', () {
      expect(daysFromSource('1', '1', 'Months'), 30);
      expect(daysFromSource('3', '5', 'Months'), 120); // 4*30
    });

    test('Years: 365 倍', () {
      expect(daysFromSource('1', '1', 'Years'), 365);
      expect(daysFromSource('2', '2', 'Years'), 730);
    });

    test('大文字小文字・前後空白を無視する', () {
      expect(daysFromSource('1', '1', ' days '), 1);
      expect(daysFromSource('1', '1', 'WEEKS'), 7);
    });

    test('数値化できない Metric は null', () {
      expect(daysFromSource('', '', 'Package use-by date'), isNull);
      expect(daysFromSource('', '', 'When Ripe'), isNull);
      expect(daysFromSource('', '', 'Indefinitely'), isNull);
      expect(daysFromSource('', '', 'Not Recommended'), isNull);
    });

    test('Metric があっても数値が空なら null', () {
      expect(daysFromSource('', '', 'Days'), isNull);
      expect(daysFromSource('1', '', 'Days'), isNull);
    });

    test('下限は 1 日（0 に丸まらない）', () {
      // ありえないが念のため: 中央値 0 でも最低 1 を返す。
      expect(daysFromSource('0', '0', 'Days'), 1);
    });
  });

  group('daysForRow (保存源フォールバック)', () {
    Map<String, String> emptyRow() => {
          for (final p in sourcePrefixes) ...{
            '${p}_Min': '',
            '${p}_Max': '',
            '${p}_Metric': '',
          },
        };

    test('Refrigerate を最優先する', () {
      final row = emptyRow()
        ..['Refrigerate_Min'] = '3'
        ..['Refrigerate_Max'] = '4'
        ..['Refrigerate_Metric'] = 'Days'
        ..['DOP_Refrigerate_Min'] = '1'
        ..['DOP_Refrigerate_Max'] = '1'
        ..['DOP_Refrigerate_Metric'] = 'Months';
      expect(daysForRow(row), 4); // Refrigerate 優先
    });

    test('Refrigerate が無ければ DOP_Refrigerate にフォールバック', () {
      final row = emptyRow()
        ..['DOP_Refrigerate_Min'] = '1'
        ..['DOP_Refrigerate_Max'] = '2'
        ..['DOP_Refrigerate_Metric'] = 'Days';
      expect(daysForRow(row), 2);
    });

    test('冷蔵が無ければ Pantry にフォールバック', () {
      final row = emptyRow()
        ..['Pantry_Min'] = '3'
        ..['Pantry_Max'] = '5'
        ..['Pantry_Metric'] = 'Days';
      expect(daysForRow(row), 4);
    });

    test('数値化できる源が無ければ null', () {
      final row = emptyRow()
        ..['Refrigerate_Metric'] = 'Package use-by date';
      expect(daysForRow(row), isNull);
    });
  });

  group('matchRows (行の絞り込み)', () {
    final rows = [
      {'Name': 'Chicken parts', 'Name_subtitle': 'breast halves, boneless'},
      {'Name': 'Chicken parts', 'Name_subtitle': 'legs or thighs'},
      {'Name': 'Cabbage', 'Name_subtitle': ''},
      {'Name': 'Bacon', 'Name_subtitle': ''},
      {'Name': 'Bacon', 'Name_subtitle': 'fully cooked'},
    ];

    test('subtitle == null は name のみで一致', () {
      expect(matchRows(rows, 'Chicken parts', null).length, 2);
    });

    test('subtitle が部分一致で 1 行に絞れる', () {
      final r = matchRows(rows, 'Chicken parts', 'boneless');
      expect(r.length, 1);
      expect(r.single['Name_subtitle'], 'breast halves, boneless');
    });

    test("subtitle == '' は空 subtitle 行のみ（Bacon の cooked を除外）", () {
      final r = matchRows(rows, 'Bacon', '');
      expect(r.length, 1);
      expect(r.single['Name_subtitle'], '');
    });

    test('大文字小文字・前後空白を無視する', () {
      expect(matchRows(rows, '  cabbage ', '').length, 1);
    });
  });

  group('parseCsv', () {
    test('クォート内のカンマ・改行を 1 フィールドとして扱う', () {
      const csv = 'a,b,c\n"x,y",z,"line1\nline2"\n';
      final rows = parseCsv(csv);
      expect(rows.length, 2);
      expect(rows[1], ['x,y', 'z', 'line1\nline2']);
    });

    test('"" を 1 個のダブルクォートにエスケープ解除する', () {
      const csv = 'a\n"he said ""hi"""\n';
      final rows = parseCsv(csv);
      expect(rows[1].single, 'he said "hi"');
    });
  });
}
