import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/ui_helpers.dart';
import '../controllers/current_user_controller.dart';
import '../views/profile_view.dart';
import 'settings_buttons.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final List<DrawerItem> items;

  const AppDrawer({Key? key, required this.currentRoute, required this.items})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final currentUser = CurrentUserController.currentUser;

    return Drawer(
      elevation: 10,
      child: Container(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Cerrar el drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileView(),
                    ),
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child:
                      currentUser != null
                          ? Center(
                            child: Text(
                              currentUser.nombres[0] + currentUser.apellidos[0],
                              style: TextStyle(
                                fontSize: 18, // Tamaño más pequeño
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          )
                          : Icon(
                            AppIcons.person,
                            color: theme.colorScheme.primary,
                            size: 24, // Tamaño más pequeño
                          ),
                ),
              ),
              accountName:
                  currentUser != null
                      ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          currentUser.nombreCompleto,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                      : const Text(
                        'CREMOR',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              accountEmail:
                  currentUser != null
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'CI: ${currentUser.numeroIdentificacion}',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentUser.rol,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                      : Text(t.appName, style: const TextStyle(fontSize: 14)),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children:
                    items.map((item) {
                      final bool isSelected = currentRoute == item.route;

                      // Obtener el texto traducido según la clave
                      String translatedTitle = _getTranslatedTitle(
                        t,
                        item.titleKey,
                      );

                      return ListTile(
                        leading: Icon(
                          item.icon,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                        title: Text(
                          translatedTitle, // Usar el texto traducido
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                isSelected ? theme.colorScheme.primary : null,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: theme.colorScheme.primary
                            .withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            UIHelpers.borderRadiusSmall,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Cerrar el drawer
                          if (currentRoute != item.route) {
                            if (item.route == '/profile') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileView(),
                                ),
                              );
                            } else {
                              Navigator.pushReplacementNamed(
                                context,
                                item.route,
                              );
                            }
                          }
                        },
                      );
                    }).toList(),
              ),
            ),
            const Divider(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(t.settings), const SettingsButtons()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para obtener el texto traducido según la clave
  String _getTranslatedTitle(AppLocalizations t, String titleKey) {
    switch (titleKey) {
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
      default:
        return titleKey; // Si no hay traducción, usar la clave como texto
    }
  }
}

class DrawerItem {
  final String titleKey; // Clave para la traducción
  final IconData icon;
  final String route;

  const DrawerItem({
    required this.titleKey,
    required this.icon,
    required this.route,
  });
}
