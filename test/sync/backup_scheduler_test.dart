import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/features/sync/presentation/sync_controller.dart';

void main() {
  test('1. デバウンス: 2 回 schedule しても 5 秒後に 1 回だけ実行される', () {
    fakeAsync((async) {
      final scheduler = BackupScheduler();
      var callCount = 0;

      scheduler.schedule(() async => callCount++);
      async.elapse(const Duration(seconds: 2)); // 途中で再スケジュール
      scheduler.schedule(() async => callCount++);

      expect(callCount, 0); // まだ実行されていない

      async.elapse(const Duration(seconds: 5)); // 2 回目の schedule から 5 秒後

      expect(callCount, 1); // 1 回だけ実行

      scheduler.dispose();
    });
  });

  test('2. cancel() でタイマーが停止し、コールバックが呼ばれない', () {
    fakeAsync((async) {
      final scheduler = BackupScheduler();
      var callCount = 0;

      scheduler.schedule(() async => callCount++);
      scheduler.cancel();

      async.elapse(const Duration(seconds: 10));

      expect(callCount, 0);
    });
  });

  test('3. dispose() は cancel() と同義', () {
    fakeAsync((async) {
      final scheduler = BackupScheduler();
      var callCount = 0;

      scheduler.schedule(() async => callCount++);
      scheduler.dispose(); // cancel と同義

      async.elapse(const Duration(seconds: 10));

      expect(callCount, 0);
    });
  });
}
