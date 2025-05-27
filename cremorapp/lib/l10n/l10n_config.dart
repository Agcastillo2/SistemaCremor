import 'package:flutter/material.dart';

class L10nConfig {
  // Configuración para generar archivos de traducción
  static const supportedLocales = [
    Locale('es'), // Español (predeterminado)
    Locale('en'), // Inglés
  ];

  // Ruta donde Flutter buscará los archivos .arb
  static const localizationsDirPath = 'lib/l10n';

  // El parámetro de generación de código
  static const generateLocalizationsCode = true;
}
