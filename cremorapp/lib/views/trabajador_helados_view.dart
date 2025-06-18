import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../controllers/current_user_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bar_with_settings.dart';
import '../widgets/custom_fab.dart';
import '../utils/ui_helpers.dart' hide AppIcons;
import '../utils/icons.dart';
import '../utils/drawer_items_helper.dart';
import 'registro_entrada_screen.dart';
import 'registro_salida_screen.dart';

class TrabajadorHeladosView extends StatelessWidget {
  const TrabajadorHeladosView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = CurrentUserController.currentUser;
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const SizedBox.shrink();
    }

    final baseItems = [
      DrawerItem(
        titleKey: 'dashboard',
        icon: AppIcons.home,
        route: '/trabajador-helados',
      ),
      DrawerItem(
        titleKey: 'profile',
        icon: AppIcons.profile,
        route: '/profile',
      ),
      DrawerItem(titleKey: 'logout', icon: AppIcons.logout, route: '/login'),
    ];

    final drawerItems = insertRegisterItems(baseItems, context, currentUser);

    return Scaffold(
      appBar: AppBarWithSettings(
        title: 'Panel Trabajador de Helados',
        titleKey: 'trabajador_helados',
        elevation: 4,
      ),
      drawer: AppDrawer(
        currentRoute: '/trabajador-helados',
        items: drawerItems,
      ),
      floatingActionButton: SpeedDialFAB(
        backgroundColor: theme.colorScheme.primary,
        mainIcon: Icons.add,
        tooltip: t.settings,
        actions: [
          SpeedDialItem(
            icon: Icons.login,
            label: 'Registrar Entrada',
            backgroundColor: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RegistroEntradaScreen(
                        idPersona: currentUser.idPersona,
                        nombres: currentUser.nombres,
                        apellidos: currentUser.apellidos,
                        rol: 'Trabajador de Helados',
                        idRol: currentUser.idRol,
                      ),
                ),
              );
            },
          ),
          SpeedDialItem(
            icon: Icons.logout,
            label: 'Registrar Salida',
            backgroundColor: Colors.red,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RegistroSalidaScreen(
                        idPersona: currentUser.idPersona,
                        nombres: currentUser.nombres,
                        apellidos: currentUser.apellidos,
                        rol: 'Trabajador de Helados',
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, ${currentUser.nombres}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            UIHelpers.vSpaceMedium,
            Text(
              'Panel de Control',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.secondary,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
