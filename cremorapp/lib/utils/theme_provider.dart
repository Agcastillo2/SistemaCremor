import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  ThemeMode _themeMode = ThemeMode.system;
  static const String themePrefsKey = 'theme_mode';

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadFromPrefs();
  }

  void _loadFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeModeString = prefs.getString(themePrefsKey) ?? 'system';
    _setThemeMode(themeModeString);
    notifyListeners();
  }

  void _saveToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = 'system';

    switch (_themeMode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }

    await prefs.setString(themePrefsKey, value);
  }

  void toggleTheme(bool isOn) {
    _isDarkMode = isOn;
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _isDarkMode = (mode == ThemeMode.dark);
    _saveToPrefs();
    notifyListeners();
  }

  void _setThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        _isDarkMode = false;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        _isDarkMode = true;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
        // Determinar si está en modo oscuro basado en el sistema
        var brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        _isDarkMode = brightness == Brightness.dark;
    }
  }
}
