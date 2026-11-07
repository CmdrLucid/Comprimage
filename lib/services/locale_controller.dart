import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user-selected locale (null = follow system) and persists it.
class LocaleController extends ChangeNotifier {
  static const _key = 'locale';

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      _locale = (code == null || code.isEmpty) ? null : Locale(code);
      notifyListeners();
    } catch (_) {
      // Fall back to system locale.
    }
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, locale.languageCode);
      }
    } catch (_) {}
  }
}
