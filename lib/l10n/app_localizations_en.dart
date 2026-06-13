// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tsukaikiri';

  @override
  String get inventoryTitle => 'Inventory';

  @override
  String get emptyInventory => 'No ingredients yet.\nTap + to add one.';

  @override
  String get addIngredient => 'Add ingredient';

  @override
  String get editIngredient => 'Edit ingredient';

  @override
  String get filterAll => 'All';

  @override
  String get categoryMeat => 'Meat';

  @override
  String get categoryFish => 'Fish';

  @override
  String get categoryVegetable => 'Vegetables';

  @override
  String get categoryFruit => 'Fruit';

  @override
  String get categoryDairy => 'Dairy';

  @override
  String get categoryEgg => 'Eggs';

  @override
  String get categoryGrain => 'Grains & Staples';

  @override
  String get categorySeasoning => 'Seasoning';

  @override
  String get categoryFrozen => 'Frozen';

  @override
  String get categoryBeverage => 'Beverages';

  @override
  String get categoryStaple => 'Pantry';

  @override
  String get categoryOther => 'Other';

  @override
  String get unitPiece => 'pcs';

  @override
  String get unitGram => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'L';

  @override
  String get unitBottle => 'bottles';

  @override
  String get unitSheet => 'sheets';

  @override
  String get unitPack => 'packs';

  @override
  String get unitBag => 'bags';

  @override
  String get unitGo => 'go';

  @override
  String get unitCup => 'cups';

  @override
  String get unitCan => 'cans';

  @override
  String get unitCustom => 'Custom…';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldQuantity => 'Quantity';

  @override
  String get fieldUnit => 'Unit';

  @override
  String get fieldExpiry => 'Expiry date';

  @override
  String get fieldExpiryOptional => 'Expiry date (optional)';

  @override
  String get customUnitLabel => 'Custom unit';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionClear => 'Clear';

  @override
  String get validationNameRequired => 'Please enter a name';

  @override
  String get validationQuantityInvalid => 'Enter a number greater than 0';

  @override
  String get validationUnitRequired => 'Please enter a unit';

  @override
  String get deleteConfirmTitle => 'Delete this ingredient?';

  @override
  String deleteConfirmBody(String name) {
    return '$name will be removed from your inventory.';
  }

  @override
  String get expiryExpired => 'Expired';

  @override
  String get expiryToday => 'Today';

  @override
  String expiryInDays(int days) {
    return '$days days left';
  }

  @override
  String get expiryNone => 'No date';

  @override
  String get selectIngredientPrompt => 'Select an ingredient to see details';

  @override
  String inventoryCountLine(int count) {
    return '$count items in the fridge · soonest first';
  }

  @override
  String get groupNow => 'Use up today or soon';

  @override
  String get groupWeek => 'This week';

  @override
  String get groupPlenty => 'Plenty of time';

  @override
  String get groupNoDate => 'No expiry date';

  @override
  String get swipeHint => '← Swipe a card left for quick actions';

  @override
  String get emptyInventoryTitle => 'Your inventory is empty';

  @override
  String get emptyInventoryBody =>
      'Add ingredients and we\'ll suggest use-it-up meals, starting with what expires soonest.';

  @override
  String get cameraRegister => 'Add by camera';

  @override
  String get manualAdd => 'Add manually';

  @override
  String get suggestRecipes => 'Suggest recipes';

  @override
  String get suggestRecipesSub => 'See use-it-up menu';

  @override
  String get actionUsedUp => 'Used up';

  @override
  String get actionUndo => 'Undo';

  @override
  String get toastUsedUp => 'Marked as used up';

  @override
  String get toastDeleted => 'Deleted';

  @override
  String get detailAddToShoppingList => 'Add to shopping list';

  @override
  String get detailAddedToShoppingList => 'Added to the shopping list';

  @override
  String get detailShoppingListNotConfigured =>
      'Choose a shopping list in Settings first';

  @override
  String get detailViewRecipe => 'See recipes';

  @override
  String get comingSoon => 'This feature is coming in a future update.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageJa => '日本語';

  @override
  String get languageEn => 'English';

  @override
  String get languageEs => 'Español';

  @override
  String get languageHint =>
      'Choosing \"System default\" follows your device language setting.';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionAi => 'AI (recognition & recipes)';

  @override
  String get settingsSectionIntegration => 'Integrations';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsSectionSupport => 'Support';

  @override
  String get settingsAiProvider => 'AI provider';

  @override
  String get settingsApiKey => 'API key';

  @override
  String get settingsImageRecognition => 'Image recognition';

  @override
  String get settingsShoppingList => 'Shopping list';

  @override
  String get settingsAppliances => 'Appliances';

  @override
  String get settingsCloudSync => 'Cloud sync';

  @override
  String get settingsSupportAuthor => 'Support the author';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsSyncOffNote =>
      'Sync is off. Data is stored only on this device.';

  @override
  String settingsVersionLine(String version) {
    return 'Tsukaikiri · v$version';
  }

  @override
  String get shellNavInventory => 'Inventory';

  @override
  String get shellNavCamera => 'Camera';

  @override
  String get shellNavMeals => 'Meal Planner';

  @override
  String get shellNavShopping => 'Shopping List';

  @override
  String get shellNavOnboarding => 'Setup Assistant';

  @override
  String get shellNavSettings => 'Settings';

  @override
  String get shellNavHelp => 'Help';

  @override
  String get shellSectionMain => 'MAIN';

  @override
  String get shellSectionOther => 'OTHER';

  @override
  String shellInventoryCount(int count) {
    return '$count items';
  }

  @override
  String get shellPlaceholder => 'This screen is coming soon.';

  @override
  String get shellPlaceholderTitle => 'Work in progress';

  @override
  String get desktopCategoryLabel => 'Category';

  @override
  String get desktopGroupNow => 'Today & Soon';

  @override
  String get desktopGroupWeek => 'This Week';

  @override
  String get desktopGroupPlenty => 'Plenty of Time';

  @override
  String get desktopSearchPlaceholder => 'Search ingredients…';

  @override
  String get desktopNoResults => 'No matching ingredients';

  @override
  String get desktopSelectPrompt => 'Select an ingredient';

  @override
  String get desktopSelectBody =>
      'Click an item in the list to view details and edit.';

  @override
  String get desktopAddIngredient => 'Add Ingredient';

  @override
  String get desktopAddIngredientShortcut => '⌘N';

  @override
  String get desktopCameraRegister => 'Camera';

  @override
  String get desktopCameraShortcut => '⌘K';

  @override
  String get desktopSuggestMeals => 'Suggest Meals';

  @override
  String get desktopSuggestMealsShortcut => '⌘R';

  @override
  String desktopQuantityUnit(String qty, String unit) {
    return '$qty $unit';
  }

  @override
  String desktopExpiryDaysOver(int n) {
    return '$n days over';
  }

  @override
  String get desktopExpiryToday => 'Today';

  @override
  String desktopExpiryDaysLeft(int n) {
    return '$n days left';
  }

  @override
  String get desktopDetailQty => 'Quantity';

  @override
  String get desktopDetailCategory => 'Category';

  @override
  String get desktopDetailExpiry => 'Expiry';

  @override
  String get desktopSuggestWithIngredient => 'Suggest meal with this';

  @override
  String get desktopUsedUp => 'Mark as used up';

  @override
  String get desktopDelete => 'Delete';

  @override
  String get desktopEditHint =>
      'Use the edit button to change name and quantity.';

  @override
  String desktopCountSuffix(int n) {
    return '$n items';
  }

  @override
  String get settingsNavAi => 'AI';

  @override
  String get settingsNavGeneral => 'General';

  @override
  String get settingsNavShopping => 'Shopping List';

  @override
  String get settingsNavAppliance => 'Appliances';

  @override
  String get settingsNavData => 'Data';

  @override
  String get settingsNavSupport => 'Support';

  @override
  String get settingsAiHeading => 'AI (recognition & meal suggestions)';

  @override
  String get settingsAiVisionYes => 'Image recognition';

  @override
  String get settingsAiVisionNo => 'No image recognition';

  @override
  String get settingsAiOnDeviceDesc => 'Free · no API key · offline';

  @override
  String get settingsAiOnDeviceUnavailable => 'Not available on this device';

  @override
  String get settingsAiOnDeviceNoKeyNote =>
      'On-device AI works with no API key. Nothing leaves your device.';

  @override
  String get settingsApiKeyHeading => 'API Key';

  @override
  String get settingsApiKeyPlaceholder => 'Paste your API key';

  @override
  String get settingsApiKeyNote =>
      'Your key is stored securely on this device.';

  @override
  String get settingsApiKeySave => 'Save';

  @override
  String get settingsApiKeyChange => 'Change';

  @override
  String get settingsApiKeyDelete => 'Delete';

  @override
  String settingsApiKeyGetLink(String provider) {
    return 'Get $provider key';
  }

  @override
  String settingsApiKeySavedMasked(String masked) {
    return 'Saved: $masked';
  }

  @override
  String get settingsModelHeading => 'Model';

  @override
  String get settingsModelFetch => 'Fetch models';

  @override
  String get settingsModelFetching => 'Fetching…';

  @override
  String get settingsModelNeedKey => 'Save an API key first to fetch models.';

  @override
  String settingsModelCurrent(String model) {
    return 'In use: $model';
  }

  @override
  String get settingsModelDefault => 'Default (auto)';

  @override
  String get settingsNetworkError =>
      'Please move to an area with good signal or connect to Wi-Fi.';

  @override
  String get settingsGeneralHeading => 'General';

  @override
  String get settingsShoppingHeading => 'Shopping List';

  @override
  String get settingsShoppingLinkedApp => 'Linked app';

  @override
  String get settingsShoppingReminders => 'Reminders (macOS)';

  @override
  String get settingsShoppingLists => 'Destination list';

  @override
  String get settingsShoppingLoad => 'Load lists';

  @override
  String get settingsShoppingLoading => 'Loading…';

  @override
  String settingsShoppingCurrent(String name) {
    return 'Current: $name';
  }

  @override
  String get settingsShoppingNone => 'Not selected';

  @override
  String get settingsShoppingNewName => 'New list name';

  @override
  String get settingsShoppingCreate => 'Create';

  @override
  String get settingsShoppingLoadError =>
      'Could not load lists. Check that access to Reminders is allowed.';

  @override
  String get settingsApplianceHeading => 'Appliances';

  @override
  String get settingsApplianceHotcook => 'Hotcook';

  @override
  String get settingsApplianceHealsio => 'Healsio';

  @override
  String get settingsApplianceNotOwned => 'Not owned';

  @override
  String get settingsApplianceSeries => 'Series';

  @override
  String get settingsApplianceCapacity => 'Capacity';

  @override
  String get settingsApplianceNote =>
      'Registered appliances get prioritized recipes, with portions adjusted to the model and capacity.';

  @override
  String get settingsDataHeading => 'Data Sync';

  @override
  String get settingsDataICloud => 'iCloud Sync';

  @override
  String get settingsDataComingSoon => 'Sync is coming soon.';

  @override
  String settingsDataLastBackup(String date) {
    return 'Last backup: $date';
  }

  @override
  String get settingsDataNeverBackedUp => 'No backup yet';

  @override
  String get settingsDataBackupButton => 'Backup Now';

  @override
  String get settingsDataRestoreButton => 'Restore from Backup';

  @override
  String get settingsDataBackupSuccess => 'Backup saved.';

  @override
  String get settingsDataRestoreConfirmTitle => 'Restore backup?';

  @override
  String settingsDataRestoreConfirmBody(int count) {
    return 'Current inventory ($count items) and settings will be replaced with the backup file contents. This cannot be undone.';
  }

  @override
  String get settingsDataRestoreConfirmOk => 'Restore';

  @override
  String get settingsDataSyncEnabledLabel => 'iCloud Auto Backup';

  @override
  String get settingsDataSyncEnabledDesc =>
      'Automatically backs up when inventory or settings change';

  @override
  String get settingsDataSyncKeepOnFailureLabel => 'Stay on when backup fails';

  @override
  String get settingsDataSyncKeepOnFailureDesc =>
      'Keep auto backup on even if the first backup fails (e.g. not signed in to iCloud). Turn off to revert the switch on failure.';

  @override
  String get settingsDataCameraPreserveLabel => 'Keep camera progress';

  @override
  String get settingsDataCameraPreserveDesc =>
      'Keep photos and edited candidates when you leave and return to the camera screen. Turn off to start fresh each time.';

  @override
  String settingsDataRestoreConfirmDate(String date) {
    return 'Backup date: $date';
  }

  @override
  String settingsDataRestoreConfirmCount(int count) {
    return 'Items in backup: $count';
  }

  @override
  String get settingsDataRestoreConfirmWarning =>
      'This will replace your current data. This cannot be undone.';

  @override
  String get settingsDataICloudNotAvailable =>
      'iCloud is not available. Please sign in to iCloud in System Settings.';

  @override
  String get settingsDataRestoreSuccess => 'Data restored.';

  @override
  String get settingsDataRestoreFormatError =>
      'Invalid backup file. Please use a backup created by Tsukaikiri.';

  @override
  String get settingsDataRestoreNewerVersionError =>
      'This backup was created by a newer version of Tsukaikiri. Please update the app first.';

  @override
  String get settingsDataNoBackupFound => 'No backup was found in iCloud.';

  @override
  String settingsDataSyncFailed(String detail) {
    return 'Something went wrong: $detail';
  }

  @override
  String get settingsSupportHeading => 'Support';

  @override
  String get settingsSupportComingSoon => '(coming soon)';

  @override
  String get settingsSupportHelp => 'Help';

  @override
  String get settingsSupportAbout => 'About';

  @override
  String settingsAboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsAboutClose => 'Close';

  @override
  String get mealsConditionsLabel => 'Conditions';

  @override
  String get mealsCondAuto => 'Any';

  @override
  String get mealsCondMainOnly => 'Main only';

  @override
  String get mealsCondOneMore => 'One more dish';

  @override
  String get mealsCondQuick => 'Quick';

  @override
  String get mealsSuggestButton => 'Suggest from inventory';

  @override
  String get mealsSuggestShortcut => '⌘R';

  @override
  String get mealsBeforeBody => 'Click \"Suggest from inventory\"';

  @override
  String get mealsGenerating => 'Generating recipes…';

  @override
  String get mealsLowStockBanner =>
      'Inventory is low, so suggestions include recipes that need shopping.';

  @override
  String mealsFocusBanner(String name) {
    return 'Suggesting from \"$name\"';
  }

  @override
  String get mealsErrorNetwork =>
      'Couldn\'t get suggestions. Move to a spot with better signal or connect to Wi-Fi, then retry.';

  @override
  String get mealsErrorNoApiKey =>
      'No AI API key is registered. Add an API key in Settings.';

  @override
  String get mealsRetry => 'Retry';

  @override
  String get mealsOpenSettings => 'Open Settings';

  @override
  String get mealsBadgeUseNear => 'Use soon';

  @override
  String get mealsApplianceHotcook => '🍲 Hotcook';

  @override
  String get mealsApplianceHealsio => '♨️ Healsio';

  @override
  String get mealsApplianceNormal => '🔥 Stovetop';

  @override
  String mealsCookMinutes(int minutes) {
    return '⏱ $minutes min';
  }

  @override
  String get mealsDetailEmpty => 'Select a recipe';

  @override
  String mealsCookTime(int minutes) {
    return 'Cook time $minutes min';
  }

  @override
  String get mealsToShopping => 'Add to shopping list';

  @override
  String get mealsDecide => 'Choose this recipe';

  @override
  String get mealsDecided => 'Chosen';

  @override
  String get mealsIngredientsHeading => 'Ingredients';

  @override
  String get mealsStepsHeading => 'Steps';

  @override
  String get mealsTitle => 'Meal ideas';

  @override
  String get mealsSubtitle => 'We\'ll plan use-it-up meals from what you have.';

  @override
  String get mealsConditionsPrompt => 'What kind of meal?';

  @override
  String get mealsGeneratingTitle => 'Planning your meals';

  @override
  String get mealsCancel => 'Cancel';

  @override
  String mealsResultCount(int count) {
    return '$count ideas from your inventory';
  }

  @override
  String get mealsResultBanner =>
      'Picked recipes that use up ingredients expiring soon.';

  @override
  String mealsToShoppingCount(int count) {
    return 'Add to shopping list ($count)';
  }

  @override
  String mealsShortageCount(int count) {
    return 'Buy $count';
  }

  @override
  String get mealsIngInStock => 'In stock';

  @override
  String get mealsIngToBuy => 'Buy';

  @override
  String get mealsErrorTitle => 'Couldn\'t get suggestions';

  @override
  String get mealsErrorNoApiKeyTitle => 'No API key registered';

  @override
  String get mealsBackToInventory => 'Back to inventory';

  @override
  String shoppingMissingCount(int n) {
    return 'Missing items ($n)';
  }

  @override
  String get shoppingSelectAll => 'Select all';

  @override
  String get shoppingDeselectAll => 'Deselect all';

  @override
  String shoppingForLabel(String meal) {
    return 'for $meal';
  }

  @override
  String get shoppingRightPanelTitle => 'Destination list';

  @override
  String get shoppingAppLabel => 'App';

  @override
  String get shoppingRemindersApp => 'Reminders (macOS)';

  @override
  String get shoppingLoadLists => 'Load lists';

  @override
  String get shoppingLoadingLists => 'Loading…';

  @override
  String get shoppingNewListName => 'New list name';

  @override
  String get shoppingCreateList => 'Create';

  @override
  String shoppingAddButton(String list, int n) {
    return 'Add to \"$list\" ($n items)';
  }

  @override
  String get shoppingAddButtonNoList => 'Select a list first';

  @override
  String shoppingDoneTitle(int n) {
    return '$n items added';
  }

  @override
  String shoppingDoneBody(String list) {
    return 'Find them in Reminders: \"$list\"';
  }

  @override
  String get shoppingOpenReminders => 'Open Reminders';

  @override
  String get shoppingBackToInventory => 'Back to inventory';

  @override
  String get shoppingEmptyTitle => 'No missing ingredients';

  @override
  String get shoppingEmptyBody =>
      'Decide on meals to see what you need to buy.';

  @override
  String get shoppingGoToMeals => 'Go to meal planner';

  @override
  String get shoppingErrorTitle => 'Could not add to list';

  @override
  String get shoppingErrorNetwork =>
      'Please move to an area with good signal or connect to Wi-Fi. Also check that Reminders access is allowed.';

  @override
  String get shoppingRetry => 'Retry';

  @override
  String get shoppingListLoadError =>
      'Could not load lists. Check that Reminders access is allowed.';

  @override
  String shoppingQtyUnit(int qty) {
    return '$qty pcs';
  }

  @override
  String get shoppingMobileTitle => 'Shopping list';

  @override
  String get shoppingMobileSubtitle => 'Ingredients missing for your meals';

  @override
  String shoppingMobileSummary(int total, int chosen) {
    return '$total missing · adding $chosen';
  }

  @override
  String get shoppingDest => 'Add to';

  @override
  String get shoppingChange => 'Change';

  @override
  String get shoppingAdding => 'Adding to Reminders…';

  @override
  String shoppingAddingDetail(String list, int count) {
    return 'Sending $count items to \"$list\"';
  }

  @override
  String get shoppingErrorRetainNotice => 'Your selection has been kept';

  @override
  String get shoppingTryAgain => 'Try again';

  @override
  String get shoppingBack => 'Back';

  @override
  String get cameraTitle => 'Camera Registration';

  @override
  String get cameraDropZoneTitle => 'Drop photos, or click to select';

  @override
  String get cameraDropZoneBody => 'Add up to 10 photos of your fridge';

  @override
  String cameraAnalyzeButton(int n) {
    return 'Analyze $n photo(s) ⌘R';
  }

  @override
  String get cameraMaxPhotosHint =>
      'You can add up to 10 photos. Extra photos were skipped.';

  @override
  String get cameraAnalyzingTitle => 'AI is analyzing your photos…';

  @override
  String get cameraAnalyzingBody =>
      'Recognizing ingredients. Please wait a moment.';

  @override
  String cameraReviewHeader(int n) {
    return 'Detected ingredients ($n items)';
  }

  @override
  String get cameraConfHighLabel => 'High';

  @override
  String get cameraConfMidLabel => 'Mid';

  @override
  String get cameraConfLowLabel => 'Low';

  @override
  String cameraConfirmButton(int n) {
    return 'Add selected ($n items)';
  }

  @override
  String get cameraEditNameLabel => 'Name';

  @override
  String get cameraEditQtyLabel => 'Quantity';

  @override
  String get cameraEditUnitLabel => 'Unit';

  @override
  String get cameraEditCategoryLabel => 'Category';

  @override
  String get cameraErrorNetworkTitle => 'Could not analyze photos';

  @override
  String get cameraErrorNetworkBody =>
      'Please move to an area with better signal or connect to Wi-Fi.';

  @override
  String get cameraErrorNoApiKeyTitle => 'No API key registered';

  @override
  String get cameraErrorNoApiKeyBody =>
      'Go to Settings and add an API key to enable AI recognition.';

  @override
  String get cameraErrorNoVisionTitle =>
      'This provider does not support image recognition';

  @override
  String get cameraErrorNoVisionBody =>
      'Switch to a provider with image recognition in Settings.';

  @override
  String get cameraErrorRetry => 'Try again';

  @override
  String get cameraErrorOpenSettings => 'Open Settings';

  @override
  String cameraAddedToast(int n) {
    return 'Added $n items to inventory';
  }

  @override
  String get cameraMobileCaptureTitle => 'Photograph your fridge';

  @override
  String get cameraMobileAddPhotos => 'Add photos';

  @override
  String cameraMobilePhotoCount(int n) {
    return '$n / 10';
  }

  @override
  String cameraMobileAnalyzeButton(int n) {
    return 'Analyze $n photo(s)';
  }

  @override
  String get cameraMobileReviewTitle => 'Detected ingredients';

  @override
  String cameraMobileReviewSummary(int total, int chosen) {
    return '$total candidates · $chosen selected';
  }

  @override
  String get cameraMobileReviewHint =>
      'Select the items to keep and adjust the name, quantity, or category as needed';

  @override
  String get cameraMobileReviewFootnote =>
      'These candidates were read automatically by AI. You can review them before adding.';

  @override
  String get cameraMobileErrorLater => 'Analyze later';

  @override
  String get onboardingRailTitle => 'Setup Assistant';

  @override
  String get onboardingStep0 => 'Welcome';

  @override
  String get onboardingStep1 => 'Choose AI';

  @override
  String get onboardingStep2 => 'Reminders';

  @override
  String get onboardingStep3 => 'Pick a List';

  @override
  String get onboardingStep4 => 'Appliances';

  @override
  String get onboardingStep5 => 'Done';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Tsukaikiri';

  @override
  String get onboardingWelcomeSub =>
      'Register the ingredients in your fridge and get use-it-up meal suggestions.\nLet\'s start with a quick setup.';

  @override
  String get onboardingWelcomeFeature1Title => 'Snap to register';

  @override
  String get onboardingWelcomeFeature1Body =>
      'Add ingredients in bulk with your camera';

  @override
  String get onboardingWelcomeFeature2Title => 'Use-it-up meals';

  @override
  String get onboardingWelcomeFeature2Body =>
      'Prioritizes ingredients expiring soonest';

  @override
  String get onboardingWelcomeFeature3Title => 'Shopping list';

  @override
  String get onboardingWelcomeFeature3Body =>
      'Auto-adds missing items to Reminders';

  @override
  String get onboardingWelcomeStart => 'Get Started';

  @override
  String get onboardingAiTitle => 'AI is ready to use';

  @override
  String get onboardingAiSub =>
      'The AI runs on your device, so no API key is needed.';

  @override
  String onboardingAiOnDeviceReady(String name) {
    return '$name runs on your device — free, no API key, offline. Nothing leaves your device.';
  }

  @override
  String get onboardingAiOnDeviceMissing =>
      'On-device AI isn\'t available on this device. You can add your own API key later in Settings → AI to use cloud AI.';

  @override
  String get onboardingAiSkip => 'Set up later';

  @override
  String get onboardingAiKeyLabel => 'API Key';

  @override
  String onboardingAiGetKeyLink(String provider) {
    return 'Get $provider API key';
  }

  @override
  String get onboardingAiSelected => 'Selected';

  @override
  String get onboardingLinkTitle => 'Connect Reminders';

  @override
  String get onboardingLinkSub =>
      'Missing ingredients will be automatically added to macOS Reminders.';

  @override
  String get onboardingLinkSkip => 'Later';

  @override
  String get onboardingLinkApp => 'App';

  @override
  String get onboardingLinkAppValue => 'Reminders (macOS)';

  @override
  String get onboardingLinkAction => 'Can do';

  @override
  String get onboardingLinkActionValue => 'Add items to a shopping list';

  @override
  String get onboardingLinkPrivacy => 'Privacy';

  @override
  String get onboardingLinkPrivacyValue =>
      'Photos are processed on this Mac only';

  @override
  String get onboardingLinkButton => 'Allow Access to Reminders';

  @override
  String get onboardingLinkDone => 'Connected to Reminders';

  @override
  String get onboardingLinkError =>
      'Could not access Reminders. You can set this up later in Settings.';

  @override
  String get onboardingListTitle => 'Choose a Destination List';

  @override
  String get onboardingListSub =>
      'Select the Reminders list where shopping items will be added.';

  @override
  String get onboardingListSkip => 'Later';

  @override
  String get onboardingListNewName => 'New list name…';

  @override
  String get onboardingListCreate => 'Create';

  @override
  String get onboardingListLoading => 'Loading…';

  @override
  String get onboardingApplianceTitle => 'Register Appliances';

  @override
  String get onboardingApplianceSub =>
      'Select the appliances you own for customized recipes.';

  @override
  String get onboardingApplianceSkip => 'I don\'t own any';

  @override
  String get onboardingApplianceSeries => 'Series';

  @override
  String get onboardingFinishTitle => 'All set!';

  @override
  String get onboardingFinishSub =>
      'Register your fridge ingredients and start getting use-it-up meal suggestions.';

  @override
  String get onboardingFinishAiLabel => 'AI';

  @override
  String get onboardingFinishListLabel => 'Reminders list';

  @override
  String get onboardingFinishApplianceLabel => 'Appliances';

  @override
  String get onboardingFinishNotSet => 'Not configured';

  @override
  String get onboardingFinishSettingsNote =>
      'You can change these settings anytime in the Settings screen.';

  @override
  String get onboardingFinishStart => 'Register ingredients and start';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get helpTitle => 'Help / About';

  @override
  String get helpAppTagline =>
      'An app to help you use up fridge ingredients by suggesting use-it-up meals.';

  @override
  String get helpGuideEyebrow => 'GUIDE';

  @override
  String get helpGuideTitle => 'How to Use';

  @override
  String get helpStep1Title => 'Register ingredients';

  @override
  String get helpStep1Body =>
      'Take a photo of your fridge and AI will recognize ingredients to add to your inventory. You can also add them manually.';

  @override
  String get helpStep2Title => 'Check inventory and expiry';

  @override
  String get helpStep2Body =>
      'Ingredients are sorted by expiry date. Those expiring soon are shown in orange; overdue ones in red.';

  @override
  String get helpStep3Title => 'Get meal suggestions';

  @override
  String get helpStep3Body =>
      'Get use-it-up meal ideas from your current inventory. Recipes tailored to your appliances are included.';

  @override
  String get helpStep4Title => 'Add missing items to shopping list';

  @override
  String get helpStep4Body =>
      'Ingredients you need for your chosen meals are added in bulk to your Reminders shopping list.';

  @override
  String get helpDataEyebrow => 'DATA';

  @override
  String get helpDataTitle => 'About Expiry Data';

  @override
  String get helpDataP1 =>
      'The expiry guidelines in this app are based on the FoodKeeper dataset published by the USDA Food Safety and Inspection Service (FSIS). FoodKeeper is an official dataset summarizing recommended storage periods for various foods.';

  @override
  String get helpDataP2 =>
      'Foods not covered by FoodKeeper — such as Japanese-specific ingredients — are supplemented with independently researched storage guidelines.';

  @override
  String get helpDataCalloutTitle => 'Dates shown are estimates only';

  @override
  String get helpDataCalloutBody =>
      'Actual shelf life varies depending on storage conditions, whether the package has been opened, and the season. Always check the condition of food yourself.';

  @override
  String get helpSourceTitle => 'Sources & References';

  @override
  String get helpSourceFoodkeeperTitle => 'FoodKeeper';

  @override
  String get helpSourceFoodkeeperDesc => 'USDA / FSIS food storage guidelines';

  @override
  String get helpSourceDatagovTitle => 'Data.gov (FoodKeeper Data)';

  @override
  String get helpSourceDatagovDesc => 'US Government open data catalog';

  @override
  String get helpEditCalloutTitle => 'You can edit expiry dates anytime';

  @override
  String get helpEditCalloutBody =>
      'Open the detail view for any ingredient to update its expiry date. Override with the date on the package or your own judgment.';

  @override
  String get helpLegalTitle => 'Legal & Privacy';

  @override
  String get helpLegalTerms => 'Terms of Use';

  @override
  String get helpLegalPrivacy => 'Privacy Policy';

  @override
  String get helpLegalFaq => 'FAQ & Support';

  @override
  String get helpFooter =>
      'FoodKeeper data © USDA / FSIS (Public Domain)\n© 2026 Tsukaikiri';
}
