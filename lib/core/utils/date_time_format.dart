/// 同期画面などで使う分単位の日時表記（例: 2026-06-12 09:30）。
String formatDateTimeMinutes(DateTime dt) {
  return '${dt.year}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}
