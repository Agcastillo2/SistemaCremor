import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../views/registro_entrada_screen.dart';
import '../views/registro_salida_screen.dart';
import '../views/registro_entrada_nata_screen.dart';
import '../views/registro_salida_nata_screen.dart';
import '../widgets/app_drawer.dart';
import 'icons.dart';

List<DrawerItem> getRegisterDrawerItems(
  BuildContext context,
  UserModel currentUser,
) {
  final isNataRole = currentUser.rol.contains('Nata');

  return [
    DrawerItem(
      titleKey: 'registro_entrada',
      icon: Icons.login,
      route: '',
      iconColor: Colors.green,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    isNataRole
                        ? RegistroEntradaNataScreen(
                          idPersona: currentUser.idPersona,
                          nombres: currentUser.nombres,
                          apellidos: currentUser.apellidos,
                          rol: currentUser.rol,
                          idRol: currentUser.idRol,
                        )
                        : RegistroEntradaScreen(
                          idPersona: currentUser.idPersona,
                          nombres: currentUser.nombres,
                          apellidos: currentUser.apellidos,
                          rol: currentUser.rol,
                          idRol: currentUser.idRol,
                        ),
          ),
        );
      },
    ),
    DrawerItem(
      titleKey: 'registro_salida',
      icon: Icons.logout,
      route: '',
      iconColor: Colors.red,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    isNataRole
                        ? RegistroSalidaNataScreen(
                          idPersona: currentUser.idPersona,
                          nombres: currentUser.nombres,
                          apellidos: currentUser.apellidos,
                          rol: currentUser.rol,
                        )
                        : RegistroSalidaScreen(
                          idPersona: currentUser.idPersona,
                          nombres: currentUser.nombres,
                          apellidos: currentUser.apellidos,
                          rol: currentUser.rol,
                        ),
          ),
        );
      },
    ),
  ];
}

List<DrawerItem> insertRegisterItems(
  List<DrawerItem> baseItems,
  BuildContext context,
  UserModel currentUser,
) {
  // Crear una copia de la lista base
  final items = List<DrawerItem>.from(baseItems);

  // Encontrar el índice después de "Mi Perfil"
  final profileIndex = items.indexWhere((item) => item.titleKey == 'profile');
  if (profileIndex == -1) return items;

  // Insertar los items de registro después de "Mi Perfil"
  items.insertAll(
    profileIndex + 1,
    getRegisterDrawerItems(context, currentUser),
  );

  return items;
}
