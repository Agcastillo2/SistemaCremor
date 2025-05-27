import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/profile_controller.dart';
import '../controllers/current_user_controller.dart';
import '../models/user_update_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ProfileController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPasswordFields = false;
  late TextEditingController _identificacionController;
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _telefonoController;
  late TextEditingController _correoController;
  late TextEditingController _direccionController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _numeroHijosController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    final currentUser = CurrentUserController.currentUser!;
    _identificacionController = TextEditingController(
      text: currentUser.numeroIdentificacion,
    );
    _nombresController = TextEditingController(text: currentUser.nombres);
    _apellidosController = TextEditingController(text: currentUser.apellidos);
    _telefonoController = TextEditingController(text: currentUser.telefono);
    _correoController = TextEditingController(text: currentUser.correo);
    _direccionController = TextEditingController(text: currentUser.direccion);
    _fechaNacimientoController = TextEditingController(
      text: currentUser.fechaNacimiento.toIso8601String().split('T')[0],
    );
    _numeroHijosController = TextEditingController(
      text: currentUser.numeroHijos.toString(),
    );
  }

  @override
  void dispose() {
    _identificacionController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _fechaNacimientoController.dispose();
    _numeroHijosController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final currentUser = CurrentUserController.currentUser!;

      final userData = UserUpdateModel(
        numeroIdentificacion: _identificacionController.text,
        nombres: _nombresController.text,
        apellidos: _apellidosController.text,
        telefono: _telefonoController.text,
        correo: _correoController.text,
        direccion: _direccionController.text,
        fechaNacimiento: DateTime.parse(_fechaNacimientoController.text),
        genero: currentUser.genero,
        disponibilidad: currentUser.disponibilidad,
        estadoCivil: currentUser.estadoCivil,
        tipoSangre: 'A+', // Usar el tipo de sangre del perfil actual
        tipoLicencia: 'NINGUNA', // Usar el tipo de licencia del perfil actual
        numeroHijos: int.parse(_numeroHijosController.text),
        antiguedadConduccion: 0, // Usar el valor del perfil actual
        idRol: currentUser.idRol, // Mantener el mismo rol
        currentPassword:
            _currentPasswordController.text.isEmpty
                ? null
                : _currentPasswordController.text,
        newPassword:
            _newPasswordController.text.isEmpty
                ? null
                : _newPasswordController.text,
      );

      final (success, error) = await _controller.updateProfile(userData);

      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = CurrentUserController.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Número de Cédula',
                controller: _identificacionController,
                icon: Icons.badge,
                validator: _controller.validateIdentificacion,
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nombres',
                controller: _nombresController,
                icon: Icons.person,
                validator: _controller.validateNombres,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Apellidos',
                controller: _apellidosController,
                icon: Icons.person,
                validator: _controller.validateApellidos,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Teléfono',
                controller: _telefonoController,
                icon: Icons.phone,
                validator: _controller.validateTelefono,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Correo Electrónico',
                controller: _correoController,
                icon: Icons.email,
                validator: _controller.validateCorreo,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Dirección',
                controller: _direccionController,
                icon: Icons.location_on,
                validator: _controller.validateDireccion,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Fecha de Nacimiento',
                controller: _fechaNacimientoController,
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: currentUser.fechaNacimiento,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(
                      () =>
                          _fechaNacimientoController.text =
                              date.toIso8601String().split('T')[0],
                    );
                  }
                },
                validator: _controller.validateFechaNacimiento,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Número de Hijos',
                controller: _numeroHijosController,
                icon: Icons.child_care,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _controller.validateNumeroHijos,
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                title: const Text('Cambiar Contraseña'),
                value: _showPasswordFields,
                onChanged: (value) {
                  setState(() {
                    _showPasswordFields = value ?? false;
                    if (!_showPasswordFields) {
                      _currentPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    }
                  });
                },
              ),
              if (_showPasswordFields) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Contraseña Actual',
                  controller: _currentPasswordController,
                  icon: Icons.lock,
                  obscureText: _obscureCurrentPassword,
                  validator:
                      (value) =>
                          _controller.validateCurrentPassword(value, null),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(
                          () =>
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword,
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
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              CustomButton(
                text: _isLoading ? 'Guardando...' : 'Guardar Cambios',
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
