import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../controllers/current_user_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bar_with_settings.dart';
import '../widgets/info_card.dart';
import '../widgets/list_card.dart';
import '../widgets/custom_fab.dart';
import '../utils/ui_helpers.dart';

class JefeNataView extends StatelessWidget {
  const JefeNataView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = CurrentUserController.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final t = AppLocalizations.of(context)!; // Obtener las traducciones

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
        route: '/jefe-nata',
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

    // Usamos isDark en la construcción de la UI
    return Scaffold(
      appBar: AppBarWithSettings(
        title: 'Panel Jefe de Nata', // Título por defecto
        titleKey: 'Jefe de Nata', // Clave para traducción
        elevation: 4,
      ),
      drawer: AppDrawer(currentRoute: '/jefe-nata', items: drawerItems),
      floatingActionButton: SpeedDialFAB(
        backgroundColor: theme.colorScheme.primary,
        mainIcon: Icons.add,
        tooltip: t.settings,
        actions: [
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
          SpeedDialItem(
            icon: AppIcons.milk,
            label: 'Registro de Producción',
            backgroundColor: Colors.blue,
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header y saludo
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

            // Tarjetas con métricas
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

            // Lista de actividad reciente
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

            // Accesos rápidos
            const Text(
              'Accesos Rápidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            UIHelpers.vSpaceMedium,
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  'Registro de Procesos',
                  AppIcons.assignments,
                  () {},
                ),
                _buildFeatureCard(
                  context,
                  'Asignaciones',
                  AppIcons.calendar,
                  () {},
                ),
                _buildFeatureCard(context, 'Inventario', AppIcons.milk, () {}),
                _buildFeatureCard(
                  context,
                  'Reportes',
                  Icons.bar_chart_rounded,
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIHelpers.borderRadiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIHelpers.borderRadiusLarge),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIHelpers.borderRadiusLarge),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDark
                      ? [Colors.grey[800]!, Colors.grey[700]!]
                      : [
                        theme.colorScheme.primary.withOpacity(0.7),
                        theme.colorScheme.primary,
                      ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              UIHelpers.vSpaceMedium,
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
