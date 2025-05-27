import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/locale_provider.dart';
import '../utils/ui_helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectorButton extends StatelessWidget {
  final bool mini;

  const LanguageSelectorButton({Key? key, this.mini = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale;
    final t =
        AppLocalizations.of(context)!; // Verificar si estamos en modo oscuro
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<String>(
      icon: UIHelpers.getLanguageIcon(isDark),
      tooltip: t.changeLanguage,
      padding: const EdgeInsets.all(8),
      constraints:
          mini ? const BoxConstraints(minWidth: 36, minHeight: 36) : null,
      offset: const Offset(0, 40),
      itemBuilder:
          (context) => [
            PopupMenuItem<String>(
              value: 'es',
              child: _buildLanguageItem(
                context: context,
                languageCode: 'es',
                countryCode: 'ES',
                isSelected: currentLocale.languageCode == 'es',
              ),
            ),
            PopupMenuItem<String>(
              value: 'en',
              child: _buildLanguageItem(
                context: context,
                languageCode: 'en',
                countryCode: 'US',
                isSelected: currentLocale.languageCode == 'en',
              ),
            ),
          ],
      onSelected: (languageCode) {
        // Use the provider directly to ensure proper notifications
        Provider.of<LocaleProvider>(
          context,
          listen: false,
        ).setLocale(Locale(languageCode));
      },
    );
  }

  Widget _buildLanguageItem({
    required BuildContext context,
    required String languageCode,
    required String countryCode,
    required bool isSelected,
  }) {
    return Row(
      children: [
        Text(
          LocaleUtils.getFlagEmoji(countryCode),
          style: const TextStyle(fontSize: 20),
        ),
        UIHelpers.hSpaceSmall,
        Text(
          LocaleUtils.getLanguageName(context, languageCode),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const Spacer(),
        if (isSelected) const Icon(Icons.check, size: 18),
      ],
    );
  }
}
