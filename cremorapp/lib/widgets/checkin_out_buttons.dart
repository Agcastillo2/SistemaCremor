import 'package:flutter/material.dart';
import '../controllers/current_user_controller.dart';
import '../views/registro_entrada_screen.dart';
import '../views/registro_salida_screen.dart';
import '../views/registro_entrada_nata_screen.dart';
import '../views/registro_salida_nata_screen.dart';

class CheckInOutButtons extends StatelessWidget {
  const CheckInOutButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = CurrentUserController.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    bool isNataRole = currentUser.rol.contains('Nata');

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'entrada',
              child: ListTile(
                leading: Icon(Icons.login, color: Colors.green),
                title: Text('Registrar Entrada'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'salida',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Registrar Salida'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
      onSelected: (value) {
        if (value == 'entrada') {
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
        } else if (value == 'salida') {
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
        }
      },
    );
  }
}
