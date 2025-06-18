import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../controllers/current_user_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bar_with_settings.dart';
import '../widgets/info_card.dart';
import '../widgets/list_card.dart';
import '../widgets/custom_fab.dart';
import '../utils/ui_helpers.dart' hide AppIcons;
import '../utils/icons.dart';
import '../utils/drawer_items_helper.dart';
import 'registro_entrada_screen.dart';
import 'registro_salida_screen.dart';

class JefeHeladosView extends StatelessWidget {
  const JefeHeladosView({super.key});

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
        route: '/jefe-helados',
      ),
      DrawerItem(
        titleKey: 'profile',
        icon: AppIcons.profile,
        route: '/profile',
      ),
      DrawerItem(
        titleKey: 'assignments',
        icon: AppIcons.assignments,
        route: '/assignments',
      ),
      DrawerItem(titleKey: 'logout', icon: AppIcons.logout, route: '/login'),
    ];

    final drawerItems = insertRegisterItems(baseItems, context, currentUser);

    return Scaffold(
      appBar: AppBarWithSettings(
        title: 'Panel Jefe de Helados',
        titleKey: 'Jefe de Helados',
        elevation: 4,
      ),
      drawer: AppDrawer(currentRoute: '/jefe-helados', items: drawerItems),
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
                        rol: 'Jefe de Helados',
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
                        rol: 'Jefe de Helados',
                      ),
                ),
              );
            },
          ),
          SpeedDialItem(
            icon: AppIcons.assignments,
            label: 'Nuevo Proceso',
            backgroundColor: Colors.green,
            onPressed: () {},
          ),
          SpeedDialItem(
            icon: AppIcons.person,
            label: 'Asignar Personal',
            backgroundColor: Colors.purple,
            onPressed: () {},
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
            UIHelpers.vSpaceLarge,

            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Producción Hoy',
                    value: '1500U',
                    icon: Icons.ice_skating,
                    color: Colors.blue,
                    showTrend: true,
                    trendValue: 3.8,
                    onTap: () {},
                  ),
                ),
                UIHelpers.hSpaceMedium,
                Expanded(
                  child: MetricCard(
                    title: 'Procesos',
                    value: '8',
                    icon: AppIcons.assignments,
                    color: Colors.green,
                    showTrend: true,
                    trendValue: 0,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            UIHelpers.vSpaceMedium,
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Personal',
                    value: '6',
                    icon: AppIcons.person,
                    color: Colors.purple,
                    showTrend: true,
                    trendValue: 0,
                    onTap: () {},
                  ),
                ),
                UIHelpers.hSpaceMedium,
                Expanded(
                  child: MetricCard(
                    title: 'Eficiencia',
                    value: '92%',
                    icon: Icons.speed_rounded,
                    color: Colors.orange,
                    showTrend: true,
                    trendValue: 1.5,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            UIHelpers.vSpaceLarge,

            ListCard(
              title: 'Actividad Reciente',
              items: [
                ListItem(
                  title: 'Lote #H789',
                  subtitle: 'Finalizado hoy a las 09:15 AM',
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.2),
                    child: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListItem(
                  title: 'Asignación #456',
                  subtitle: 'Asignado a María López - En proceso',
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    child: const Icon(Icons.pending, color: Colors.orange),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListItem(
                  title: 'Stock actualizado',
                  subtitle: 'Actualizado hoy a las 08:30',
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: const Icon(Icons.inventory_2, color: Colors.blue),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
              action: TextButton(
                onPressed: () {},
                child: const Text('Ver todos'),
              ),
              shrinkWrap: true,
            ),
          ],
        ),
      ),
    );
  }
}
