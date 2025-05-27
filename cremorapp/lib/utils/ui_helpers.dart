import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppIcons {
  static const IconData home = Icons.dashboard_rounded;
  static const IconData profile = Icons.person_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData vehicles = Icons.local_shipping_rounded;
  static const IconData assignments = Icons.assignment_rounded;
  static const IconData milk = Icons.water_drop_rounded;
  static const IconData logout = Icons.logout_rounded;
  static const IconData login = Icons.login_rounded;
  static const IconData theme = Icons.brightness_6_rounded;
  static const IconData language = Icons.language_rounded;
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData email = Icons.email_rounded;
  static const IconData phone = Icons.phone_android_rounded;
  static const IconData location = Icons.location_on_rounded;
  static const IconData person = Icons.person_outline_rounded;
  static const IconData id = Icons.badge_rounded;
  static const IconData password = Icons.lock_rounded;
  static const IconData visibility = Icons.visibility_rounded;
  static const IconData visibilityOff = Icons.visibility_off_rounded;
  static const IconData family = Icons.family_restroom_rounded;
  static const IconData license = Icons.card_membership_rounded;
  static const IconData bloodType = Icons.bloodtype_rounded;
  static const IconData person_add = Icons.person_add_rounded;
  static const IconData manage_users = Icons.manage_accounts_rounded;
}

class LocaleUtils {
  static String getLanguageName(BuildContext context, String languageCode) {
    switch (languageCode) {
      case 'es':
        return AppLocalizations.of(context)!.spanish;
      case 'en':
        return AppLocalizations.of(context)!.english;
      default:
        return languageCode;
    }
  }

  static String getFlagEmoji(String countryCode) {
    // Convert country code to flag emoji (works for most country codes)
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
}

class UIHelpers {
  // Espaciado vertical
  static const Widget vSpaceTiny = SizedBox(height: 4.0);
  static const Widget vSpaceSmall = SizedBox(height: 8.0);
  static const Widget vSpaceMedium = SizedBox(height: 16.0);
  static const Widget vSpaceLarge = SizedBox(height: 24.0);
  static const Widget vSpaceXLarge = SizedBox(height: 32.0);
  static const Widget vSpaceXXLarge = SizedBox(height: 48.0);

  // Espaciado horizontal
  static const Widget hSpaceTiny = SizedBox(width: 4.0);
  static const Widget hSpaceSmall = SizedBox(width: 8.0);
  static const Widget hSpaceMedium = SizedBox(width: 16.0);
  static const Widget hSpaceLarge = SizedBox(width: 24.0);
  static const Widget hSpaceXLarge = SizedBox(width: 32.0);

  // Bordes redondeados comunes
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  static const double borderRadiusXXLarge = 32.0;

  // Sombras
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> get darkShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Decoraciones comunes
  static BoxDecoration roundedBoxDecoration({
    Color? color,
    double radius = borderRadiusMedium,
    List<BoxShadow>? shadows,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadows,
      border: border,
    );
  }

  static Icon getThemeIcon(bool isDark) =>
      isDark
          ? const Icon(AppIcons.theme, color: Colors.white)
          : const Icon(AppIcons.theme, color: Colors.black87);

  static Icon getLanguageIcon(bool isDark) =>
      isDark
          ? const Icon(AppIcons.language, color: Colors.white)
          : const Icon(AppIcons.language, color: Colors.black87);
}

// Extensiones para el contexto
extension ContextExtension on BuildContext {
  // Acceder fácilmente al tema
  ThemeData get theme => Theme.of(this);

  // Acceder fácilmente a los colores
  ColorScheme get colors => Theme.of(this).colorScheme;

  // Acceder fácilmente a las dimensiones de pantalla
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // Saber si es pantalla pequeña, mediana o grande
  bool get isSmallScreen => screenWidth < 600;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 900;
  bool get isLargeScreen => screenWidth >= 900;
}
