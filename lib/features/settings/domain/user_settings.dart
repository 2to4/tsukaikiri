import 'appliance.dart';

/// アプリ設定のドメインモデル。DB の AppSettings から変換して使う。
class UserSettings {
  const UserSettings({
    required this.localePref,
    this.shoppingListId,
    this.shoppingListName,
    this.selectedProvider = 'gemini',
    this.modelOverrides = const {},
    this.syncEnabled = false,
    this.lastSyncedAt,
    this.appliances = const [],
    this.cameraPreserveState = true,
    this.syncKeepOnFailure = true,
  });

  /// 'ja' / 'en' / 'system'
  final String localePref;

  /// 書き込み先リストの識別子（macOS/iOS=calendarIdentifier / Android=tasklist id）
  final String? shoppingListId;

  /// UI 表示用リスト名（識別子で引き当てた現在の名前）
  final String? shoppingListName;

  /// 選択中の AI プロバイダ識別子（'gemini' / 'claude' / 'openai' / 'grok'）
  final String selectedProvider;

  /// プロバイダごとのモデル上書き（{providerId: modelId}）。
  /// 未指定のプロバイダは実装側のフォールバック既定値を使う。
  final Map<String, String> modelOverrides;

  final bool syncEnabled;
  final DateTime? lastSyncedAt;
  final List<Appliance> appliances;

  /// カメラ登録画面の途中状態を再入場時に保持するか（デフォルト true = 現行挙動:
  /// capture/review の途中状態を保持し error のみリセット。false なら毎回リセット）。
  final bool cameraPreserveState;

  /// 同期トグル ON 直後の自動バックアップ失敗時も ON を維持するか（デフォルト true = 現行）。
  final bool syncKeepOnFailure;

  UserSettings copyWith({
    String? localePref,
    String? shoppingListId,
    String? shoppingListName,
    String? selectedProvider,
    Map<String, String>? modelOverrides,
    bool? syncEnabled,
    DateTime? lastSyncedAt,
    List<Appliance>? appliances,
    bool? cameraPreserveState,
    bool? syncKeepOnFailure,
  }) =>
      UserSettings(
        localePref: localePref ?? this.localePref,
        shoppingListId: shoppingListId ?? this.shoppingListId,
        shoppingListName: shoppingListName ?? this.shoppingListName,
        selectedProvider: selectedProvider ?? this.selectedProvider,
        modelOverrides: modelOverrides ?? this.modelOverrides,
        syncEnabled: syncEnabled ?? this.syncEnabled,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        appliances: appliances ?? this.appliances,
        cameraPreserveState: cameraPreserveState ?? this.cameraPreserveState,
        syncKeepOnFailure: syncKeepOnFailure ?? this.syncKeepOnFailure,
      );
}
