import 'package:tsukaikiri/core/secure_storage/secure_storage_service.dart';

/// インメモリの SecureStorageService フェイク（テスト共用）。
class FakeSecureStorage extends SecureStorageService {
  FakeSecureStorage() : super();

  /// 保存内容の検証用に公開する。
  final Map<String, String> store = {};

  @override
  Future<String?> getApiKey(String provider) async => store[provider];

  @override
  Future<void> setApiKey(String provider, String apiKey) async =>
      store[provider] = apiKey;

  @override
  Future<void> deleteApiKey(String provider) async => store.remove(provider);

  @override
  Future<bool> hasApiKey(String provider) async {
    final k = store[provider];
    return k != null && k.isNotEmpty;
  }
}
