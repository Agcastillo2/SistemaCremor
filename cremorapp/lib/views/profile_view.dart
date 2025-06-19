import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/profile_controller.dart';
import '../controllers/current_user_controller.dart';
import '../models/user_update_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_drawer.dart';
import '../utils/icons.dart';
import '../utils/validators.dart';
import '../utils/drawer_items_helper.dart';
import 'register_view.dart';
import 'change_password_view.dart';

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
  late TextEditingController _identificacionController;
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _telefonoController;
  late TextEditingController _correoController;
  late TextEditingController _direccionController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _numeroHijosController;

  Future<bool> _validateAndShowAgeDialog(DateTime date) async {
    final validationResult = Validators.validateFechaNacimiento(
      date.toIso8601String(),
    );

    if (validationResult.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationResult.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    if (validationResult.needsConfirmation) {
      if (!mounted) return false;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Advertencia de Edad'),
            content: Text(
              validationResult.confirmationMessage ??
                  'La persona es menor de edad. ¿Desea continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continuar'),
              ),
            ],
          );
        },
      );

      return confirmed ?? false;
    }

    return true;
  }

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
    super.dispose();
  }

  // Campo Fecha Nacimiento builder
  Widget _buildFechaNacimientoField() {
    return CustomTextField(
      controller: _fechaNacimientoController,
      label: 'Fecha de Nacimiento',
      readOnly: true,
      icon: Icons.calendar_today,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate:
              DateTime.tryParse(_fechaNacimientoController.text) ??
              DateTime.now().subtract(const Duration(days: 365 * 18)),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          final validationResult = Validators.validateFechaNacimiento(
            picked.toIso8601String(),
          );
          if (validationResult.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(validationResult.error!),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          if (validationResult.needsConfirmation) {
            final confirmed = await showDialog<bool>(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text('Advertencia de Edad'),
                    content: Text(
                      validationResult.confirmationMessage ??
                          'La persona es menor de edad. ¿Desea continuar?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Continuar'),
                      ),
                    ],
                  ),
            );
            if (confirmed != true) return;
          }
          setState(
            () =>
                _fechaNacimientoController.text =
                    picked.toIso8601String().split('T')[0],
          );
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty)
          return 'La fecha de nacimiento es requerida';
        final result = Validators.validateFechaNacimiento(value);
        return result.error;
      },
    );
  }

  Future<void> _submit() async {
    // Validate fecha nacimiento first
    final fechaNacimiento = _fechaNacimientoController.text;
    final ageValidation = Validators.validateFechaNacimiento(fechaNacimiento);

    if (ageValidation.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ageValidation.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (ageValidation.needsConfirmation) {
      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Advertencia de Edad'),
            content: Text(
              ageValidation.confirmationMessage ??
                  'La persona es menor de edad. ¿Desea continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continuar'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        return;
      }
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
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
          tipoSangre: currentUser.tipoSangre,
          tipoLicencia: currentUser.tipoLicencia,
          numeroHijos: int.parse(_numeroHijosController.text),
          antiguedadConduccion: currentUser.antiguedadConduccion,
          idRol: currentUser.idRol,
          currentPassword: null,
          newPassword: null,
        );

        await _controller.updateProfile(userData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString();
          });

          // Si es un error de contraseña, mostramos un mensaje más específico
          String errorMessage;
          if (e.toString().contains('contraseña actual es incorrecta')) {
            errorMessage = 'La contraseña actual ingresada es incorrecta';
          } else {
            errorMessage = 'Error al actualizar el perfil: ${e.toString()}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
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
    // Drawer items logic: supervisor vs others (entry/exit registration)
    final currentUser = CurrentUserController.currentUser!;
    final roleLower = currentUser.rol.toLowerCase();
    late List<DrawerItem> drawerItems;
    if (roleLower.contains('supervisor')) {
      drawerItems = [
        DrawerItem(
          titleKey: 'dashboard',
          icon: AppIcons.home,
          route: '/supervisor',
        ),
        DrawerItem(
          titleKey: 'profile',
          icon: AppIcons.profile,
          route: '/profile',
        ),
        DrawerItem(
          titleKey: 'register',
          icon: AppIcons.manage_users,
          route: '/register',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterView()),
            );
          },
        ),
        DrawerItem(titleKey: 'logout', icon: AppIcons.logout, route: '/login'),
      ];
    } else {
      final baseItems = [
        DrawerItem(
          titleKey: 'dashboard',
          icon: AppIcons.home,
          route:
              roleLower.contains('nata') ? '/jefe-nata' : '/trabajador-helados',
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
      drawerItems = insertRegisterItems(baseItems, context, currentUser);
    }
    return Scaffold(
      drawer: AppDrawer(currentRoute: '/profile', items: drawerItems),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Theme.of(context).primaryColor,
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
              _buildFechaNacimientoField(),
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
              CustomButton(
                text: 'Cambiar Contraseña',
                icon: Icons.lock_outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordView(),
                    ),
                  );
                },
                isOutlined: true,
              ),
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
