import 'appliance.dart';

/// アプリ設定のドメインモデル。DB の AppSettings から変換して使う。
class UserSettings {
  const UserSettings({
    required this.localePref,
    this.shoppingListId,
    this.shoppingListName,
    this.selectedProvider = 'gemini',
    this.syncEnabled = false,
    this.lastSyncedAt,
    this.appliances = const [],
  });

  /// 'ja' / 'en' / 'system'
  final String localePref;

  /// 書き込み先リストの識別子（macOS/iOS=calendarIdentifier / Android=tasklist id）
  final String? shoppingListId;

  /// UI 表示用リスト名（識別子で引き当てた現在の名前）
  final String? shoppingListName;

  /// 選択中の AI プロバイダ識別子（'gemini' / 'claude' / 'openai' / 'grok'）
  final String selectedProvider;

  final bool syncEnabled;
  final DateTime? lastSyncedAt;
  final List<Appliance> appliances;

  UserSettings copyWith({
    String? localePref,
    String? shoppingListId,
    String? shoppingListName,
    String? selectedProvider,
    bool? syncEnabled,
    DateTime? lastSyncedAt,
    List<Appliance>? appliances,
  }) =>
      UserSettings(
        localePref: localePref ?? this.localePref,
        shoppingListId: shoppingListId ?? this.shoppingListId,
        shoppingListName: shoppingListName ?? this.shoppingListName,
        selectedProvider: selectedProvider ?? this.selectedProvider,
        syncEnabled: syncEnabled ?? this.syncEnabled,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        appliances: appliances ?? this.appliances,
      );
}
