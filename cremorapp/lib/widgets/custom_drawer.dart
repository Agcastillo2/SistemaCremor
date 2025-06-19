import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../views/profile_view.dart';
// Importaciones para las nuevas pantallas (se crearán después)
import '../views/registro_entrada_screen.dart';
import '../views/registro_salida_screen.dart';
// Add imports for Nata-specific registro screens
import '../views/registro_entrada_nata_screen.dart';
import '../views/registro_salida_nata_screen.dart';

class CustomDrawer extends StatelessWidget {
  final int idPersona; // Nuevo parámetro
  final String nombres;
  final String apellidos;
  final String cedula;
  final String rol;
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
    required this.idPersona, // Añadido idPersona
    required this.nombres,
    required this.apellidos,
    required this.cedula,
    required this.rol,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileView()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    nombres[0] + apellidos[0],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            accountName: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                '$nombres $apellidos',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CI: $cedula', style: const TextStyle(fontSize: 14)),
                Text(
                  rol.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(AppLocalizations.of(context)?.profile ?? 'Mi Perfil'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileView()),
              );
            },
          ),
          if (rol == 'JEFE_NATA') ...[
            ListTile(
              leading: const Icon(Icons.workspaces_outline),
              title: const Text('Procesos'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar navegación a la pantalla de Procesos
              },
            ),
          ],
          // Nueva Opción: Registro Entrada
          ListTile(
            leading: const Icon(Icons.timer_outlined), // Icono para entrada
            title: const Text('Registro Entrada'), // TODO: Localizar este texto
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          (rol.contains('NATA'))
                              ? RegistroEntradaNataScreen(
                                idPersona: idPersona,
                                nombres: nombres,
                                apellidos: apellidos,
                                rol: rol,
                                idRol:
                                    1, // TODO: Obtener el ID del rol del login
                              )
                              : RegistroEntradaScreen(
                                idPersona: idPersona,
                                nombres: nombres,
                                apellidos: apellidos,
                                rol: rol,
                                idRol:
                                    1, // TODO: Obtener el ID del rol del login
                              ),
                ),
              );
            },
          ),
          // Nueva Opción: Registro Salida
          ListTile(
            leading: const Icon(Icons.timer_off_outlined), // Icono para salida
            title: const Text('Registro Salida'), // TODO: Localizar este texto
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          (rol.contains('NATA'))
                              ? RegistroSalidaNataScreen(
                                idPersona: idPersona,
                                nombres: nombres,
                                apellidos: apellidos,
                                rol: rol,
                              )
                              : RegistroSalidaScreen(
                                idPersona: idPersona,
                                nombres: nombres,
                                apellidos: apellidos,
                                rol: rol,
                              ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(
              AppLocalizations.of(context)?.logout ?? 'Cerrar Sesión',
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
