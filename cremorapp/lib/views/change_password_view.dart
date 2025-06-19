import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';
import '../models/user_update_model.dart';
import '../controllers/current_user_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ProfileController();
  bool _isLoading = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final currentUser = CurrentUserController.currentUser!;
        final userData = UserUpdateModel(
          // Mantener los datos actuales del usuario
          numeroIdentificacion: currentUser.numeroIdentificacion,
          nombres: currentUser.nombres,
          apellidos: currentUser.apellidos,
          telefono: currentUser.telefono,
          correo: currentUser.correo,
          direccion: currentUser.direccion,
          fechaNacimiento: currentUser.fechaNacimiento,
          genero: currentUser.genero,
          disponibilidad: currentUser.disponibilidad,
          estadoCivil: currentUser.estadoCivil,
          tipoSangre: currentUser.tipoSangre,
          tipoLicencia: currentUser.tipoLicencia,
          numeroHijos: currentUser.numeroHijos,
          antiguedadConduccion: currentUser.antiguedadConduccion,
          idRol: currentUser.idRol,
          // Agregar las contraseñas
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

        final (success, error) = await _controller.updateProfile(userData);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contraseña actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Regresar a la vista anterior
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Error al actualizar la contraseña'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Ingrese su contraseña actual y la nueva contraseña',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Contraseña Actual',
                controller: _currentPasswordController,
                icon: Icons.lock,
                obscureText: _obscureCurrentPassword,
                validator:
                    (value) => _controller.validateCurrentPassword(
                      value,
                      _newPasswordController.text,
                    ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed:
                      () => setState(
                        () =>
                            _obscureCurrentPassword = !_obscureCurrentPassword,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nueva Contraseña',
                controller: _newPasswordController,
                icon: Icons.lock_outline,
                obscureText: _obscureNewPassword,
                validator:
                    (value) => _controller.validateNewPassword(
                      value,
                      _currentPasswordController.text,
                    ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed:
                      () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Confirmar Nueva Contraseña',
                controller: _confirmPasswordController,
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                validator:
                    (value) => _controller.validateConfirmPassword(
                      value,
                      _newPasswordController.text,
                    ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed:
                      () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text:
                    _isLoading
                        ? 'Cambiando contraseña...'
                        : 'Cambiar Contraseña',
                onPressed: _isLoading ? null : _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
