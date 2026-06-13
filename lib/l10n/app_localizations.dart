import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
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
    Locale('es'),
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

  /// No description provided for @detailAddedToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Added to the shopping list'**
  String get detailAddedToShoppingList;

  /// No description provided for @detailShoppingListNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Choose a shopping list in Settings first'**
  String get detailShoppingListNotConfigured;

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

  /// No description provided for @languageEs.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageEs;

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

  /// No description provided for @settingsAiOnDeviceDesc.
  ///
  /// In en, this message translates to:
  /// **'Free · no API key · offline'**
  String get settingsAiOnDeviceDesc;

  /// No description provided for @settingsAiOnDeviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get settingsAiOnDeviceUnavailable;

  /// No description provided for @settingsAiOnDeviceNoKeyNote.
  ///
  /// In en, this message translates to:
  /// **'On-device AI works with no API key. Nothing leaves your device.'**
  String get settingsAiOnDeviceNoKeyNote;

  /// No description provided for @aiUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'AI isn\'t available'**
  String get aiUnavailableTitle;

  /// No description provided for @aiUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This device doesn\'t support on-device AI. You can add your own API key in Settings → AI to use cloud AI. Inventory and shopping list still work without AI.'**
  String get aiUnavailableBody;

  /// No description provided for @aiCloudKeyMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'No API key registered'**
  String get aiCloudKeyMissingTitle;

  /// No description provided for @aiCloudKeyMissingBody.
  ///
  /// In en, this message translates to:
  /// **'The selected cloud AI has no API key, or the key is invalid. Add a key in Settings → AI, or switch to on-device AI on supported devices. Inventory and shopping list still work without AI.'**
  String get aiCloudKeyMissingBody;

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

  /// No description provided for @settingsDataLastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String settingsDataLastBackup(String date);

  /// No description provided for @settingsDataNeverBackedUp.
  ///
  /// In en, this message translates to:
  /// **'No backup yet'**
  String get settingsDataNeverBackedUp;

  /// No description provided for @settingsDataBackupButton.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get settingsDataBackupButton;

  /// No description provided for @settingsDataRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get settingsDataRestoreButton;

  /// No description provided for @settingsDataBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup saved.'**
  String get settingsDataBackupSuccess;

  /// No description provided for @settingsDataRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get settingsDataRestoreConfirmTitle;

  /// No description provided for @settingsDataRestoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Current inventory ({count} items) and settings will be replaced with the backup file contents. This cannot be undone.'**
  String settingsDataRestoreConfirmBody(int count);

  /// No description provided for @settingsDataRestoreConfirmOk.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get settingsDataRestoreConfirmOk;

  /// No description provided for @settingsDataSyncEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'iCloud Auto Backup'**
  String get settingsDataSyncEnabledLabel;

  /// No description provided for @settingsDataSyncEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically backs up when inventory or settings change'**
  String get settingsDataSyncEnabledDesc;

  /// No description provided for @settingsDataSyncKeepOnFailureLabel.
  ///
  /// In en, this message translates to:
  /// **'Stay on when backup fails'**
  String get settingsDataSyncKeepOnFailureLabel;

  /// No description provided for @settingsDataSyncKeepOnFailureDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep auto backup on even if the first backup fails (e.g. not signed in to iCloud). Turn off to revert the switch on failure.'**
  String get settingsDataSyncKeepOnFailureDesc;

  /// No description provided for @settingsDataCameraPreserveLabel.
  ///
  /// In en, this message translates to:
  /// **'Keep camera progress'**
  String get settingsDataCameraPreserveLabel;

  /// No description provided for @settingsDataCameraPreserveDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep photos and edited candidates when you leave and return to the camera screen. Turn off to start fresh each time.'**
  String get settingsDataCameraPreserveDesc;

  /// No description provided for @settingsDataRestoreConfirmDate.
  ///
  /// In en, this message translates to:
  /// **'Backup date: {date}'**
  String settingsDataRestoreConfirmDate(String date);

  /// No description provided for @settingsDataRestoreConfirmCount.
  ///
  /// In en, this message translates to:
  /// **'Items in backup: {count}'**
  String settingsDataRestoreConfirmCount(int count);

  /// No description provided for @settingsDataRestoreConfirmWarning.
  ///
  /// In en, this message translates to:
  /// **'This will replace your current data. This cannot be undone.'**
  String get settingsDataRestoreConfirmWarning;

  /// No description provided for @settingsDataICloudNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'iCloud is not available. Please sign in to iCloud in System Settings.'**
  String get settingsDataICloudNotAvailable;

  /// No description provided for @settingsDataRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored.'**
  String get settingsDataRestoreSuccess;

  /// No description provided for @settingsDataRestoreFormatError.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file. Please use a backup created by Tsukaikiri.'**
  String get settingsDataRestoreFormatError;

  /// No description provided for @settingsDataRestoreNewerVersionError.
  ///
  /// In en, this message translates to:
  /// **'This backup was created by a newer version of Tsukaikiri. Please update the app first.'**
  String get settingsDataRestoreNewerVersionError;

  /// No description provided for @settingsDataNoBackupFound.
  ///
  /// In en, this message translates to:
  /// **'No backup was found in iCloud.'**
  String get settingsDataNoBackupFound;

  /// No description provided for @settingsDataSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {detail}'**
  String settingsDataSyncFailed(String detail);

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

  /// No description provided for @mealsFocusBanner.
  ///
  /// In en, this message translates to:
  /// **'Suggesting from \"{name}\"'**
  String mealsFocusBanner(String name);

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

  /// No description provided for @mealsErrorOnDevice.
  ///
  /// In en, this message translates to:
  /// **'The AI couldn\'t generate a response. The model may be warming up, or there may be too many items. Try with fewer items, or wait a moment and retry.'**
  String get mealsErrorOnDevice;

  /// No description provided for @cameraVisionUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t register from photos on this device'**
  String get cameraVisionUnavailableTitle;

  /// No description provided for @cameraVisionUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'On-device AI can\'t read photos. Add a vision-capable cloud AI key in Settings → AI, or add items by hand.'**
  String get cameraVisionUnavailableBody;

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

  /// No description provided for @mealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal ideas'**
  String get mealsTitle;

  /// No description provided for @mealsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll plan use-it-up meals from what you have.'**
  String get mealsSubtitle;

  /// No description provided for @mealsConditionsPrompt.
  ///
  /// In en, this message translates to:
  /// **'What kind of meal?'**
  String get mealsConditionsPrompt;

  /// No description provided for @mealsGeneratingTitle.
  ///
  /// In en, this message translates to:
  /// **'Planning your meals'**
  String get mealsGeneratingTitle;

  /// No description provided for @mealsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mealsCancel;

  /// No description provided for @mealsResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ideas from your inventory'**
  String mealsResultCount(int count);

  /// No description provided for @mealsResultBanner.
  ///
  /// In en, this message translates to:
  /// **'Picked recipes that use up ingredients expiring soon.'**
  String get mealsResultBanner;

  /// No description provided for @mealsToShoppingCount.
  ///
  /// In en, this message translates to:
  /// **'Add to shopping list ({count})'**
  String mealsToShoppingCount(int count);

  /// No description provided for @mealsShortageCount.
  ///
  /// In en, this message translates to:
  /// **'Buy {count}'**
  String mealsShortageCount(int count);

  /// No description provided for @mealsIngInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get mealsIngInStock;

  /// No description provided for @mealsIngToBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get mealsIngToBuy;

  /// No description provided for @mealsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get suggestions'**
  String get mealsErrorTitle;

  /// No description provided for @mealsErrorNoApiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'No API key registered'**
  String get mealsErrorNoApiKeyTitle;

  /// No description provided for @mealsBackToInventory.
  ///
  /// In en, this message translates to:
  /// **'Back to inventory'**
  String get mealsBackToInventory;

  /// No description provided for @shoppingMissingCount.
  ///
  /// In en, this message translates to:
  /// **'Missing items ({n})'**
  String shoppingMissingCount(int n);

  /// No description provided for @shoppingSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get shoppingSelectAll;

  /// No description provided for @shoppingDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get shoppingDeselectAll;

  /// No description provided for @shoppingForLabel.
  ///
  /// In en, this message translates to:
  /// **'for {meal}'**
  String shoppingForLabel(String meal);

  /// No description provided for @shoppingRightPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Destination list'**
  String get shoppingRightPanelTitle;

  /// No description provided for @shoppingAppLabel.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get shoppingAppLabel;

  /// No description provided for @shoppingRemindersApp.
  ///
  /// In en, this message translates to:
  /// **'Reminders (macOS)'**
  String get shoppingRemindersApp;

  /// No description provided for @shoppingLoadLists.
  ///
  /// In en, this message translates to:
  /// **'Load lists'**
  String get shoppingLoadLists;

  /// No description provided for @shoppingLoadingLists.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get shoppingLoadingLists;

  /// No description provided for @shoppingNewListName.
  ///
  /// In en, this message translates to:
  /// **'New list name'**
  String get shoppingNewListName;

  /// No description provided for @shoppingCreateList.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get shoppingCreateList;

  /// No description provided for @shoppingAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add to \"{list}\" ({n} items)'**
  String shoppingAddButton(String list, int n);

  /// No description provided for @shoppingAddButtonNoList.
  ///
  /// In en, this message translates to:
  /// **'Select a list first'**
  String get shoppingAddButtonNoList;

  /// No description provided for @shoppingDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'{n} items added'**
  String shoppingDoneTitle(int n);

  /// No description provided for @shoppingDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Find them in Reminders: \"{list}\"'**
  String shoppingDoneBody(String list);

  /// No description provided for @shoppingOpenReminders.
  ///
  /// In en, this message translates to:
  /// **'Open Reminders'**
  String get shoppingOpenReminders;

  /// No description provided for @shoppingBackToInventory.
  ///
  /// In en, this message translates to:
  /// **'Back to inventory'**
  String get shoppingBackToInventory;

  /// No description provided for @shoppingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No missing ingredients'**
  String get shoppingEmptyTitle;

  /// No description provided for @shoppingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Decide on meals to see what you need to buy.'**
  String get shoppingEmptyBody;

  /// No description provided for @shoppingGoToMeals.
  ///
  /// In en, this message translates to:
  /// **'Go to meal planner'**
  String get shoppingGoToMeals;

  /// No description provided for @shoppingErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not add to list'**
  String get shoppingErrorTitle;

  /// No description provided for @shoppingErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Please move to an area with good signal or connect to Wi-Fi. Also check that Reminders access is allowed.'**
  String get shoppingErrorNetwork;

  /// No description provided for @shoppingRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get shoppingRetry;

  /// No description provided for @shoppingListLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load lists. Check that Reminders access is allowed.'**
  String get shoppingListLoadError;

  /// No description provided for @shoppingQtyUnit.
  ///
  /// In en, this message translates to:
  /// **'{qty} pcs'**
  String shoppingQtyUnit(int qty);

  /// No description provided for @shoppingMobileTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingMobileTitle;

  /// No description provided for @shoppingMobileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients missing for your meals'**
  String get shoppingMobileSubtitle;

  /// No description provided for @shoppingMobileSummary.
  ///
  /// In en, this message translates to:
  /// **'{total} missing · adding {chosen}'**
  String shoppingMobileSummary(int total, int chosen);

  /// No description provided for @shoppingDest.
  ///
  /// In en, this message translates to:
  /// **'Add to'**
  String get shoppingDest;

  /// No description provided for @shoppingChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get shoppingChange;

  /// No description provided for @shoppingAdding.
  ///
  /// In en, this message translates to:
  /// **'Adding to Reminders…'**
  String get shoppingAdding;

  /// No description provided for @shoppingAddingDetail.
  ///
  /// In en, this message translates to:
  /// **'Sending {count} items to \"{list}\"'**
  String shoppingAddingDetail(String list, int count);

  /// No description provided for @shoppingErrorRetainNotice.
  ///
  /// In en, this message translates to:
  /// **'Your selection has been kept'**
  String get shoppingErrorRetainNotice;

  /// No description provided for @shoppingTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get shoppingTryAgain;

  /// No description provided for @shoppingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get shoppingBack;

  /// No description provided for @cameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Registration'**
  String get cameraTitle;

  /// No description provided for @cameraDropZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop photos, or click to select'**
  String get cameraDropZoneTitle;

  /// No description provided for @cameraDropZoneBody.
  ///
  /// In en, this message translates to:
  /// **'Add up to 10 photos of your fridge'**
  String get cameraDropZoneBody;

  /// No description provided for @cameraAnalyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze {n} photo(s) ⌘R'**
  String cameraAnalyzeButton(int n);

  /// No description provided for @cameraMaxPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 10 photos. Extra photos were skipped.'**
  String get cameraMaxPhotosHint;

  /// No description provided for @cameraAnalyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing your photos…'**
  String get cameraAnalyzingTitle;

  /// No description provided for @cameraAnalyzingBody.
  ///
  /// In en, this message translates to:
  /// **'Recognizing ingredients. Please wait a moment.'**
  String get cameraAnalyzingBody;

  /// No description provided for @cameraReviewHeader.
  ///
  /// In en, this message translates to:
  /// **'Detected ingredients ({n} items)'**
  String cameraReviewHeader(int n);

  /// No description provided for @cameraConfHighLabel.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get cameraConfHighLabel;

  /// No description provided for @cameraConfMidLabel.
  ///
  /// In en, this message translates to:
  /// **'Mid'**
  String get cameraConfMidLabel;

  /// No description provided for @cameraConfLowLabel.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get cameraConfLowLabel;

  /// No description provided for @cameraConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Add selected ({n} items)'**
  String cameraConfirmButton(int n);

  /// No description provided for @cameraEditNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get cameraEditNameLabel;

  /// No description provided for @cameraEditQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get cameraEditQtyLabel;

  /// No description provided for @cameraEditUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get cameraEditUnitLabel;

  /// No description provided for @cameraEditCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get cameraEditCategoryLabel;

  /// No description provided for @cameraErrorNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not analyze photos'**
  String get cameraErrorNetworkTitle;

  /// No description provided for @cameraErrorNetworkBody.
  ///
  /// In en, this message translates to:
  /// **'Please move to an area with better signal or connect to Wi-Fi.'**
  String get cameraErrorNetworkBody;

  /// No description provided for @cameraErrorNoApiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'No API key registered'**
  String get cameraErrorNoApiKeyTitle;

  /// No description provided for @cameraErrorNoApiKeyBody.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings and add an API key to enable AI recognition.'**
  String get cameraErrorNoApiKeyBody;

  /// No description provided for @cameraErrorNoVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'This provider does not support image recognition'**
  String get cameraErrorNoVisionTitle;

  /// No description provided for @cameraErrorNoVisionBody.
  ///
  /// In en, this message translates to:
  /// **'Switch to a provider with image recognition in Settings.'**
  String get cameraErrorNoVisionBody;

  /// No description provided for @cameraErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get cameraErrorRetry;

  /// No description provided for @cameraErrorOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get cameraErrorOpenSettings;

  /// No description provided for @cameraAddedToast.
  ///
  /// In en, this message translates to:
  /// **'Added {n} items to inventory'**
  String cameraAddedToast(int n);

  /// No description provided for @cameraMobileCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Photograph your fridge'**
  String get cameraMobileCaptureTitle;

  /// No description provided for @cameraMobileAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get cameraMobileAddPhotos;

  /// No description provided for @cameraMobilePhotoCount.
  ///
  /// In en, this message translates to:
  /// **'{n} / 10'**
  String cameraMobilePhotoCount(int n);

  /// No description provided for @cameraMobileAnalyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze {n} photo(s)'**
  String cameraMobileAnalyzeButton(int n);

  /// No description provided for @cameraMobileReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Detected ingredients'**
  String get cameraMobileReviewTitle;

  /// No description provided for @cameraMobileReviewSummary.
  ///
  /// In en, this message translates to:
  /// **'{total} candidates · {chosen} selected'**
  String cameraMobileReviewSummary(int total, int chosen);

  /// No description provided for @cameraMobileReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Select the items to keep and adjust the name, quantity, or category as needed'**
  String get cameraMobileReviewHint;

  /// No description provided for @cameraMobileReviewFootnote.
  ///
  /// In en, this message translates to:
  /// **'These candidates were read automatically by AI. You can review them before adding.'**
  String get cameraMobileReviewFootnote;

  /// No description provided for @cameraMobileErrorLater.
  ///
  /// In en, this message translates to:
  /// **'Analyze later'**
  String get cameraMobileErrorLater;

  /// No description provided for @onboardingRailTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup Assistant'**
  String get onboardingRailTitle;

  /// No description provided for @onboardingStep0.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingStep0;

  /// No description provided for @onboardingStep1.
  ///
  /// In en, this message translates to:
  /// **'Choose AI'**
  String get onboardingStep1;

  /// No description provided for @onboardingStep2.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get onboardingStep2;

  /// No description provided for @onboardingStep3.
  ///
  /// In en, this message translates to:
  /// **'Pick a List'**
  String get onboardingStep3;

  /// No description provided for @onboardingStep4.
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get onboardingStep4;

  /// No description provided for @onboardingStep5.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onboardingStep5;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tsukaikiri'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSub.
  ///
  /// In en, this message translates to:
  /// **'Register the ingredients in your fridge and get use-it-up meal suggestions.\nLet\'s start with a quick setup.'**
  String get onboardingWelcomeSub;

  /// No description provided for @onboardingWelcomeFeature1Title.
  ///
  /// In en, this message translates to:
  /// **'Snap to register'**
  String get onboardingWelcomeFeature1Title;

  /// No description provided for @onboardingWelcomeFeature1Body.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients in bulk with your camera'**
  String get onboardingWelcomeFeature1Body;

  /// No description provided for @onboardingWelcomeFeature2Title.
  ///
  /// In en, this message translates to:
  /// **'Use-it-up meals'**
  String get onboardingWelcomeFeature2Title;

  /// No description provided for @onboardingWelcomeFeature2Body.
  ///
  /// In en, this message translates to:
  /// **'Prioritizes ingredients expiring soonest'**
  String get onboardingWelcomeFeature2Body;

  /// No description provided for @onboardingWelcomeFeature3Title.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get onboardingWelcomeFeature3Title;

  /// No description provided for @onboardingWelcomeFeature3Body.
  ///
  /// In en, this message translates to:
  /// **'Auto-adds missing items to Reminders'**
  String get onboardingWelcomeFeature3Body;

  /// No description provided for @onboardingWelcomeStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingWelcomeStart;

  /// No description provided for @onboardingAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI is ready to use'**
  String get onboardingAiTitle;

  /// No description provided for @onboardingAiSub.
  ///
  /// In en, this message translates to:
  /// **'The AI runs on your device, so no API key is needed.'**
  String get onboardingAiSub;

  /// No description provided for @onboardingAiOnDeviceReady.
  ///
  /// In en, this message translates to:
  /// **'{name} runs on your device — free, no API key, offline. Nothing leaves your device.'**
  String onboardingAiOnDeviceReady(String name);

  /// No description provided for @onboardingAiOnDeviceMissing.
  ///
  /// In en, this message translates to:
  /// **'On-device AI isn\'t available on this device. You can add your own API key later in Settings → AI to use cloud AI.'**
  String get onboardingAiOnDeviceMissing;

  /// No description provided for @onboardingAiSkip.
  ///
  /// In en, this message translates to:
  /// **'Set up later'**
  String get onboardingAiSkip;

  /// No description provided for @onboardingAiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get onboardingAiKeyLabel;

  /// No description provided for @onboardingAiGetKeyLink.
  ///
  /// In en, this message translates to:
  /// **'Get {provider} API key'**
  String onboardingAiGetKeyLink(String provider);

  /// No description provided for @onboardingAiSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get onboardingAiSelected;

  /// No description provided for @onboardingLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Reminders'**
  String get onboardingLinkTitle;

  /// No description provided for @onboardingLinkSub.
  ///
  /// In en, this message translates to:
  /// **'Missing ingredients will be automatically added to macOS Reminders.'**
  String get onboardingLinkSub;

  /// No description provided for @onboardingLinkSkip.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get onboardingLinkSkip;

  /// No description provided for @onboardingLinkApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get onboardingLinkApp;

  /// No description provided for @onboardingLinkAppValue.
  ///
  /// In en, this message translates to:
  /// **'Reminders (macOS)'**
  String get onboardingLinkAppValue;

  /// No description provided for @onboardingLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Can do'**
  String get onboardingLinkAction;

  /// No description provided for @onboardingLinkActionValue.
  ///
  /// In en, this message translates to:
  /// **'Add items to a shopping list'**
  String get onboardingLinkActionValue;

  /// No description provided for @onboardingLinkPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get onboardingLinkPrivacy;

  /// No description provided for @onboardingLinkPrivacyValue.
  ///
  /// In en, this message translates to:
  /// **'Photos are processed on this Mac only'**
  String get onboardingLinkPrivacyValue;

  /// No description provided for @onboardingLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Allow Access to Reminders'**
  String get onboardingLinkButton;

  /// No description provided for @onboardingLinkDone.
  ///
  /// In en, this message translates to:
  /// **'Connected to Reminders'**
  String get onboardingLinkDone;

  /// No description provided for @onboardingLinkError.
  ///
  /// In en, this message translates to:
  /// **'Could not access Reminders. You can set this up later in Settings.'**
  String get onboardingLinkError;

  /// No description provided for @onboardingListTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a Destination List'**
  String get onboardingListTitle;

  /// No description provided for @onboardingListSub.
  ///
  /// In en, this message translates to:
  /// **'Select the Reminders list where shopping items will be added.'**
  String get onboardingListSub;

  /// No description provided for @onboardingListSkip.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get onboardingListSkip;

  /// No description provided for @onboardingListNewName.
  ///
  /// In en, this message translates to:
  /// **'New list name…'**
  String get onboardingListNewName;

  /// No description provided for @onboardingListCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get onboardingListCreate;

  /// No description provided for @onboardingListLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get onboardingListLoading;

  /// No description provided for @onboardingApplianceTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Appliances'**
  String get onboardingApplianceTitle;

  /// No description provided for @onboardingApplianceSub.
  ///
  /// In en, this message translates to:
  /// **'Select the appliances you own for customized recipes.'**
  String get onboardingApplianceSub;

  /// No description provided for @onboardingApplianceSkip.
  ///
  /// In en, this message translates to:
  /// **'I don\'t own any'**
  String get onboardingApplianceSkip;

  /// No description provided for @onboardingApplianceSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get onboardingApplianceSeries;

  /// No description provided for @onboardingFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'All set!'**
  String get onboardingFinishTitle;

  /// No description provided for @onboardingFinishSub.
  ///
  /// In en, this message translates to:
  /// **'Register your fridge ingredients and start getting use-it-up meal suggestions.'**
  String get onboardingFinishSub;

  /// No description provided for @onboardingFinishAiLabel.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get onboardingFinishAiLabel;

  /// No description provided for @onboardingFinishListLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminders list'**
  String get onboardingFinishListLabel;

  /// No description provided for @onboardingFinishApplianceLabel.
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get onboardingFinishApplianceLabel;

  /// No description provided for @onboardingFinishNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get onboardingFinishNotSet;

  /// No description provided for @onboardingFinishSettingsNote.
  ///
  /// In en, this message translates to:
  /// **'You can change these settings anytime in the Settings screen.'**
  String get onboardingFinishSettingsNote;

  /// No description provided for @onboardingFinishStart.
  ///
  /// In en, this message translates to:
  /// **'Register ingredients and start'**
  String get onboardingFinishStart;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help / About'**
  String get helpTitle;

  /// No description provided for @helpAppTagline.
  ///
  /// In en, this message translates to:
  /// **'An app to help you use up fridge ingredients by suggesting use-it-up meals.'**
  String get helpAppTagline;

  /// No description provided for @helpGuideEyebrow.
  ///
  /// In en, this message translates to:
  /// **'GUIDE'**
  String get helpGuideEyebrow;

  /// No description provided for @helpGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get helpGuideTitle;

  /// No description provided for @helpStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Register ingredients'**
  String get helpStep1Title;

  /// No description provided for @helpStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your fridge and AI will recognize ingredients to add to your inventory. You can also add them manually.'**
  String get helpStep1Body;

  /// No description provided for @helpStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Check inventory and expiry'**
  String get helpStep2Title;

  /// No description provided for @helpStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Ingredients are sorted by expiry date. Those expiring soon are shown in orange; overdue ones in red.'**
  String get helpStep2Body;

  /// No description provided for @helpStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Get meal suggestions'**
  String get helpStep3Title;

  /// No description provided for @helpStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Get use-it-up meal ideas from your current inventory. Recipes tailored to your appliances are included.'**
  String get helpStep3Body;

  /// No description provided for @helpStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Add missing items to shopping list'**
  String get helpStep4Title;

  /// No description provided for @helpStep4Body.
  ///
  /// In en, this message translates to:
  /// **'Ingredients you need for your chosen meals are added in bulk to your Reminders shopping list.'**
  String get helpStep4Body;

  /// No description provided for @helpAiEyebrow.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get helpAiEyebrow;

  /// No description provided for @helpAiTitle.
  ///
  /// In en, this message translates to:
  /// **'About AI'**
  String get helpAiTitle;

  /// No description provided for @helpAiBody1.
  ///
  /// In en, this message translates to:
  /// **'Tsukaikiri uses AI for meal suggestions and ingredient recognition. On supported devices the AI runs on your device (on-device): free, no API key, and works offline.'**
  String get helpAiBody1;

  /// No description provided for @helpAiBody2.
  ///
  /// In en, this message translates to:
  /// **'If you\'d like smarter suggestions, you can register your own API key (Gemini, OpenAI, Claude, etc.) in Settings → AI to switch to a higher-end cloud model.'**
  String get helpAiBody2;

  /// No description provided for @helpAiCalloutTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get helpAiCalloutTitle;

  /// No description provided for @helpAiCalloutBody.
  ///
  /// In en, this message translates to:
  /// **'When using on-device AI, your photos and inventory are processed on your device and are not sent anywhere.'**
  String get helpAiCalloutBody;

  /// No description provided for @helpDataEyebrow.
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get helpDataEyebrow;

  /// No description provided for @helpDataTitle.
  ///
  /// In en, this message translates to:
  /// **'About Expiry Data'**
  String get helpDataTitle;

  /// No description provided for @helpDataP1.
  ///
  /// In en, this message translates to:
  /// **'The expiry guidelines in this app are based on the FoodKeeper dataset published by the USDA Food Safety and Inspection Service (FSIS). FoodKeeper is an official dataset summarizing recommended storage periods for various foods.'**
  String get helpDataP1;

  /// No description provided for @helpDataP2.
  ///
  /// In en, this message translates to:
  /// **'Foods not covered by FoodKeeper — such as Japanese-specific ingredients — are supplemented with independently researched storage guidelines.'**
  String get helpDataP2;

  /// No description provided for @helpDataCalloutTitle.
  ///
  /// In en, this message translates to:
  /// **'Dates shown are estimates only'**
  String get helpDataCalloutTitle;

  /// No description provided for @helpDataCalloutBody.
  ///
  /// In en, this message translates to:
  /// **'Actual shelf life varies depending on storage conditions, whether the package has been opened, and the season. Always check the condition of food yourself.'**
  String get helpDataCalloutBody;

  /// No description provided for @helpSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources & References'**
  String get helpSourceTitle;

  /// No description provided for @helpSourceFoodkeeperTitle.
  ///
  /// In en, this message translates to:
  /// **'FoodKeeper'**
  String get helpSourceFoodkeeperTitle;

  /// No description provided for @helpSourceFoodkeeperDesc.
  ///
  /// In en, this message translates to:
  /// **'USDA / FSIS food storage guidelines'**
  String get helpSourceFoodkeeperDesc;

  /// No description provided for @helpSourceDatagovTitle.
  ///
  /// In en, this message translates to:
  /// **'Data.gov (FoodKeeper Data)'**
  String get helpSourceDatagovTitle;

  /// No description provided for @helpSourceDatagovDesc.
  ///
  /// In en, this message translates to:
  /// **'US Government open data catalog'**
  String get helpSourceDatagovDesc;

  /// No description provided for @helpEditCalloutTitle.
  ///
  /// In en, this message translates to:
  /// **'You can edit expiry dates anytime'**
  String get helpEditCalloutTitle;

  /// No description provided for @helpEditCalloutBody.
  ///
  /// In en, this message translates to:
  /// **'Open the detail view for any ingredient to update its expiry date. Override with the date on the package or your own judgment.'**
  String get helpEditCalloutBody;

  /// No description provided for @helpLegalTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal & Privacy'**
  String get helpLegalTitle;

  /// No description provided for @helpLegalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get helpLegalTerms;

  /// No description provided for @helpLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get helpLegalPrivacy;

  /// No description provided for @helpLegalFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ & Support'**
  String get helpLegalFaq;

  /// No description provided for @helpFooter.
  ///
  /// In en, this message translates to:
  /// **'FoodKeeper data © USDA / FSIS (Public Domain)\n© 2026 Tsukaikiri'**
  String get helpFooter;
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
      <String>['en', 'es', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
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
