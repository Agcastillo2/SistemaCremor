import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../controllers/register_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/theme.dart';
import '../models/rol_model.dart';
import '../utils/validators.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = RegisterController();
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _fechaNacimientoController = TextEditingController();
  final _vencimientoLicenciaController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Campos del formulario
  String _numeroIdentificacion = '';
  String _nombres = '';
  String _apellidos = '';
  DateTime? _fechaNacimiento;
  final String _numeroHijos = '';
  String _tipoSangre = 'A+';
  bool _genero = true;
  String _direccion = '';
  String _telefono = '';
  String _correo = '';
  String _disponibilidad = 'DISPONIBLE';
  String _estadoCivil = 'SOLTERO';
  String _tipoLicencia = 'NINGUNA';
  DateTime? _vencimientoLicencia;
  String _antiguedadConduccion = '';
  String _password = '';

  // Add these new fields
  List<RolModel> _roles = [];
  RolModel? _selectedRole;
  bool _loadingRoles = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await RolModel.fetchRoles();
      setState(() {
        _roles = roles;
        _loadingRoles = false;
      });
    } catch (e) {
      setState(() {
        _loadingRoles = false;
        _errorMessage = 'Error al cargar roles: $e';
      });
    }
  }

  @override
  void dispose() {
    _fechaNacimientoController.dispose();
    _vencimientoLicenciaController.dispose();
    super.dispose();
  }

  Future<void> _selectFechaNacimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      // Validar la edad
      final validationResult = Validators.validateFechaNacimiento(
        picked.toIso8601String(),
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
        return;
      }

      if (validationResult.needsConfirmation) {
        if (!mounted) return;

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Advertencia de Edad'),
              content: Text(
                validationResult.confirmationMessage ??
                    'La persona es menor de edad. ¿Desea continuar con el registro?',
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

      setState(() {
        _fechaNacimiento = picked;
        _fechaNacimientoController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _selectVencimientoLicencia() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _vencimientoLicencia ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _vencimientoLicencia) {
      setState(() {
        _vencimientoLicencia = picked;
        _vencimientoLicenciaController.text = _dateFormat.format(picked);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_fechaNacimiento == null) {
        setState(() {
          _errorMessage = 'Por favor, selecciona una fecha de nacimiento';
        });
        return;
      }

      if (_selectedRole == null) {
        setState(() {
          _errorMessage = 'Por favor, selecciona un rol';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      _formKey.currentState?.save();

      final mensaje = await _controller.registerUser(
        numeroIdentificacion: _numeroIdentificacion,
        nombres: _nombres,
        apellidos: _apellidos,
        fechaNacimiento: _dateFormat.format(_fechaNacimiento!),
        numeroHijos: _numeroHijos,
        tipoSangre: _tipoSangre,
        genero: _genero,
        direccion: _direccion,
        telefono: _telefono,
        correo: _correo,
        disponibilidad: _disponibilidad,
        estadoCivil: _estadoCivil,
        tipoLicencia: _tipoLicencia,
        vencimientoLicencia:
            _vencimientoLicencia != null
                ? _dateFormat.format(_vencimientoLicencia!)
                : '',
        antiguedadConduccion: _antiguedadConduccion,
        password: _password,
        idRol: _selectedRole!.id,
      );

      setState(() {
        _isLoading = false;
      });

      if (mensaje == 'Usuario registrado correctamente' && mounted) {
        // Mostrar diálogo de éxito
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Éxito'),
              content: const Text('Usuario registrado correctamente'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el diálogo
                    Navigator.of(
                      context,
                    ).pop(); // Volver a la pantalla anterior
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _errorMessage = mensaje;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear nuevo usuario'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  label: 'Número de identificación',
                  icon: Icons.badge,
                  onSaved: (v) => _numeroIdentificacion = v ?? '',
                  validator: _controller.validateIdentificacion,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Nombres',
                  icon: Icons.person,
                  onSaved: (v) => _nombres = v ?? '',
                  validator: _controller.validateNombres,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Apellidos',
                  icon: Icons.person,
                  onSaved: (v) => _apellidos = v ?? '',
                  validator: _controller.validateApellidos,
                ),
                const SizedBox(height: 12),
                // Fecha de nacimiento
                GestureDetector(
                  onTap: _selectFechaNacimiento,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: 'Fecha de nacimiento',
                      icon: Icons.calendar_today,
                      controller: _fechaNacimientoController,
                      validator:
                          (v) =>
                              _fechaNacimiento == null
                                  ? 'Campo requerido'
                                  : null,
                      readOnly: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _tipoSangre,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de sangre',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'A+', child: Text('A+')),
                    DropdownMenuItem(value: 'A-', child: Text('A-')),
                    DropdownMenuItem(value: 'B+', child: Text('B+')),
                    DropdownMenuItem(value: 'B-', child: Text('B-')),
                    DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                    DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                    DropdownMenuItem(value: 'O+', child: Text('O+')),
                    DropdownMenuItem(value: 'O-', child: Text('O-')),
                  ],
                  onChanged: (v) => setState(() => _tipoSangre = v ?? 'A+'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Género:'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Masculino'),
                        value: true,
                        groupValue: _genero,
                        onChanged: (v) => setState(() => _genero = v ?? true),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Femenino'),
                        value: false,
                        groupValue: _genero,
                        onChanged: (v) => setState(() => _genero = v ?? false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Dirección',
                  icon: Icons.home,
                  onSaved: (v) => _direccion = v ?? '',
                  validator: _controller.validateDireccion,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Teléfono',
                  icon: Icons.phone,
                  onSaved: (v) => _telefono = v ?? '',
                  validator: _controller.validateTelefono,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Correo electrónico',
                  icon: Icons.email,
                  onSaved: (v) => _correo = v ?? '',
                  validator: _controller.validateCorreo,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _disponibilidad,
                  decoration: const InputDecoration(
                    labelText: 'Disponibilidad',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'DISPONIBLE',
                      child: Text('DISPONIBLE'),
                    ),
                    DropdownMenuItem(
                      value: 'VACACIONES',
                      child: Text('VACACIONES'),
                    ),
                    DropdownMenuItem(
                      value: 'INACTIVO',
                      child: Text('INACTIVO'),
                    ),
                    DropdownMenuItem(
                      value: 'PERMISO_MEDICO',
                      child: Text('PERMISO MÉDICO'),
                    ),
                  ],
                  onChanged:
                      (v) =>
                          setState(() => _disponibilidad = v ?? 'DISPONIBLE'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _estadoCivil,
                  decoration: const InputDecoration(
                    labelText: 'Estado civil',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'SOLTERO', child: Text('SOLTERO')),
                    DropdownMenuItem(value: 'CASADO', child: Text('CASADO')),
                    DropdownMenuItem(
                      value: 'DIVORCIADO',
                      child: Text('DIVORCIADO'),
                    ),
                    DropdownMenuItem(value: 'VIUDO', child: Text('VIUDO')),
                    DropdownMenuItem(
                      value: 'UNION_LIBRE',
                      child: Text('UNIÓN LIBRE'),
                    ),
                  ],
                  onChanged:
                      (v) => setState(() => _estadoCivil = v ?? 'SOLTERO'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _tipoLicencia,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de licencia',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'B', child: Text('B')),
                    DropdownMenuItem(value: 'C', child: Text('C')),
                    DropdownMenuItem(value: 'D', child: Text('D')),
                    DropdownMenuItem(value: 'E', child: Text('E')),
                    DropdownMenuItem(value: 'F', child: Text('F')),
                    DropdownMenuItem(value: 'G', child: Text('G')),
                    DropdownMenuItem(value: 'A1', child: Text('A1')),
                    DropdownMenuItem(value: 'A2', child: Text('A2')),
                    DropdownMenuItem(value: 'NINGUNA', child: Text('NINGUNA')),
                  ],
                  onChanged:
                      (v) => setState(() => _tipoLicencia = v ?? 'NINGUNA'),
                ),
                const SizedBox(height: 12),
                // Vencimiento de licencia
                GestureDetector(
                  onTap: _selectVencimientoLicencia,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: 'Vencimiento de licencia',
                      icon: Icons.calendar_today,
                      controller: _vencimientoLicenciaController,
                      readOnly: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Antigüedad de conducción (años)',
                  icon: Icons.timelapse,
                  onSaved: (v) => _antiguedadConduccion = v ?? '',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Contraseña',
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  onSaved: (v) => _password = v ?? '',
                  validator: _controller.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                _loadingRoles
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<RolModel>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _roles
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role.toString()),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                      validator:
                          (value) =>
                              value == null
                                  ? 'Por favor, selecciona un rol'
                                  : null,
                    ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),
                CustomButton(
                  text: _isLoading ? 'Creando...' : 'Crear usuario',
                  onPressed: _isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
