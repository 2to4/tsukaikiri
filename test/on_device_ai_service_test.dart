import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/features/recipe/service/on_device_ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.futo4.tsukaikiri/ondevice_ai');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  void mock(Future<Object?>? Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(channel, handler);
  }

  const service = OnDeviceAiService();

  test('availability: ネイティブの戻り値を解釈する', () async {
    mock((call) async {
      expect(call.method, 'availability');
      return {'available': true, 'supportsVision': false};
    });
    final a = await service.availability();
    expect(a.available, isTrue);
    expect(a.supportsVision, isFalse);
  });

  test('availability: unavailable + reason', () async {
    mock((call) async => {
          'available': false,
          'supportsVision': false,
          'reason': 'apple_intelligence_not_enabled',
        });
    final a = await service.availability();
    expect(a.available, isFalse);
    expect(a.reason, 'apple_intelligence_not_enabled');
  });

  test('availability: プラグイン未登録（MissingPlugin）でも unavailable を返す', () async {
    // ハンドラ未設定 = MissingPluginException 相当。
    final a = await service.availability();
    expect(a.available, isFalse);
  });

  test('generate: prompt と images を渡しテキストを受け取る', () async {
    late MethodCall captured;
    mock((call) async {
      captured = call;
      return '{"recipes":[]}';
    });
    final out = await service.generate(
      prompt: 'p',
      images: [Uint8List.fromList([1, 2, 3])],
    );
    expect(out, '{"recipes":[]}');
    final args = captured.arguments as Map;
    expect(args['prompt'], 'p');
    expect(args['images'], isA<List>());
  });

  test('generate: PlatformException → OnDeviceAiException（code 保持）', () async {
    mock((call) async {
      throw PlatformException(code: 'generate_failed', message: 'boom');
    });
    await expectLater(
      service.generate(prompt: 'p'),
      throwsA(isA<OnDeviceAiException>()
          .having((e) => e.code, 'code', 'generate_failed')),
    );
  });

  test('generate: 空レスポンス → OnDeviceAiException', () async {
    mock((call) async => '');
    await expectLater(
      service.generate(prompt: 'p'),
      throwsA(isA<OnDeviceAiException>()),
    );
  });
}
