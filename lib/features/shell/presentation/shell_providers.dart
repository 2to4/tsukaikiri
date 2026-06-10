import 'package:flutter_riverpod/flutter_riverpod.dart';

/// サイドバーで選択中のセクション。
enum ShellSection {
  /// 在庫管理（⌘1）
  inventory,

  /// カメラ登録（⌘2）
  camera,

  /// 献立提案（⌘3）
  meals,

  /// 買い物リスト（⌘4）
  shopping,

  /// 設定アシスタント
  onboarding,

  /// 設定（⌘,）
  settings,

  /// ヘルプ
  help,
}

/// 現在選択中のシェルセクション。
class ShellSectionNotifier extends Notifier<ShellSection> {
  @override
  ShellSection build() => ShellSection.inventory;

  void select(ShellSection section) => state = section;
}

final shellSectionProvider =
    NotifierProvider<ShellSectionNotifier, ShellSection>(
  ShellSectionNotifier.new,
);
