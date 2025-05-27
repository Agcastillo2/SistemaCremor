import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_settings_controller.dart';
import '../utils/ui_helpers.dart';
import '../utils/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool mini;

  const ThemeToggleButton({Key? key, this.mini = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final t = AppLocalizations.of(context)!;

    return IconButton(
      icon: UIHelpers.getThemeIcon(isDark),
      tooltip: isDark ? t.lightMode : t.darkMode,
      padding: const EdgeInsets.all(8),
      constraints:
          mini ? const BoxConstraints(minWidth: 36, minHeight: 36) : null,
      onPressed: () => AppSettingsController.toggleTheme(context, !isDark),
    );
  }
}
