import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/app_drawer.dart';

class RoleBasedMenu {
  static List<DrawerItem> getMenuItems(UserModel user) {
    final List<DrawerItem> items = [];
    final String rol = user.rol.toLowerCase();

    // Dashboard para jefes
    if (rol.contains('jefe')) {
      items.add(
        DrawerItem(
          titleKey: 'dashboard',
          icon: Icons.dashboard,
          route: rol.contains('nata') ? '/jefe-nata' : '/jefe-helados',
        ),
      );
    }

    // Dashboard para trabajadores
    if (rol.contains('trabajador')) {
      items.add(
        DrawerItem(
          titleKey: 'dashboard',
          icon: Icons.dashboard,
          route:
              rol.contains('nata') ? '/trabajador-nata' : '/trabajador-helados',
        ),
      );
    }

    // Mi Perfil para todos los roles
    items.add(
      DrawerItem(titleKey: 'profile', icon: Icons.person, route: '/profile'),
    );

    // Procesos específicos por rol
    if (rol.contains('trabajador')) {
      items.add(
        DrawerItem(
          titleKey: 'procesos',
          icon: Icons.work,
          route: rol.contains('nata') ? '/procesos-nata' : '/procesos-helados',
        ),
      );

      // Registro de entrada/salida para trabajadores
      items.add(
        DrawerItem(
          titleKey: 'registro_entrada',
          icon: Icons.login,
          route:
              rol.contains('nata')
                  ? '/registro-entrada-nata'
                  : '/registro-entrada',
        ),
      );
      items.add(
        DrawerItem(
          titleKey: 'registro_salida',
          icon: Icons.logout,
          route:
              rol.contains('nata')
                  ? '/registro-salida-nata'
                  : '/registro-salida',
        ),
      );
    }

    // Opciones de supervisor
    if (rol.contains('supervisor')) {
      items.add(
        DrawerItem(
          titleKey: 'supervision',
          icon: Icons.supervisor_account,
          route: '/supervision',
        ),
      );
      items.add(
        DrawerItem(
          titleKey: 'reportes',
          icon: Icons.assessment,
          route: '/reportes',
        ),
      );
      items.add(
        DrawerItem(
          titleKey: 'registro_supervisor',
          icon: Icons.how_to_reg,
          route: '/registro-supervisor',
        ),
      );
    }

    // Gestión de personal para jefes
    if (rol.contains('jefe')) {
      items.add(
        DrawerItem(
          titleKey: 'personal',
          icon: Icons.people,
          route: rol.contains('nata') ? '/personal-nata' : '/personal-helados',
        ),
      );
      items.add(
        DrawerItem(
          titleKey: 'horarios',
          icon: Icons.schedule,
          route: '/horarios',
        ),
      );
      items.add(
        DrawerItem(
          titleKey: 'register',
          icon: Icons.person_add,
          route: '/register',
        ),
      );
    }

    // Logout siempre al final
    items.add(
      DrawerItem(titleKey: 'logout', icon: Icons.exit_to_app, route: '/login'),
    );

    return items;
  }
}
