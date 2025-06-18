import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../controllers/current_user_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bar_with_settings.dart';
import '../widgets/custom_fab.dart';
import '../utils/ui_helpers.dart' hide AppIcons;
import '../utils/icons.dart';
import 'register_view.dart';
import 'password_recovery_view.dart';

class SupervisorView extends StatelessWidget {
  const SupervisorView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = CurrentUserController.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final t = AppLocalizations.of(context)!; // Obtener traducciones

    if (currentUser == null) {
      // If no user is logged in, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const SizedBox.shrink();
    }

    final drawerItems = [
      DrawerItem(
        titleKey: 'dashboard',
        icon: AppIcons.home,
        route: '/supervisor',
      ),
      DrawerItem(
        titleKey: 'profile',
        icon: AppIcons.profile,
        route: '/profile',
      ),
      DrawerItem(
        titleKey: 'register', // Para registro de usuarios
        icon: AppIcons.manage_users,
        route: '/register',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterView()),
          );
        },
      ),
      DrawerItem(titleKey: 'logout', icon: AppIcons.logout, route: '/login'),
    ];

    return Scaffold(
      appBar: const AppBarWithSettings(
        title: 'Panel Supervisor', // Título por defecto
        titleKey: 'Supervisor', // Clave para traducción
        elevation: 4,
      ),
      drawer: AppDrawer(currentRoute: '/supervisor', items: drawerItems),
      floatingActionButton: SpeedDialFAB(
        backgroundColor: theme.colorScheme.primary,
        mainIcon: Icons.add,
        tooltip: t.settings,
        actions: [
          SpeedDialItem(
            icon: AppIcons.person_add,
            label: t.register,
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterView()),
              );
            },
          ),
          SpeedDialItem(
            icon: Icons.password,
            label: t.changePassword,
            backgroundColor: Colors.orange,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PasswordRecoveryView(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDark
                    ? [Colors.grey[900]!, Colors.grey[800]!]
                    : [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  UIHelpers.borderRadiusMedium,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t.welcome}, ${currentUser.nombres}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.dashboard, // Replace with an existing key, or use a hardcoded string like 'Supervisor Panel'
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Accesos Rápidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterView(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: Text(t.register),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PasswordRecoveryView(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.password),
                  label: Text(t.changePassword),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
