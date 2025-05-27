import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../views/profile_view.dart';

class CustomDrawer extends StatelessWidget {
  final String nombres;
  final String apellidos;
  final String cedula;
  final String rol;
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
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
                Text(rol, style: const TextStyle(fontSize: 14)),
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
