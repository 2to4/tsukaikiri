import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Tsukaikiri'**
  String get appTitle;

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryTitle;

  /// No description provided for @emptyInventory.
  ///
  /// In en, this message translates to:
  /// **'No ingredients yet.\nTap + to add one.'**
  String get emptyInventory;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addIngredient;

  /// No description provided for @editIngredient.
  ///
  /// In en, this message translates to:
  /// **'Edit ingredient'**
  String get editIngredient;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @categoryMeat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get categoryMeat;

  /// No description provided for @categoryFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get categoryFish;

  /// No description provided for @categoryVegetable.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get categoryVegetable;

  /// No description provided for @categoryFruit.
  ///
  /// In en, this message translates to:
  /// **'Fruit'**
  String get categoryFruit;

  /// No description provided for @categoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get categoryDairy;

  /// No description provided for @categoryEgg.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get categoryEgg;

  /// No description provided for @categoryGrain.
  ///
  /// In en, this message translates to:
  /// **'Grains & Staples'**
  String get categoryGrain;

  /// No description provided for @categorySeasoning.
  ///
  /// In en, this message translates to:
  /// **'Seasoning'**
  String get categorySeasoning;

  /// No description provided for @categoryFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get categoryFrozen;

  /// No description provided for @categoryBeverage.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get categoryBeverage;

  /// No description provided for @categoryStaple.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get categoryStaple;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get unitPiece;

  /// No description provided for @unitGram.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitGram;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitL.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get unitL;

  /// No description provided for @unitBottle.
  ///
  /// In en, this message translates to:
  /// **'bottles'**
  String get unitBottle;

  /// No description provided for @unitSheet.
  ///
  /// In en, this message translates to:
  /// **'sheets'**
  String get unitSheet;

  /// No description provided for @unitPack.
  ///
  /// In en, this message translates to:
  /// **'packs'**
  String get unitPack;

  /// No description provided for @unitBag.
  ///
  /// In en, this message translates to:
  /// **'bags'**
  String get unitBag;

  /// No description provided for @unitGo.
  ///
  /// In en, this message translates to:
  /// **'go'**
  String get unitGo;

  /// No description provided for @unitCup.
  ///
  /// In en, this message translates to:
  /// **'cups'**
  String get unitCup;

  /// No description provided for @unitCan.
  ///
  /// In en, this message translates to:
  /// **'cans'**
  String get unitCan;

  /// No description provided for @unitCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get unitCustom;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @fieldQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get fieldQuantity;

  /// No description provided for @fieldUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get fieldUnit;

  /// No description provided for @fieldExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get fieldExpiry;

  /// No description provided for @fieldExpiryOptional.
  ///
  /// In en, this message translates to:
  /// **'Expiry date (optional)'**
  String get fieldExpiryOptional;

  /// No description provided for @customUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom unit'**
  String get customUnitLabel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get validationNameRequired;

  /// No description provided for @validationQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number greater than 0'**
  String get validationQuantityInvalid;

  /// No description provided for @validationUnitRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a unit'**
  String get validationUnitRequired;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this ingredient?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from your inventory.'**
  String deleteConfirmBody(String name);

  /// No description provided for @expiryExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiryExpired;

  /// No description provided for @expiryToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get expiryToday;

  /// No description provided for @expiryInDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String expiryInDays(int days);

  /// No description provided for @expiryNone.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get expiryNone;

  /// No description provided for @selectIngredientPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select an ingredient to see details'**
  String get selectIngredientPrompt;

  /// No description provided for @inventoryCountLine.
  ///
  /// In en, this message translates to:
  /// **'{count} items in the fridge · soonest first'**
  String inventoryCountLine(int count);

  /// No description provided for @groupNow.
  ///
  /// In en, this message translates to:
  /// **'Use up today or soon'**
  String get groupNow;

  /// No description provided for @groupWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get groupWeek;

  /// No description provided for @groupPlenty.
  ///
  /// In en, this message translates to:
  /// **'Plenty of time'**
  String get groupPlenty;

  /// No description provided for @groupNoDate.
  ///
  /// In en, this message translates to:
  /// **'No expiry date'**
  String get groupNoDate;

  /// No description provided for @swipeHint.
  ///
  /// In en, this message translates to:
  /// **'← Swipe a card left for quick actions'**
  String get swipeHint;

  /// No description provided for @emptyInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your inventory is empty'**
  String get emptyInventoryTitle;

  /// No description provided for @emptyInventoryBody.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients and we\'ll suggest use-it-up meals, starting with what expires soonest.'**
  String get emptyInventoryBody;

  /// No description provided for @cameraRegister.
  ///
  /// In en, this message translates to:
  /// **'Add by camera'**
  String get cameraRegister;

  /// No description provided for @manualAdd.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get manualAdd;

  /// No description provided for @suggestRecipes.
  ///
  /// In en, this message translates to:
  /// **'Suggest recipes'**
  String get suggestRecipes;

  /// No description provided for @suggestRecipesSub.
  ///
  /// In en, this message translates to:
  /// **'See use-it-up menu'**
  String get suggestRecipesSub;

  /// No description provided for @actionUsedUp.
  ///
  /// In en, this message translates to:
  /// **'Used up'**
  String get actionUsedUp;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @toastUsedUp.
  ///
  /// In en, this message translates to:
  /// **'Marked as used up'**
  String get toastUsedUp;

  /// No description provided for @toastDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get toastDeleted;

  /// No description provided for @detailAddToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Add to shopping list'**
  String get detailAddToShoppingList;

  /// No description provided for @detailViewRecipe.
  ///
  /// In en, this message translates to:
  /// **'See recipes'**
  String get detailViewRecipe;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming in a future update.'**
  String get comingSoon;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageJa.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJa;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageHint.
  ///
  /// In en, this message translates to:
  /// **'Choosing \"System default\" follows your device language setting.'**
  String get languageHint;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionAi.
  ///
  /// In en, this message translates to:
  /// **'AI (recognition & recipes)'**
  String get settingsSectionAi;

  /// No description provided for @settingsSectionIntegration.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get settingsSectionIntegration;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  /// No description provided for @settingsSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSectionSupport;

  /// No description provided for @settingsAiProvider.
  ///
  /// In en, this message translates to:
  /// **'AI provider'**
  String get settingsAiProvider;

  /// No description provided for @settingsApiKey.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get settingsApiKey;

  /// No description provided for @settingsImageRecognition.
  ///
  /// In en, this message translates to:
  /// **'Image recognition'**
  String get settingsImageRecognition;

  /// No description provided for @settingsShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get settingsShoppingList;

  /// No description provided for @settingsAppliances.
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get settingsAppliances;

  /// No description provided for @settingsCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get settingsCloudSync;

  /// No description provided for @settingsSupportAuthor.
  ///
  /// In en, this message translates to:
  /// **'Support the author'**
  String get settingsSupportAuthor;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelp;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsComingSoonValue.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get settingsComingSoonValue;

  /// No description provided for @settingsSyncOffNote.
  ///
  /// In en, this message translates to:
  /// **'Sync is off. Data is stored only on this device.'**
  String get settingsSyncOffNote;

  /// No description provided for @settingsVersionLine.
  ///
  /// In en, this message translates to:
  /// **'Tsukaikiri · v{version}'**
  String settingsVersionLine(String version);

  /// No description provided for @shellNavInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get shellNavInventory;

  /// No description provided for @shellNavCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get shellNavCamera;

  /// No description provided for @shellNavMeals.
  ///
  /// In en, this message translates to:
  /// **'Meal Planner'**
  String get shellNavMeals;

  /// No description provided for @shellNavShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shellNavShopping;

  /// No description provided for @shellNavOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Setup Assistant'**
  String get shellNavOnboarding;

  /// No description provided for @shellNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get shellNavSettings;

  /// No description provided for @shellNavHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get shellNavHelp;

  /// No description provided for @shellSectionMain.
  ///
  /// In en, this message translates to:
  /// **'MAIN'**
  String get shellSectionMain;

  /// No description provided for @shellSectionOther.
  ///
  /// In en, this message translates to:
  /// **'OTHER'**
  String get shellSectionOther;

  /// No description provided for @shellInventoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String shellInventoryCount(int count);

  /// No description provided for @shellPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'This screen is coming soon.'**
  String get shellPlaceholder;

  /// No description provided for @shellPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Work in progress'**
  String get shellPlaceholderTitle;

  /// No description provided for @desktopCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get desktopCategoryLabel;

  /// No description provided for @desktopGroupNow.
  ///
  /// In en, this message translates to:
  /// **'Today & Soon'**
  String get desktopGroupNow;

  /// No description provided for @desktopGroupWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get desktopGroupWeek;

  /// No description provided for @desktopGroupPlenty.
  ///
  /// In en, this message translates to:
  /// **'Plenty of Time'**
  String get desktopGroupPlenty;

  /// No description provided for @desktopSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search ingredients…'**
  String get desktopSearchPlaceholder;

  /// No description provided for @desktopNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching ingredients'**
  String get desktopNoResults;

  /// No description provided for @desktopSelectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select an ingredient'**
  String get desktopSelectPrompt;

  /// No description provided for @desktopSelectBody.
  ///
  /// In en, this message translates to:
  /// **'Click an item in the list to view details and edit.'**
  String get desktopSelectBody;

  /// No description provided for @desktopAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get desktopAddIngredient;

  /// No description provided for @desktopAddIngredientShortcut.
  ///
  /// In en, this message translates to:
  /// **'⌘N'**
  String get desktopAddIngredientShortcut;

  /// No description provided for @desktopCameraRegister.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get desktopCameraRegister;

  /// No description provided for @desktopCameraShortcut.
  ///
  /// In en, this message translates to:
  /// **'⌘K'**
  String get desktopCameraShortcut;

  /// No description provided for @desktopSuggestMeals.
  ///
  /// In en, this message translates to:
  /// **'Suggest Meals'**
  String get desktopSuggestMeals;

  /// No description provided for @desktopSuggestMealsShortcut.
  ///
  /// In en, this message translates to:
  /// **'⌘R'**
  String get desktopSuggestMealsShortcut;

  /// No description provided for @desktopQuantityUnit.
  ///
  /// In en, this message translates to:
  /// **'{qty} {unit}'**
  String desktopQuantityUnit(String qty, String unit);

  /// No description provided for @desktopExpiryDaysOver.
  ///
  /// In en, this message translates to:
  /// **'{n} days over'**
  String desktopExpiryDaysOver(int n);

  /// No description provided for @desktopExpiryToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get desktopExpiryToday;

  /// No description provided for @desktopExpiryDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{n} days left'**
  String desktopExpiryDaysLeft(int n);

  /// No description provided for @desktopDetailQty.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get desktopDetailQty;

  /// No description provided for @desktopDetailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get desktopDetailCategory;

  /// No description provided for @desktopDetailExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get desktopDetailExpiry;

  /// No description provided for @desktopSuggestWithIngredient.
  ///
  /// In en, this message translates to:
  /// **'Suggest meal with this'**
  String get desktopSuggestWithIngredient;

  /// No description provided for @desktopUsedUp.
  ///
  /// In en, this message translates to:
  /// **'Mark as used up'**
  String get desktopUsedUp;

  /// No description provided for @desktopDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get desktopDelete;

  /// No description provided for @desktopEditHint.
  ///
  /// In en, this message translates to:
  /// **'Use the edit button to change name and quantity.'**
  String get desktopEditHint;

  /// No description provided for @desktopCountSuffix.
  ///
  /// In en, this message translates to:
  /// **'{n} items'**
  String desktopCountSuffix(int n);

  /// No description provided for @settingsNavAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get settingsNavAi;

  /// No description provided for @settingsNavGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsNavGeneral;

  /// No description provided for @settingsNavShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get settingsNavShopping;

  /// No description provided for @settingsNavAppliance.
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get settingsNavAppliance;

  /// No description provided for @settingsNavData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsNavData;

  /// No description provided for @settingsNavSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsNavSupport;

  /// No description provided for @settingsAiHeading.
  ///
  /// In en, this message translates to:
  /// **'AI (recognition & meal suggestions)'**
  String get settingsAiHeading;

  /// No description provided for @settingsAiVisionYes.
  ///
  /// In en, this message translates to:
  /// **'Image recognition'**
  String get settingsAiVisionYes;

  /// No description provided for @settingsAiVisionNo.
  ///
  /// In en, this message translates to:
  /// **'No image recognition'**
  String get settingsAiVisionNo;

  /// No description provided for @settingsApiKeyHeading.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get settingsApiKeyHeading;

  /// No description provided for @settingsApiKeyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Paste your API key'**
  String get settingsApiKeyPlaceholder;

  /// No description provided for @settingsApiKeyNote.
  ///
  /// In en, this message translates to:
  /// **'Your key is stored securely on this device.'**
  String get settingsApiKeyNote;

  /// No description provided for @settingsApiKeySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsApiKeySave;

  /// No description provided for @settingsApiKeyChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get settingsApiKeyChange;

  /// No description provided for @settingsApiKeyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsApiKeyDelete;

  /// No description provided for @settingsApiKeyGetLink.
  ///
  /// In en, this message translates to:
  /// **'Get {provider} key'**
  String settingsApiKeyGetLink(String provider);

  /// No description provided for @settingsApiKeySavedMasked.
  ///
  /// In en, this message translates to:
  /// **'Saved: {masked}'**
  String settingsApiKeySavedMasked(String masked);

  /// No description provided for @settingsModelHeading.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get settingsModelHeading;

  /// No description provided for @settingsModelFetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch models'**
  String get settingsModelFetch;

  /// No description provided for @settingsModelFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching…'**
  String get settingsModelFetching;

  /// No description provided for @settingsModelNeedKey.
  ///
  /// In en, this message translates to:
  /// **'Save an API key first to fetch models.'**
  String get settingsModelNeedKey;

  /// No description provided for @settingsModelCurrent.
  ///
  /// In en, this message translates to:
  /// **'In use: {model}'**
  String settingsModelCurrent(String model);

  /// No description provided for @settingsModelDefault.
  ///
  /// In en, this message translates to:
  /// **'Default (auto)'**
  String get settingsModelDefault;

  /// No description provided for @settingsNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Please move to an area with good signal or connect to Wi-Fi.'**
  String get settingsNetworkError;

  /// No description provided for @settingsGeneralHeading.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneralHeading;

  /// No description provided for @settingsShoppingHeading.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get settingsShoppingHeading;

  /// No description provided for @settingsShoppingLinkedApp.
  ///
  /// In en, this message translates to:
  /// **'Linked app'**
  String get settingsShoppingLinkedApp;

  /// No description provided for @settingsShoppingReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders (macOS)'**
  String get settingsShoppingReminders;

  /// No description provided for @settingsShoppingLists.
  ///
  /// In en, this message translates to:
  /// **'Destination list'**
  String get settingsShoppingLists;

  /// No description provided for @settingsShoppingLoad.
  ///
  /// In en, this message translates to:
  /// **'Load lists'**
  String get settingsShoppingLoad;

  /// No description provided for @settingsShoppingLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get settingsShoppingLoading;

  /// No description provided for @settingsShoppingCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current: {name}'**
  String settingsShoppingCurrent(String name);

  /// No description provided for @settingsShoppingNone.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get settingsShoppingNone;

  /// No description provided for @settingsShoppingNewName.
  ///
  /// In en, this message translates to:
  /// **'New list name'**
  String get settingsShoppingNewName;

  /// No description provided for @settingsShoppingCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get settingsShoppingCreate;

  /// No description provided for @settingsShoppingLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load lists. Check that access to Reminders is allowed.'**
  String get settingsShoppingLoadError;

  /// No description provided for @settingsApplianceHeading.
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get settingsApplianceHeading;

  /// No description provided for @settingsApplianceHotcook.
  ///
  /// In en, this message translates to:
  /// **'Hotcook'**
  String get settingsApplianceHotcook;

  /// No description provided for @settingsApplianceHealsio.
  ///
  /// In en, this message translates to:
  /// **'Healsio'**
  String get settingsApplianceHealsio;

  /// No description provided for @settingsApplianceNotOwned.
  ///
  /// In en, this message translates to:
  /// **'Not owned'**
  String get settingsApplianceNotOwned;

  /// No description provided for @settingsApplianceSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get settingsApplianceSeries;

  /// No description provided for @settingsApplianceCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get settingsApplianceCapacity;

  /// No description provided for @settingsApplianceNote.
  ///
  /// In en, this message translates to:
  /// **'Registered appliances get prioritized recipes, with portions adjusted to the model and capacity.'**
  String get settingsApplianceNote;

  /// No description provided for @settingsDataHeading.
  ///
  /// In en, this message translates to:
  /// **'Data Sync'**
  String get settingsDataHeading;

  /// No description provided for @settingsDataICloud.
  ///
  /// In en, this message translates to:
  /// **'iCloud Sync'**
  String get settingsDataICloud;

  /// No description provided for @settingsDataComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Sync is coming soon.'**
  String get settingsDataComingSoon;

  /// No description provided for @settingsSupportHeading.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupportHeading;

  /// No description provided for @settingsSupportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'(coming soon)'**
  String get settingsSupportComingSoon;

  /// No description provided for @settingsSupportHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsSupportHelp;

  /// No description provided for @settingsSupportAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSupportAbout;

  /// No description provided for @settingsAboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsAboutVersion(String version);

  /// No description provided for @settingsAboutClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsAboutClose;

  /// No description provided for @mealsConditionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get mealsConditionsLabel;

  /// No description provided for @mealsCondAuto.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get mealsCondAuto;

  /// No description provided for @mealsCondMainOnly.
  ///
  /// In en, this message translates to:
  /// **'Main only'**
  String get mealsCondMainOnly;

  /// No description provided for @mealsCondOneMore.
  ///
  /// In en, this message translates to:
  /// **'One more dish'**
  String get mealsCondOneMore;

  /// No description provided for @mealsCondQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get mealsCondQuick;

  /// No description provided for @mealsSuggestButton.
  ///
  /// In en, this message translates to:
  /// **'Suggest from inventory'**
  String get mealsSuggestButton;

  /// No description provided for @mealsSuggestShortcut.
  ///
  /// In en, this message translates to:
  /// **'⌘R'**
  String get mealsSuggestShortcut;

  /// No description provided for @mealsBeforeBody.
  ///
  /// In en, this message translates to:
  /// **'Click \"Suggest from inventory\"'**
  String get mealsBeforeBody;

  /// No description provided for @mealsGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating recipes…'**
  String get mealsGenerating;

  /// No description provided for @mealsLowStockBanner.
  ///
  /// In en, this message translates to:
  /// **'Inventory is low, so suggestions include recipes that need shopping.'**
  String get mealsLowStockBanner;

  /// No description provided for @mealsErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get suggestions. Move to a spot with better signal or connect to Wi-Fi, then retry.'**
  String get mealsErrorNetwork;

  /// No description provided for @mealsErrorNoApiKey.
  ///
  /// In en, this message translates to:
  /// **'No AI API key is registered. Add an API key in Settings.'**
  String get mealsErrorNoApiKey;

  /// No description provided for @mealsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get mealsRetry;

  /// No description provided for @mealsOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get mealsOpenSettings;

  /// No description provided for @mealsBadgeUseNear.
  ///
  /// In en, this message translates to:
  /// **'Use soon'**
  String get mealsBadgeUseNear;

  /// No description provided for @mealsApplianceHotcook.
  ///
  /// In en, this message translates to:
  /// **'🍲 Hotcook'**
  String get mealsApplianceHotcook;

  /// No description provided for @mealsApplianceHealsio.
  ///
  /// In en, this message translates to:
  /// **'♨️ Healsio'**
  String get mealsApplianceHealsio;

  /// No description provided for @mealsApplianceNormal.
  ///
  /// In en, this message translates to:
  /// **'🔥 Stovetop'**
  String get mealsApplianceNormal;

  /// No description provided for @mealsCookMinutes.
  ///
  /// In en, this message translates to:
  /// **'⏱ {minutes} min'**
  String mealsCookMinutes(int minutes);

  /// No description provided for @mealsDetailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Select a recipe'**
  String get mealsDetailEmpty;

  /// No description provided for @mealsCookTime.
  ///
  /// In en, this message translates to:
  /// **'Cook time {minutes} min'**
  String mealsCookTime(int minutes);

  /// No description provided for @mealsToShopping.
  ///
  /// In en, this message translates to:
  /// **'Add to shopping list'**
  String get mealsToShopping;

  /// No description provided for @mealsDecide.
  ///
  /// In en, this message translates to:
  /// **'Choose this recipe'**
  String get mealsDecide;

  /// No description provided for @mealsDecided.
  ///
  /// In en, this message translates to:
  /// **'Chosen'**
  String get mealsDecided;

  /// No description provided for @mealsIngredientsHeading.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get mealsIngredientsHeading;

  /// No description provided for @mealsStepsHeading.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get mealsStepsHeading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
