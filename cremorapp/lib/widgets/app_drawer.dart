import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../controllers/current_user_controller.dart';
import '../views/profile_view.dart';
import 'settings_buttons.dart';
import '../models/user_model.dart';

class DrawerItem {
  final String titleKey;
  final IconData icon;
  final String route;
  final Color? iconColor;
  final VoidCallback? onTap;

  DrawerItem({
    required this.titleKey,
    required this.icon,
    required this.route,
    this.iconColor,
    this.onTap,
  });
}

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final List<DrawerItem> items;

  const AppDrawer({Key? key, required this.currentRoute, required this.items})
    : super(key: key);

  List<DrawerItem> _getDrawerItems(
    BuildContext context,
    UserModel? currentUser,
  ) {
    if (currentUser == null) return [];

    final isNataRole = currentUser.rol.contains('Nata');
    final baseItems = List<DrawerItem>.from(items);

    // Encontrar el índice después de "Mi Perfil"
    final profileIndex = baseItems.indexWhere(
      (item) => item.titleKey == 'profile',
    );
    if (profileIndex == -1) return baseItems;

    return baseItems;
  }

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
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              margin: EdgeInsets.zero,
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileView(),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25,
                  child: Text(
                    currentUser != null
                        ? '${currentUser.nombres[0]}${currentUser.apellidos[0]}'
                        : '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              accountName: Text(
                currentUser != null
                    ? '${currentUser.nombres} ${currentUser.apellidos}'
                    : '',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              accountEmail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CI: ${currentUser?.numeroIdentificacion ?? ''}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    currentUser?.rol ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children:
                    _getDrawerItems(context, currentUser).map((item) {
                      final bool isSelected = currentRoute == item.route;
                      return ListTile(
                        leading: Icon(
                          item.icon,
                          color: item.iconColor ?? theme.iconTheme.color,
                        ),
                        title: Text(
                          _getTitle(t, item.titleKey),
                          style: TextStyle(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodyLarge?.color,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onTap:
                            item.onTap ??
                            () {
                              Navigator.pop(context);
                              if (item.route == '/login') {
                                CurrentUserController.clearCurrentUser();
                              }
                              Navigator.pushReplacementNamed(
                                context,
                                item.route,
                              );
                            },
                      );
                    }).toList(),
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SettingsButtons(axis: Axis.horizontal),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(AppLocalizations t, String titleKey) {
    switch (titleKey) {
      case 'dashboard':
        return 'Panel Principal';
      case 'profile':
        return 'Mi Perfil';
      case 'assignments':
        return 'Asignaciones';
      case 'logout':
        return 'Cerrar Sesión';
      case 'registro_entrada':
        return 'Registrar Entrada';
      case 'registro_salida':
        return 'Registrar Salida';
      case 'register':
        return 'Registrar Usuario';
      default:
        return titleKey;
    }
  }
}
