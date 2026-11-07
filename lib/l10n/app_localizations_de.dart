// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Comprimage';

  @override
  String get emptyTitle => 'Fotos kleiner machen';

  @override
  String get emptyBody =>
      'Wähle Fotos aus deiner Galerie und verkleinere sie ohne sichtbaren Qualitätsverlust. Spare Speicherplatz, behalte Erinnerungen.';

  @override
  String get pickPhotos => 'Fotos auswählen';

  @override
  String get permissionTitle => 'Zugriff auf deine Fotos nötig';

  @override
  String get permissionBody =>
      'Comprimage braucht Zugriff auf deine Fotos, um sie anzuzeigen und zu komprimieren. Alles bleibt auf deinem Gerät.';

  @override
  String get grantAccess => 'Zugriff erlauben';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get limitedBanner =>
      'Du hast nur Zugriff auf ausgewählte Fotos erlaubt.';

  @override
  String get manageSelection => 'Verwalten';

  @override
  String get allPhotos => 'Alle Fotos';

  @override
  String get noPhotos => 'Keine Fotos gefunden';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos ausgewählt',
      one: '1 Foto ausgewählt',
      zero: 'Kein Foto ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get continueLabel => 'Weiter';

  @override
  String get clearSelection => 'Auswahl aufheben';

  @override
  String get selectAllLoaded => 'Alle geladenen auswählen';

  @override
  String get settingsTitle => 'Komprimierungs-Einstellungen';

  @override
  String get presets => 'Voreinstellungen';

  @override
  String get presetSmall => 'Klein';

  @override
  String get presetMedium => 'Mittel';

  @override
  String get presetHigh => 'Hoch';

  @override
  String get format => 'Ausgabeformat';

  @override
  String get quality => 'Qualität';

  @override
  String get maxEdge => 'Maximale Kantenlänge';

  @override
  String get original => 'Original';

  @override
  String pixels(int px) {
    return '$px px';
  }

  @override
  String get targetSize => 'Zielgröße pro Foto';

  @override
  String get targetSizeHelp =>
      'Optional. Die Qualität wird automatisch so angepasst, dass die Datei höchstens so groß ist.';

  @override
  String get targetSizeOff => 'Aus';

  @override
  String get targetValue => 'Größe';

  @override
  String get unitKb => 'KB';

  @override
  String get unitMb => 'MB';

  @override
  String get stripMetadata => 'Metadaten (EXIF/GPS) entfernen';

  @override
  String get stripMetadataHelp =>
      'Entfernt Standort und Kamerainfos. WebP enthält grundsätzlich keine Metadaten.';

  @override
  String get saveMode => 'Speichermodus';

  @override
  String get saveCopy => 'Als Kopie speichern';

  @override
  String get saveCopyDesc =>
      'Originale bleiben erhalten. Gespeichert in Pictures/Comprimage.';

  @override
  String get saveReplace => 'Originale ersetzen';

  @override
  String get saveReplaceDesc =>
      'Spart Speicherplatz: Originale werden nach dem Komprimieren gelöscht (Android fragt nach).';

  @override
  String startCompression(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos komprimieren',
      one: '1 Foto komprimieren',
    );
    return '$_temp0';
  }

  @override
  String get progressTitle => 'Komprimiere…';

  @override
  String progressOf(int current, int total) {
    return 'Foto $current von $total';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get cancelling => 'Aktuelles Foto wird beendet…';

  @override
  String get cancelDialogTitle => 'Komprimierung abbrechen?';

  @override
  String get cancelDialogBody => 'Bereits verarbeitete Fotos bleiben erhalten.';

  @override
  String get keepGoing => 'Weitermachen';

  @override
  String get resultsTitle => 'Ergebnis';

  @override
  String totalSaved(String size) {
    return '$size gespart';
  }

  @override
  String totalSavedDetail(String percent, String before, String after) {
    return '$percent kleiner · $before → $after';
  }

  @override
  String photosCompressed(int done, int total) {
    return '$done von $total Fotos komprimiert';
  }

  @override
  String skippedCount(int count) {
    return '$count übersprungen (nicht kleiner)';
  }

  @override
  String failedCount(int count) {
    return '$count fehlgeschlagen';
  }

  @override
  String savedPercent(String percent) {
    return '-$percent';
  }

  @override
  String get notSmaller => 'Übersprungen: Ergebnis nicht kleiner';

  @override
  String get failedItem => 'Fehlgeschlagen';

  @override
  String get originalDeleted => 'Original ersetzt';

  @override
  String get originalKept => 'Original behalten';

  @override
  String get targetNotReached => 'Zielgröße nicht erreicht';

  @override
  String get compareTitle => 'Vorher / Nachher';

  @override
  String get before => 'Vorher';

  @override
  String get after => 'Nachher';

  @override
  String get done => 'Fertig';

  @override
  String get newRun => 'Neuer Durchlauf';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get errorLoading => 'Fotos konnten nicht geladen werden';
}
