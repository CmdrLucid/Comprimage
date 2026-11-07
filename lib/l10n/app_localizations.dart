import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

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
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Comprimage'**
  String get appTitle;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Make your photos smaller'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Pick photos from your gallery and shrink them without visible quality loss. Save space, keep memories.'**
  String get emptyBody;

  /// No description provided for @pickPhotos.
  ///
  /// In en, this message translates to:
  /// **'Select photos'**
  String get pickPhotos;

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Access to your photos needed'**
  String get permissionTitle;

  /// No description provided for @permissionBody.
  ///
  /// In en, this message translates to:
  /// **'Comprimage needs access to your photos to display and compress them. Everything stays on your device.'**
  String get permissionBody;

  /// No description provided for @grantAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant access'**
  String get grantAccess;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @limitedBanner.
  ///
  /// In en, this message translates to:
  /// **'You have only granted access to selected photos.'**
  String get limitedBanner;

  /// No description provided for @manageSelection.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageSelection;

  /// No description provided for @allPhotos.
  ///
  /// In en, this message translates to:
  /// **'All photos'**
  String get allPhotos;

  /// No description provided for @noPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos found'**
  String get noPhotos;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No photo selected} =1{1 photo selected} other{{count} photos selected}}'**
  String selectedCount(int count);

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @selectAllLoaded.
  ///
  /// In en, this message translates to:
  /// **'Select all loaded'**
  String get selectAllLoaded;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Compression settings'**
  String get settingsTitle;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @presetSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get presetSmall;

  /// No description provided for @presetMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get presetMedium;

  /// No description provided for @presetHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get presetHigh;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Output format'**
  String get format;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @maxEdge.
  ///
  /// In en, this message translates to:
  /// **'Maximum edge length'**
  String get maxEdge;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @pixels.
  ///
  /// In en, this message translates to:
  /// **'{px} px'**
  String pixels(int px);

  /// No description provided for @targetSize.
  ///
  /// In en, this message translates to:
  /// **'Target size per photo'**
  String get targetSize;

  /// No description provided for @targetSizeHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. Quality is adjusted automatically to stay at or below this size.'**
  String get targetSizeHelp;

  /// No description provided for @targetSizeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get targetSizeOff;

  /// No description provided for @targetValue.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get targetValue;

  /// No description provided for @unitKb.
  ///
  /// In en, this message translates to:
  /// **'KB'**
  String get unitKb;

  /// No description provided for @unitMb.
  ///
  /// In en, this message translates to:
  /// **'MB'**
  String get unitMb;

  /// No description provided for @stripMetadata.
  ///
  /// In en, this message translates to:
  /// **'Remove metadata (EXIF/GPS)'**
  String get stripMetadata;

  /// No description provided for @stripMetadataHelp.
  ///
  /// In en, this message translates to:
  /// **'Removes location and camera info. WebP never keeps metadata.'**
  String get stripMetadataHelp;

  /// No description provided for @saveMode.
  ///
  /// In en, this message translates to:
  /// **'Save mode'**
  String get saveMode;

  /// No description provided for @saveCopy.
  ///
  /// In en, this message translates to:
  /// **'Save as copy'**
  String get saveCopy;

  /// No description provided for @saveCopyDesc.
  ///
  /// In en, this message translates to:
  /// **'Originals stay untouched. Saved in Pictures/Comprimage.'**
  String get saveCopyDesc;

  /// No description provided for @saveReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace originals'**
  String get saveReplace;

  /// No description provided for @saveReplaceDesc.
  ///
  /// In en, this message translates to:
  /// **'Saves space: originals are deleted after compression (Android asks for confirmation).'**
  String get saveReplaceDesc;

  /// No description provided for @startCompression.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Compress 1 photo} other{Compress {count} photos}}'**
  String startCompression(int count);

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Compressing…'**
  String get progressTitle;

  /// No description provided for @progressOf.
  ///
  /// In en, this message translates to:
  /// **'Photo {current} of {total}'**
  String progressOf(int current, int total);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelling.
  ///
  /// In en, this message translates to:
  /// **'Finishing current photo…'**
  String get cancelling;

  /// No description provided for @cancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel compression?'**
  String get cancelDialogTitle;

  /// No description provided for @cancelDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Photos already processed are kept.'**
  String get cancelDialogBody;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultsTitle;

  /// No description provided for @totalSaved.
  ///
  /// In en, this message translates to:
  /// **'{size} saved'**
  String totalSaved(String size);

  /// No description provided for @totalSavedDetail.
  ///
  /// In en, this message translates to:
  /// **'{percent} smaller · {before} → {after}'**
  String totalSavedDetail(String percent, String before, String after);

  /// No description provided for @photosCompressed.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} photos compressed'**
  String photosCompressed(int done, int total);

  /// No description provided for @skippedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped (not smaller)'**
  String skippedCount(int count);

  /// No description provided for @failedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} failed'**
  String failedCount(int count);

  /// No description provided for @savedPercent.
  ///
  /// In en, this message translates to:
  /// **'-{percent}'**
  String savedPercent(String percent);

  /// No description provided for @notSmaller.
  ///
  /// In en, this message translates to:
  /// **'Skipped: result not smaller'**
  String get notSmaller;

  /// No description provided for @failedItem.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failedItem;

  /// No description provided for @originalDeleted.
  ///
  /// In en, this message translates to:
  /// **'Original replaced'**
  String get originalDeleted;

  /// No description provided for @originalKept.
  ///
  /// In en, this message translates to:
  /// **'Original kept'**
  String get originalKept;

  /// No description provided for @targetNotReached.
  ///
  /// In en, this message translates to:
  /// **'Target size not reached'**
  String get targetNotReached;

  /// No description provided for @compareTitle.
  ///
  /// In en, this message translates to:
  /// **'Before / after'**
  String get compareTitle;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @newRun.
  ///
  /// In en, this message translates to:
  /// **'New run'**
  String get newRun;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Photos could not be loaded'**
  String get errorLoading;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
