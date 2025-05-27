import 'package:flutter/material.dart';
import '../controllers/current_user_controller.dart';
import '../widgets/custom_drawer.dart';

class TrabajadorHeladosView extends StatelessWidget {
  const TrabajadorHeladosView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = CurrentUserController.currentUser;
    if (currentUser == null) {
      // If no user is logged in, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Panel Trabajador de Helados')),
      drawer: CustomDrawer(
        nombres: currentUser.nombres,
        apellidos: currentUser.apellidos,
        cedula: currentUser.numeroIdentificacion,
        rol: 'Trabajador de Helados',
        onLogout: () {
          CurrentUserController.clearCurrentUser();
          Navigator.of(context).pushReplacementNamed('/login');
        },
      ),
      body: const Center(
        child: Text('Bienvenido al panel de Trabajador de Helados'),
      ),
    );
  }
}
