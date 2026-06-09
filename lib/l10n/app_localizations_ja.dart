// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'つかいきり';

  @override
  String get inventoryTitle => '在庫';

  @override
  String get emptyInventory => '食材がまだありません。\n＋から追加してください。';

  @override
  String get addIngredient => '食材を追加';

  @override
  String get editIngredient => '食材を編集';

  @override
  String get filterAll => 'すべて';

  @override
  String get categoryMeat => '肉';

  @override
  String get categoryFish => '魚';

  @override
  String get categoryVegetable => '野菜';

  @override
  String get categoryFruit => '果物';

  @override
  String get categoryDairy => '乳製品';

  @override
  String get categoryEgg => '卵';

  @override
  String get categoryGrain => '穀物・主食';

  @override
  String get categorySeasoning => '調味料';

  @override
  String get categoryFrozen => '冷凍食品';

  @override
  String get categoryBeverage => '飲料';

  @override
  String get categoryStaple => '常備品';

  @override
  String get categoryOther => 'その他';

  @override
  String get unitPiece => '個';

  @override
  String get unitGram => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'L';

  @override
  String get unitBottle => '本';

  @override
  String get unitSheet => '枚';

  @override
  String get unitPack => 'パック';

  @override
  String get unitBag => '袋';

  @override
  String get unitGo => '合';

  @override
  String get unitCup => '杯';

  @override
  String get unitCan => '缶';

  @override
  String get unitCustom => 'カスタム…';

  @override
  String get fieldName => '名前';

  @override
  String get fieldCategory => 'カテゴリ';

  @override
  String get fieldQuantity => '数量';

  @override
  String get fieldUnit => '単位';

  @override
  String get fieldExpiry => '賞味期限';

  @override
  String get fieldExpiryOptional => '賞味期限（任意）';

  @override
  String get customUnitLabel => 'カスタム単位';

  @override
  String get actionSave => '保存';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionDelete => '削除';

  @override
  String get actionClear => 'クリア';

  @override
  String get validationNameRequired => '名前を入力してください';

  @override
  String get validationQuantityInvalid => '0 より大きい数値を入力してください';

  @override
  String get validationUnitRequired => '単位を入力してください';

  @override
  String get deleteConfirmTitle => 'この食材を削除しますか？';

  @override
  String deleteConfirmBody(String name) {
    return '$name を在庫から削除します。';
  }

  @override
  String get expiryExpired => '期限切れ';

  @override
  String get expiryToday => '今日まで';

  @override
  String expiryInDays(int days) {
    return 'あと$days日';
  }

  @override
  String get expiryNone => '期限なし';

  @override
  String get selectIngredientPrompt => '食材を選ぶと詳細が表示されます';

  @override
  String inventoryCountLine(int count) {
    return '冷蔵庫に $count 点 ・ 使い切りたい順';
  }

  @override
  String get groupNow => '今日・もうすぐ使い切りたい';

  @override
  String get groupWeek => '今週のうちに';

  @override
  String get groupPlenty => 'まだ余裕';

  @override
  String get groupNoDate => '賞味期限なし';

  @override
  String get swipeHint => '← カードを左にスワイプでクイック操作';

  @override
  String get emptyInventoryTitle => '在庫はまだ空っぽ';

  @override
  String get emptyInventoryBody => '食材を登録すると、賞味期限の近いものから使い切りメニューを提案します。';

  @override
  String get cameraRegister => 'カメラで登録';

  @override
  String get manualAdd => '手動で追加';

  @override
  String get suggestRecipes => '献立を提案';

  @override
  String get suggestRecipesSub => '使い切りメニューを見る';

  @override
  String get actionUsedUp => '使い切った';

  @override
  String get actionUndo => '元に戻す';

  @override
  String get toastUsedUp => '使い切りました';

  @override
  String get toastDeleted => '削除しました';

  @override
  String get detailAddToShoppingList => '買い物リストに追加';

  @override
  String get detailViewRecipe => 'レシピを見る';

  @override
  String get comingSoon => 'この機能は今後のアップデートで対応予定です';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguage => '言語';

  @override
  String get languageSystem => 'システムに従う';

  @override
  String get languageJa => '日本語';

  @override
  String get languageEn => 'English';

  @override
  String get languageHint => '「システムに従う」を選ぶと、端末の言語設定に合わせて表示します。';

  @override
  String get settingsSectionGeneral => '一般';

  @override
  String get settingsSectionAi => 'AI（食材認識・献立提案）';

  @override
  String get settingsSectionIntegration => '連携';

  @override
  String get settingsSectionData => 'データ';

  @override
  String get settingsSectionSupport => 'サポート';

  @override
  String get settingsAiProvider => 'AIプロバイダ';

  @override
  String get settingsApiKey => 'APIキー';

  @override
  String get settingsImageRecognition => '画像認識';

  @override
  String get settingsShoppingList => '買い物リスト';

  @override
  String get settingsAppliances => '調理家電';

  @override
  String get settingsCloudSync => 'クラウド同期';

  @override
  String get settingsSupportAuthor => '作者をサポート';

  @override
  String get settingsHelp => 'ヘルプ';

  @override
  String get settingsAbout => 'このアプリについて';

  @override
  String get settingsComingSoonValue => '準備中';

  @override
  String get settingsSyncOffNote => '同期はオフです。この端末のみにデータが保存されます。';

  @override
  String settingsVersionLine(String version) {
    return 'つかいきり ・ v$version';
  }
}
