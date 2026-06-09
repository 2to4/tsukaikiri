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
  /// **'Support the developer'**
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
