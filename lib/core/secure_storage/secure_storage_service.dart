import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AI プロバイダの API キーを Keychain / Keystore に保管するサービス。
class SecureStorageService {
  const SecureStorageService();

  static const _storage = FlutterSecureStorage(
    mOptions: MacOsOptions(),
    iOptions: IOSOptions(),
    aOptions: AndroidOptions(),
  );

  static String _key(String provider) => 'api_key_$provider';

  Future<String?> getApiKey(String provider) =>
      _storage.read(key: _key(provider));

  Future<void> setApiKey(String provider, String apiKey) =>
      _storage.write(key: _key(provider), value: apiKey);

  Future<void> deleteApiKey(String provider) =>
      _storage.delete(key: _key(provider));

  Future<bool> hasApiKey(String provider) async {
    final key = await getApiKey(provider);
    return key != null && key.isNotEmpty;
  }
}
