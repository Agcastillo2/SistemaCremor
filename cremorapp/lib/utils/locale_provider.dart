import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('es');
  static const String localePrefsKey = 'app_locale';

  Locale get locale => _locale;

  LocaleProvider() {
    _loadFromPrefs();
  }

  void _loadFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString(localePrefsKey) ?? 'es';
    if (_locale.languageCode != languageCode) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(localePrefsKey, _locale.languageCode);
  }

  void setLocale(Locale locale) {
    if (_locale.languageCode != locale.languageCode) {
      _locale = locale;
      _saveToPrefs();
      notifyListeners();
    }
  }
}
