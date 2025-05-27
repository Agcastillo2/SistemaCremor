import 'package:flutter/material.dart';
import 'settings_buttons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppBarWithSettings extends StatelessWidget
    implements PreferredSizeWidget {
  final String title; // Título literal
  final String? titleKey; // Clave para traducción (opcional)
  final bool automaticallyImplyLeading;
  final List<Widget>? additionalActions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final double? elevation;

  const AppBarWithSettings({
    super.key,
    required this.title,
    this.titleKey,
    this.automaticallyImplyLeading = true,
    this.additionalActions,
    this.bottom,
    this.leading,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    // Obtener el título traducido si hay una clave de traducción
    final displayTitle =
        titleKey != null ? _getTranslatedTitle(t, titleKey!) : title;

    // Combinamos el botón de configuración con cualquier acción adicional
    final List<Widget> allActions = [
      ...(additionalActions ?? []),
      const SettingsButtons(mini: true),
      const SizedBox(width: 8),
    ];

    return AppBar(
      title: Text(displayTitle),
      centerTitle: true,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      actions: allActions,
      bottom: bottom,
      elevation: elevation,
    );
  }

  // Método para obtener el texto traducido según la clave
  String _getTranslatedTitle(AppLocalizations t, String key) {
    switch (key) {
      case 'dashboard':
        return t.dashboard;
      case 'profile':
        return t.profile;
      case 'vehicles':
        return t.vehicles;
      case 'assignments':
        return t.assignments;
      case 'logout':
        return t.logout;
      case 'milk':
        return t.milk;
      case 'register':
        return t.register;
      case 'settings':
        return t.settings;
      case 'Supervisor':
        return key;
      case 'Jefe de Nata':
        return key;
      case 'iceCreamManager':
        return key;
      case 'creamWorker':
        return key;
      case 'iceCreamWorker':
        return key;
      default:
        return key;
    }
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
