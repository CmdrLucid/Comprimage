import 'package:flutter/widgets.dart';

import '../models/formatting.dart';
import 'app_localizations.dart';

/// Convenience accessors for localisation inside widgets.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Byte formatting using the decimal separator of the active locale.
  String bytes(int value) => formatBytes(
    value,
    decimalComma: Localizations.localeOf(this).languageCode == 'de',
  );
}
