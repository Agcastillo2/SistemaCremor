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
import 'registro_entrada_nata_screen.dart';
import 'registro_salida_nata_screen.dart';

class JefeNataView extends StatelessWidget {
  const JefeNataView({super.key});

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
        route: '/jefe-nata',
      ),
      DrawerItem(
        titleKey: 'profile',
        icon: AppIcons.profile,
        route: '/profile',
      ),
      DrawerItem(
        titleKey: 'processes',
        icon: AppIcons.assignments,
        route: '/procesos',
      ),
      DrawerItem(titleKey: 'logout', icon: AppIcons.logout, route: '/login'),
    ];

    final drawerItems = insertRegisterItems(baseItems, context, currentUser);

    return Scaffold(
      appBar: const AppBarWithSettings(
        title: 'Panel Jefe de Nata',
        titleKey: 'Jefe de Nata',
        elevation: 4,
      ),
      drawer: AppDrawer(currentRoute: '/jefe-nata', items: drawerItems),
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
                      (context) => RegistroEntradaNataScreen(
                        idPersona: currentUser.idPersona,
                        nombres: currentUser.nombres,
                        apellidos: currentUser.apellidos,
                        rol: 'Jefe de Nata',
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
                      (context) => RegistroSalidaNataScreen(
                        idPersona: currentUser.idPersona,
                        nombres: currentUser.nombres,
                        apellidos: currentUser.apellidos,
                        rol: 'Jefe de Nata',
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
            UIHelpers.vSpaceLarge,

            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Producción Hoy',
                    value: '240L',
                    icon: AppIcons.milk,
                    color: Colors.blue,
                    showTrend: true,
                    trendValue: 5.2,
                    onTap: () {},
                  ),
                ),
                UIHelpers.hSpaceMedium,
                Expanded(
                  child: MetricCard(
                    title: 'Procesos',
                    value: '12',
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
                    value: '8',
                    icon: AppIcons.person,
                    color: Colors.purple,
                    showTrend: true,
                    trendValue: -1,
                    onTap: () {},
                  ),
                ),
                UIHelpers.hSpaceMedium,
                Expanded(
                  child: MetricCard(
                    title: 'Eficiencia',
                    value: '95%',
                    icon: Icons.speed_rounded,
                    color: Colors.orange,
                    showTrend: true,
                    trendValue: 2.5,
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
                  title: 'Proceso #12453',
                  subtitle: 'Completado hoy a las 10:30 AM',
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.2),
                    child: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListItem(
                  title: 'Asignación #789',
                  subtitle: 'Asignado a Juan Pérez - Pendiente',
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    child: const Icon(Icons.pending, color: Colors.orange),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListItem(
                  title: 'Inventario actualizado',
                  subtitle: 'Realizado ayer a las 17:45',
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
            UIHelpers.vSpaceLarge,
          ],
        ),
      ),
    );
  }
}
