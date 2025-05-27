import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/theme_provider.dart';
import '../utils/locale_provider.dart';

class AppSettingsController {
  // Cambiar el tema de la aplicación
  static void toggleTheme(BuildContext context, bool isDark) {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme(isDark);
  }

  // Establecer el modo del tema
  static void setThemeMode(BuildContext context, ThemeMode mode) {
    Provider.of<ThemeProvider>(context, listen: false).setThemeMode(mode);
  }

  // Obtener el modo actual del tema
  static ThemeMode getThemeMode(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: false).themeMode;
  }

  // Verificar si está en modo oscuro
  static bool isDarkMode(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
  }

  // Cambiar el idioma de la aplicación
  static void setLocale(BuildContext context, String languageCode) {
    Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).setLocale(Locale(languageCode));
  }

  // Obtener el idioma actual
  static Locale getLocale(BuildContext context) {
    return Provider.of<LocaleProvider>(context, listen: false).locale;
  }
}
