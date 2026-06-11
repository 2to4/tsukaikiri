import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AI プロバイダの API キーを Keychain / Keystore に保管するサービス。
///
/// macOS / iOS では synchronizable=true で書き込み、iCloud Keychain 経由で
/// デバイス間に伝播させる。既存の非 synchronizable なアイテムは初回読み出し時に
/// 自動で移行する。
///
/// テストでは [SecureStorageService.withStorage] を使ってフェイクを2つ注入できる。
class SecureStorageService {
  /// プロダクション用コンストラクタ。
  ///
  /// [storage] が渡された場合は移行ロジックをスキップして注入されたストレージを使う
  /// （後方互換のため）。省略時は synchronizable 移行ロジックが有効になる。
  const SecureStorageService([FlutterSecureStorage? storage])
      : _injectedStorage = storage,
        _syncStorage = null,
        _legacyStorage = null;

  /// テスト用コンストラクタ。
  ///
  /// [_syncStorage] と [_legacyStorage] を個別に注入して移行ロジックをテストできる。
  const SecureStorageService.withStorage({
    required FlutterSecureStorage this._syncStorage,
    required FlutterSecureStorage this._legacyStorage,
  })  : _injectedStorage = null;

  final FlutterSecureStorage? _injectedStorage;
  final FlutterSecureStorage? _syncStorage;
  final FlutterSecureStorage? _legacyStorage;

  // ---- macOS / iOS オプション ----

  static const _syncMacOsOptions = MacOsOptions(synchronizable: true);
  static const _syncIosOptions = IOSOptions(synchronizable: true);
  static const _legacyMacOsOptions = MacOsOptions();
  static const _legacyIosOptions = IOSOptions();

  // ---- デフォルトストレージ（synchronizable 版 / legacy 版）----

  static const _defaultSyncStorage = FlutterSecureStorage(
    mOptions: _syncMacOsOptions,
    iOptions: _syncIosOptions,
    aOptions: AndroidOptions(),
    wOptions: WindowsOptions(),
  );

  static const _defaultLegacyStorage = FlutterSecureStorage(
    mOptions: _legacyMacOsOptions,
    iOptions: _legacyIosOptions,
    aOptions: AndroidOptions(),
    wOptions: WindowsOptions(),
  );

  // ---- 内部ヘルパー ----

  bool get _isInjectedMode => _injectedStorage != null;

  FlutterSecureStorage get _effectiveSyncStorage =>
      _syncStorage ?? _defaultSyncStorage;

  FlutterSecureStorage get _effectiveLegacyStorage =>
      _legacyStorage ?? _defaultLegacyStorage;

  static String _key(String provider) => 'api_key_$provider';

  // ---- 公開 API ----

  Future<String?> getApiKey(String provider) async {
    // 注入モード（後方互換 / テスト）: 単純に注入されたストレージを使う
    if (_isInjectedMode) {
      return _injectedStorage!.read(key: _key(provider));
    }

    // withStorage モード（移行テスト用）: 移行ロジックを実行
    // プロダクションも同じパスを通る
    final syncVal =
        await _effectiveSyncStorage.read(key: _key(provider));
    if (syncVal != null) return syncVal;

    // synchronizable で見つからなかった → legacy を確認
    final legacyVal =
        await _effectiveLegacyStorage.read(key: _key(provider));
    if (legacyVal != null) {
      // legacy → sync へ移行
      await _effectiveSyncStorage.write(
          key: _key(provider), value: legacyVal);
      await _effectiveLegacyStorage.delete(key: _key(provider));
      return legacyVal;
    }

    return null;
  }

  Future<void> setApiKey(String provider, String apiKey) async {
    if (_isInjectedMode) {
      await _injectedStorage!.write(key: _key(provider), value: apiKey);
      return;
    }

    // synchronizable=true で書き込む（PlatformException の場合は legacy にフォールバック）
    try {
      await _effectiveSyncStorage.write(
          key: _key(provider), value: apiKey);
    } on PlatformException {
      await _effectiveLegacyStorage.write(
          key: _key(provider), value: apiKey);
    }
  }

  Future<void> deleteApiKey(String provider) async {
    if (_isInjectedMode) {
      await _injectedStorage!.delete(key: _key(provider));
      return;
    }

    // 両方削除を試みる（どちらかが失敗しても続行）
    try {
      await _effectiveSyncStorage.delete(key: _key(provider));
    } catch (_) {}
    try {
      await _effectiveLegacyStorage.delete(key: _key(provider));
    } catch (_) {}
  }

  Future<bool> hasApiKey(String provider) async {
    final key = await getApiKey(provider);
    return key != null && key.isNotEmpty;
  }
}
