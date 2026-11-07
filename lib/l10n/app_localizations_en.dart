// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Comprimage';

  @override
  String get emptyTitle => 'Make your photos smaller';

  @override
  String get emptyBody =>
      'Pick photos from your gallery and shrink them without visible quality loss. Save space, keep memories.';

  @override
  String get pickPhotos => 'Select photos';

  @override
  String get permissionTitle => 'Access to your photos needed';

  @override
  String get permissionBody =>
      'Comprimage needs access to your photos to display and compress them. Everything stays on your device.';

  @override
  String get grantAccess => 'Grant access';

  @override
  String get openSettings => 'Open settings';

  @override
  String get limitedBanner =>
      'You have only granted access to selected photos.';

  @override
  String get manageSelection => 'Manage';

  @override
  String get allPhotos => 'All photos';

  @override
  String get noPhotos => 'No photos found';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos selected',
      one: '1 photo selected',
      zero: 'No photo selected',
    );
    return '$_temp0';
  }

  @override
  String get continueLabel => 'Continue';

  @override
  String get clearSelection => 'Clear selection';

  @override
  String get selectAllLoaded => 'Select all loaded';

  @override
  String get settingsTitle => 'Compression settings';

  @override
  String get presets => 'Presets';

  @override
  String get presetSmall => 'Small';

  @override
  String get presetMedium => 'Medium';

  @override
  String get presetHigh => 'High';

  @override
  String get format => 'Output format';

  @override
  String get quality => 'Quality';

  @override
  String get maxEdge => 'Maximum edge length';

  @override
  String get original => 'Original';

  @override
  String pixels(int px) {
    return '$px px';
  }

  @override
  String get targetSize => 'Target size per photo';

  @override
  String get targetSizeHelp =>
      'Optional. Quality is adjusted automatically to stay at or below this size.';

  @override
  String get targetSizeOff => 'Off';

  @override
  String get targetValue => 'Size';

  @override
  String get unitKb => 'KB';

  @override
  String get unitMb => 'MB';

  @override
  String get stripMetadata => 'Remove metadata (EXIF/GPS)';

  @override
  String get stripMetadataHelp =>
      'Removes location and camera info. WebP never keeps metadata.';

  @override
  String get saveMode => 'Save mode';

  @override
  String get saveCopy => 'Save as copy';

  @override
  String get saveCopyDesc =>
      'Originals stay untouched. Saved in Pictures/Comprimage.';

  @override
  String get saveReplace => 'Replace originals';

  @override
  String get saveReplaceDesc =>
      'Saves space: originals are deleted after compression (Android asks for confirmation).';

  @override
  String startCompression(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Compress $count photos',
      one: 'Compress 1 photo',
    );
    return '$_temp0';
  }

  @override
  String get progressTitle => 'Compressing…';

  @override
  String progressOf(int current, int total) {
    return 'Photo $current of $total';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelling => 'Finishing current photo…';

  @override
  String get cancelDialogTitle => 'Cancel compression?';

  @override
  String get cancelDialogBody => 'Photos already processed are kept.';

  @override
  String get keepGoing => 'Keep going';

  @override
  String get resultsTitle => 'Result';

  @override
  String totalSaved(String size) {
    return '$size saved';
  }

  @override
  String totalSavedDetail(String percent, String before, String after) {
    return '$percent smaller · $before → $after';
  }

  @override
  String photosCompressed(int done, int total) {
    return '$done of $total photos compressed';
  }

  @override
  String skippedCount(int count) {
    return '$count skipped (not smaller)';
  }

  @override
  String failedCount(int count) {
    return '$count failed';
  }

  @override
  String savedPercent(String percent) {
    return '-$percent';
  }

  @override
  String get notSmaller => 'Skipped: result not smaller';

  @override
  String get failedItem => 'Failed';

  @override
  String get originalDeleted => 'Original replaced';

  @override
  String get originalKept => 'Original kept';

  @override
  String get targetNotReached => 'Target size not reached';

  @override
  String get compareTitle => 'Before / after';

  @override
  String get before => 'Before';

  @override
  String get after => 'After';

  @override
  String get done => 'Done';

  @override
  String get newRun => 'New run';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get errorLoading => 'Photos could not be loaded';
}
