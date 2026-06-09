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
  String get settingsSupportAuthor => 'Support the developer';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsComingSoonValue => 'Coming soon';

  @override
  String get settingsSyncOffNote =>
      'Sync is off. Data is stored only on this device.';

  @override
  String settingsVersionLine(String version) {
    return 'Tsukaikiri · v$version';
  }
}
