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

  @override
  String get shellNavInventory => '在庫';

  @override
  String get shellNavCamera => 'カメラ登録';

  @override
  String get shellNavMeals => '献立提案';

  @override
  String get shellNavShopping => '買い物リスト';

  @override
  String get shellNavOnboarding => '設定アシスタント';

  @override
  String get shellNavSettings => '設定';

  @override
  String get shellNavHelp => 'ヘルプ';

  @override
  String get shellSectionMain => 'メイン';

  @override
  String get shellSectionOther => 'その他';

  @override
  String shellInventoryCount(int count) {
    return '$count品の食材';
  }

  @override
  String get shellPlaceholder => 'この画面は準備中です。';

  @override
  String get shellPlaceholderTitle => '準備中';

  @override
  String get desktopCategoryLabel => 'カテゴリ';

  @override
  String get desktopGroupNow => '今日・もうすぐ';

  @override
  String get desktopGroupWeek => '今週のうちに';

  @override
  String get desktopGroupPlenty => 'まだ余裕';

  @override
  String get desktopSearchPlaceholder => '食材を検索…';

  @override
  String get desktopNoResults => '該当する食材がありません';

  @override
  String get desktopSelectPrompt => '食材を選択してください';

  @override
  String get desktopSelectBody => '一覧から食材をクリックすると\n詳細・編集できます';

  @override
  String get desktopAddIngredient => '食材を追加';

  @override
  String get desktopAddIngredientShortcut => '⌘N';

  @override
  String get desktopCameraRegister => 'カメラ登録';

  @override
  String get desktopCameraShortcut => '⌘K';

  @override
  String get desktopSuggestMeals => '献立を提案';

  @override
  String get desktopSuggestMealsShortcut => '⌘R';

  @override
  String desktopQuantityUnit(String qty, String unit) {
    return '$qty $unit';
  }

  @override
  String desktopExpiryDaysOver(int n) {
    return '$n日超過';
  }

  @override
  String get desktopExpiryToday => '今日まで';

  @override
  String desktopExpiryDaysLeft(int n) {
    return 'あと$n日';
  }

  @override
  String get desktopDetailQty => '数量';

  @override
  String get desktopDetailCategory => 'カテゴリ';

  @override
  String get desktopDetailExpiry => '賞味期限まで';

  @override
  String get desktopSuggestWithIngredient => 'この食材で献立を提案';

  @override
  String get desktopUsedUp => '使い切りにする';

  @override
  String get desktopDelete => '削除';

  @override
  String get desktopEditHint => '編集ボタンから名前・数量を変更できます';

  @override
  String desktopCountSuffix(int n) {
    return '$n品';
  }

  @override
  String get settingsNavAi => 'AI設定';

  @override
  String get settingsNavGeneral => '一般';

  @override
  String get settingsNavShopping => '買い物リスト';

  @override
  String get settingsNavAppliance => '調理家電';

  @override
  String get settingsNavData => 'データ';

  @override
  String get settingsNavSupport => 'サポート';

  @override
  String get settingsAiHeading => 'AI（食材認識・献立提案）';

  @override
  String get settingsAiVisionYes => '画像認識あり';

  @override
  String get settingsAiVisionNo => '画像認識なし';

  @override
  String get settingsApiKeyHeading => 'APIキー';

  @override
  String get settingsApiKeyPlaceholder => 'APIキーを貼り付け';

  @override
  String get settingsApiKeyNote => 'キーはこの端末内に安全に保存されます。';

  @override
  String get settingsApiKeySave => '保存';

  @override
  String get settingsApiKeyChange => '変更';

  @override
  String get settingsApiKeyDelete => '削除';

  @override
  String settingsApiKeyGetLink(String provider) {
    return '$provider のキーを取得';
  }

  @override
  String settingsApiKeySavedMasked(String masked) {
    return '保存済み: $masked';
  }

  @override
  String get settingsModelHeading => 'モデル';

  @override
  String get settingsModelFetch => 'モデルを取得';

  @override
  String get settingsModelFetching => '取得中…';

  @override
  String get settingsModelNeedKey => 'モデルを取得するには先に APIキーを保存してください。';

  @override
  String settingsModelCurrent(String model) {
    return '使用中: $model';
  }

  @override
  String get settingsModelDefault => '既定（自動）';

  @override
  String get settingsNetworkError => '電波の良い場所か Wi-Fi に接続してください。';

  @override
  String get settingsGeneralHeading => '一般';

  @override
  String get settingsShoppingHeading => '買い物リスト';

  @override
  String get settingsShoppingLinkedApp => '連携先アプリ';

  @override
  String get settingsShoppingReminders => 'リマインダー（macOS）';

  @override
  String get settingsShoppingLists => '追加先リスト';

  @override
  String get settingsShoppingLoad => 'リストを読み込む';

  @override
  String get settingsShoppingLoading => '読み込み中…';

  @override
  String settingsShoppingCurrent(String name) {
    return '現在: $name';
  }

  @override
  String get settingsShoppingNone => '未選択';

  @override
  String get settingsShoppingNewName => '新しいリスト名';

  @override
  String get settingsShoppingCreate => '作成';

  @override
  String get settingsShoppingLoadError =>
      'リストを取得できませんでした。リマインダーへのアクセスを許可しているか確認してください。';

  @override
  String get settingsApplianceHeading => '調理家電';

  @override
  String get settingsApplianceHotcook => 'ホットクック';

  @override
  String get settingsApplianceHealsio => 'ヘルシオ';

  @override
  String get settingsApplianceNotOwned => '持っていない';

  @override
  String get settingsApplianceSeries => '型（シリーズ）';

  @override
  String get settingsApplianceCapacity => '容量';

  @override
  String get settingsApplianceNote =>
      '登録すると、その家電で作れるレシピを優先表示します。型・容量に合わせて分量も調整します。';

  @override
  String get settingsDataHeading => 'データ同期';

  @override
  String get settingsDataICloud => 'iCloud 同期';

  @override
  String get settingsDataComingSoon => '同期機能は準備中です。';

  @override
  String get settingsSupportHeading => 'サポート';

  @override
  String get settingsSupportComingSoon => '（準備中）';

  @override
  String get settingsSupportHelp => 'ヘルプ';

  @override
  String get settingsSupportAbout => 'このアプリについて';

  @override
  String settingsAboutVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get settingsAboutClose => '閉じる';

  @override
  String get mealsConditionsLabel => '条件';

  @override
  String get mealsCondAuto => 'おまかせ';

  @override
  String get mealsCondMainOnly => '主菜のみ';

  @override
  String get mealsCondOneMore => 'あと1品';

  @override
  String get mealsCondQuick => '時短';

  @override
  String get mealsSuggestButton => '在庫から提案する';

  @override
  String get mealsSuggestShortcut => '⌘R';

  @override
  String get mealsBeforeBody => '「在庫から提案する」をクリックしてください';

  @override
  String get mealsGenerating => '献立を生成中…';

  @override
  String get mealsLowStockBanner => '在庫が少ないため、買い足し前提の献立も含めて提案しています。';

  @override
  String get mealsErrorNetwork =>
      '提案を取得できませんでした。電波の良い場所か Wi-Fi に接続して再試行してください。';

  @override
  String get mealsErrorNoApiKey => 'AI の API キーが未登録です。設定で API キーを登録してください。';

  @override
  String get mealsRetry => '再試行';

  @override
  String get mealsOpenSettings => '設定を開く';

  @override
  String get mealsBadgeUseNear => '期限近い';

  @override
  String get mealsApplianceHotcook => '🍲 ホットクック';

  @override
  String get mealsApplianceHealsio => '♨️ ヘルシオ';

  @override
  String get mealsApplianceNormal => '🔥 通常調理';

  @override
  String mealsCookMinutes(int minutes) {
    return '⏱ $minutes分';
  }

  @override
  String get mealsDetailEmpty => '献立を選択してください';

  @override
  String mealsCookTime(int minutes) {
    return '調理時間 $minutes分';
  }

  @override
  String get mealsToShopping => '買い物リストへ';

  @override
  String get mealsDecide => '献立に決める';

  @override
  String get mealsDecided => '決定済み';

  @override
  String get mealsIngredientsHeading => '材料';

  @override
  String get mealsStepsHeading => '手順';

  @override
  String shoppingMissingCount(int n) {
    return '不足食材 $n品';
  }

  @override
  String get shoppingSelectAll => 'すべて選択';

  @override
  String get shoppingDeselectAll => 'すべて解除';

  @override
  String shoppingForLabel(String meal) {
    return '$meal 用';
  }

  @override
  String get shoppingRightPanelTitle => '追加先リスト';

  @override
  String get shoppingAppLabel => 'アプリ';

  @override
  String get shoppingRemindersApp => 'リマインダー（macOS）';

  @override
  String get shoppingLoadLists => 'リストを読み込む';

  @override
  String get shoppingLoadingLists => '読み込み中…';

  @override
  String get shoppingNewListName => '新しいリスト名';

  @override
  String get shoppingCreateList => '作成';

  @override
  String shoppingAddButton(String list, int n) {
    return '「$list」に追加（$n件）';
  }

  @override
  String get shoppingAddButtonNoList => '先にリストを選んでください';

  @override
  String shoppingDoneTitle(int n) {
    return '$n品を追加しました';
  }

  @override
  String shoppingDoneBody(String list) {
    return 'リマインダーの「$list」で確認できます';
  }

  @override
  String get shoppingOpenReminders => 'リマインダーを開く';

  @override
  String get shoppingBackToInventory => '在庫に戻る';

  @override
  String get shoppingEmptyTitle => '不足食材はありません';

  @override
  String get shoppingEmptyBody => '献立を決めると不足食材がここに出ます。';

  @override
  String get shoppingGoToMeals => '献立提案へ';

  @override
  String get shoppingErrorTitle => 'リストに追加できませんでした';

  @override
  String get shoppingErrorNetwork =>
      '電波の良い場所か Wi-Fi に接続してください。リマインダーへのアクセス許可もご確認ください。';

  @override
  String get shoppingRetry => '再試行';

  @override
  String get shoppingListLoadError =>
      'リストを取得できませんでした。リマインダーへのアクセスを許可しているか確認してください。';

  @override
  String shoppingQtyUnit(int qty) {
    return '$qty個';
  }
}
