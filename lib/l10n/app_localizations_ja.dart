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

  @override
  String get cameraTitle => 'カメラ登録';

  @override
  String get cameraDropZoneTitle => '写真をドロップ、または クリックして選択';

  @override
  String get cameraDropZoneBody => '冷蔵庫の写真を最大10枚追加できます';

  @override
  String cameraAnalyzeButton(int n) {
    return '$n枚を解析する ⌘R';
  }

  @override
  String get cameraMaxPhotosHint => '写真は最大10枚まで追加できます。超えた分は無視されました。';

  @override
  String get cameraAnalyzingTitle => 'AIが写真を解析中…';

  @override
  String get cameraAnalyzingBody => '食材を認識しています。しばらくお待ちください';

  @override
  String cameraReviewHeader(int n) {
    return '認識された食材（$n件）';
  }

  @override
  String get cameraConfHighLabel => '確信度 高';

  @override
  String get cameraConfMidLabel => '確信度 中';

  @override
  String get cameraConfLowLabel => '確信度 低';

  @override
  String cameraConfirmButton(int n) {
    return '確定して追加（$n件）';
  }

  @override
  String get cameraEditNameLabel => '名前';

  @override
  String get cameraEditQtyLabel => '数量';

  @override
  String get cameraEditUnitLabel => '単位';

  @override
  String get cameraEditCategoryLabel => 'カテゴリ';

  @override
  String get cameraErrorNetworkTitle => '写真の解析に失敗しました';

  @override
  String get cameraErrorNetworkBody => '電波の良い場所か Wi-Fi に接続してください。';

  @override
  String get cameraErrorNoApiKeyTitle => 'API キーが登録されていません';

  @override
  String get cameraErrorNoApiKeyBody => '設定でAPIキーを登録すると、AI食材認識を使えます。';

  @override
  String get cameraErrorNoVisionTitle => 'このプロバイダは画像認識に対応していません';

  @override
  String get cameraErrorNoVisionBody => '設定から画像認識に対応したプロバイダ・モデルに変更してください。';

  @override
  String get cameraErrorRetry => 'もう一度試す';

  @override
  String get cameraErrorOpenSettings => '設定を開く';

  @override
  String cameraAddedToast(int n) {
    return '$n件を在庫に追加しました';
  }

  @override
  String get onboardingRailTitle => '設定アシスタント';

  @override
  String get onboardingStep0 => 'ようこそ';

  @override
  String get onboardingStep1 => 'AIを選ぶ';

  @override
  String get onboardingStep2 => 'リマインダー連携';

  @override
  String get onboardingStep3 => 'リストを選ぶ';

  @override
  String get onboardingStep4 => '調理家電';

  @override
  String get onboardingStep5 => '完了';

  @override
  String get onboardingWelcomeTitle => 'つかいきりへようこそ';

  @override
  String get onboardingWelcomeSub =>
      '冷蔵庫の食材を登録して、食材を無駄なく使い切る献立を提案します。\nまず簡単な設定をしましょう。';

  @override
  String get onboardingWelcomeFeature1Title => '撮るだけ登録';

  @override
  String get onboardingWelcomeFeature1Body => 'カメラで食材を一括追加';

  @override
  String get onboardingWelcomeFeature2Title => '使い切り献立';

  @override
  String get onboardingWelcomeFeature2Body => '期限間近の食材を優先';

  @override
  String get onboardingWelcomeFeature3Title => '買い物リスト';

  @override
  String get onboardingWelcomeFeature3Body => '足りない食材を自動追加';

  @override
  String get onboardingWelcomeStart => 'はじめる';

  @override
  String get onboardingAiTitle => 'AIプロバイダを選択';

  @override
  String get onboardingAiSub =>
      '食材の認識と献立提案に使うAIを選んでください。APIキーはこのMac内に安全に保存されます。';

  @override
  String get onboardingAiSkip => 'あとで設定';

  @override
  String get onboardingAiKeyLabel => 'APIキー';

  @override
  String onboardingAiGetKeyLink(String provider) {
    return '$provider のAPIキーを取得する';
  }

  @override
  String get onboardingAiSelected => '選択中';

  @override
  String get onboardingLinkTitle => 'リマインダーと連携';

  @override
  String get onboardingLinkSub => '足りない食材を、macOSのリマインダーに自動で追加します。';

  @override
  String get onboardingLinkSkip => 'あとで';

  @override
  String get onboardingLinkApp => 'アプリ';

  @override
  String get onboardingLinkAppValue => 'リマインダー（macOS）';

  @override
  String get onboardingLinkAction => 'できること';

  @override
  String get onboardingLinkActionValue => '買い物リストへの項目追加';

  @override
  String get onboardingLinkPrivacy => 'プライバシー';

  @override
  String get onboardingLinkPrivacyValue => '写真はこのMac内で処理';

  @override
  String get onboardingLinkButton => 'リマインダーへのアクセスを許可';

  @override
  String get onboardingLinkDone => 'リマインダーと連携しました';

  @override
  String get onboardingLinkError => 'リマインダーにアクセスできませんでした。設定画面で後から設定できます。';

  @override
  String get onboardingListTitle => '追加先リストを選ぶ';

  @override
  String get onboardingListSub => '買い物リストを追加するリマインダーのリストを選んでください。';

  @override
  String get onboardingListSkip => 'あとで';

  @override
  String get onboardingListNewName => '新しいリスト名…';

  @override
  String get onboardingListCreate => '作成';

  @override
  String get onboardingListLoading => '読み込み中…';

  @override
  String get onboardingApplianceTitle => '調理家電の登録';

  @override
  String get onboardingApplianceSub => 'お持ちの調理家電を選ぶと、それに合わせた献立を提案します。';

  @override
  String get onboardingApplianceSkip => '持っていない';

  @override
  String get onboardingApplianceSeries => 'シリーズ';

  @override
  String get onboardingFinishTitle => '準備ができました';

  @override
  String get onboardingFinishSub => 'さっそく冷蔵庫の食材を登録して、使い切り献立をはじめましょう。';

  @override
  String get onboardingFinishAiLabel => 'AI';

  @override
  String get onboardingFinishListLabel => 'リマインダー連携';

  @override
  String get onboardingFinishApplianceLabel => '調理家電';

  @override
  String get onboardingFinishNotSet => '未設定';

  @override
  String get onboardingFinishSettingsNote => 'これらの設定はいつでも設定画面から変更できます。';

  @override
  String get onboardingFinishStart => '食材を登録してはじめる';

  @override
  String get onboardingBack => '戻る';

  @override
  String get onboardingNext => '次へ';

  @override
  String get helpTitle => 'ヘルプ / このアプリについて';

  @override
  String get helpAppTagline => '冷蔵庫の在庫から献立を提案し、食材を「使い切る」ための家庭向けアプリです。';

  @override
  String get helpGuideEyebrow => 'GUIDE';

  @override
  String get helpGuideTitle => 'かんたんな使い方';

  @override
  String get helpStep1Title => '食材を登録する';

  @override
  String get helpStep1Body =>
      '冷蔵庫の中をカメラで撮影すると、AIが食材を読み取って在庫に追加します。手入力でも登録できます。';

  @override
  String get helpStep2Title => '在庫と期限を確認する';

  @override
  String get helpStep2Body => '賞味期限が近い順に並びます。期限が近い食材はオレンジ、超過は赤で示されます。';

  @override
  String get helpStep3Title => '献立を提案してもらう';

  @override
  String get helpStep3Body => '在庫から作れる使い切りメニューを提案します。調理家電に合わせたレシピも表示されます。';

  @override
  String get helpStep4Title => '不足食材を買い物リストへ';

  @override
  String get helpStep4Body => '献立に足りない食材は、お使いのリマインダーの買い物リストへまとめて追加できます。';

  @override
  String get helpDataEyebrow => 'DATA';

  @override
  String get helpDataTitle => '賞味期限データについて';

  @override
  String get helpDataP1 =>
      '本アプリの賞味期限のめやすは、米国農務省（USDA）食品安全検査局（FSIS）が公開する FoodKeeper のデータをベースにしています。FoodKeeper は食品ごとの保存期間の指針をまとめた公的データセットです。';

  @override
  String get helpDataP2 =>
      '和食材や日本で一般的な食品など、FoodKeeper に含まれないものは、独自に保存期間の目安を補完しています。';

  @override
  String get helpDataCalloutTitle => '表示される期限はあくまで目安です';

  @override
  String get helpDataCalloutBody =>
      '保存状態・開封の有無・季節などにより、実際の日持ちは前後します。食品の状態は必ずご自身でご確認ください。';

  @override
  String get helpSourceTitle => '出典・参考データ';

  @override
  String get helpSourceFoodkeeperTitle => 'FoodKeeper';

  @override
  String get helpSourceFoodkeeperDesc => 'USDA / FSIS による食品保存期間の指針';

  @override
  String get helpSourceDatagovTitle => 'Data.gov（FoodKeeper Data）';

  @override
  String get helpSourceDatagovDesc => '米国政府の公開データカタログ';

  @override
  String get helpEditCalloutTitle => '賞味期限はいつでも手動で修正できます';

  @override
  String get helpEditCalloutBody =>
      '各食材の詳細画面から、賞味期限の日付をいつでも編集できます。実際のパッケージの表示や保存状態に合わせて、ご自身の値に上書きしてお使いください。';

  @override
  String get helpLegalTitle => '規約・プライバシー';

  @override
  String get helpLegalTerms => '利用規約';

  @override
  String get helpLegalPrivacy => 'プライバシーポリシー';

  @override
  String get helpLegalFaq => 'よくある質問・お問い合わせ';

  @override
  String get helpFooter =>
      'FoodKeeper data © USDA / FSIS（パブリックドメイン）\n© 2026 つかいきり';
}
