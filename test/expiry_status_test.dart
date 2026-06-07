import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/features/inventory/presentation/expiry_status.dart';

void main() {
  final now = DateTime(2026, 6, 7, 9);

  ExpiryLevel levelFor(DateTime? d) => expiryInfoFor(d, now).level;

  test('期限なしは none', () {
    expect(levelFor(null), ExpiryLevel.none);
  });

  test('過去日は expired', () {
    expect(levelFor(DateTime(2026, 6, 6)), ExpiryLevel.expired);
  });

  test('当日は today（赤扱い）', () {
    expect(levelFor(DateTime(2026, 6, 7, 23)), ExpiryLevel.today);
  });

  test('残り1〜3日は warning', () {
    expect(levelFor(DateTime(2026, 6, 8)), ExpiryLevel.warning);
    expect(levelFor(DateTime(2026, 6, 10)), ExpiryLevel.warning);
  });

  test('残り4日以上は normal', () {
    expect(levelFor(DateTime(2026, 6, 11)), ExpiryLevel.normal);
  });

  test('daysLeft が正しく入る', () {
    expect(expiryInfoFor(DateTime(2026, 6, 10), now).daysLeft, 3);
    expect(expiryInfoFor(DateTime(2026, 6, 5), now).daysLeft, -2);
  });
}
