import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../controllers/password_recovery_controller.dart';
import '../utils/validators.dart';

class PasswordRecoveryView extends StatefulWidget {
  const PasswordRecoveryView({super.key});

  @override
  State<PasswordRecoveryView> createState() => _PasswordRecoveryViewState();
}

class _PasswordRecoveryViewState extends State<PasswordRecoveryView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = PasswordRecoveryController();
  String _identificacion = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  Future<void> _buscarUsuario() async {
    if (_identificacion.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingrese un número de cédula';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _controller.buscarUsuario(_identificacion);

    setState(() {
      _isLoading = false;
      if (result.$1 != null) {
        _userData = result.$1;
        _errorMessage = null;
      } else {
        _userData = null;
        _errorMessage = result.$2;
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_password != _confirmPassword) {
        setState(() {
          _errorMessage = 'Las contraseñas no coinciden';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _formKey.currentState?.save();

      final message = await _controller.cambiarPassword(
        _identificacion,
        _password,
      );

      if (!mounted) return;

      if (message == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Contraseña')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Número de Cédula',
                      icon: Icons.person,
                      onChanged:
                          (v) => setState(() => _identificacion = v ?? ''),
                      validator: Validators.validateIdentificacion,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _buscarUsuario,
                    child: const Text('Buscar'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_userData != null) ...[
                CustomTextField(
                  label: 'Nombres',
                  initialValue: _userData!['nombres'],
                  enabled: false,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Apellidos',
                  initialValue: _userData!['apellidos'],
                  enabled: false,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Nueva Contraseña',
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  onSaved: (v) => _password = v ?? '',
                  validator: Validators.validatePassword,
                  enabled: !_isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(() {
                          _obscurePassword = !_obscurePassword;
                        }),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirmar Nueva Contraseña',
                  icon: Icons.lock,
                  obscureText: _obscureConfirmPassword,
                  onSaved: (v) => _confirmPassword = v ?? '',
                  validator: Validators.validatePassword,
                  enabled: !_isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        }),
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text:
                      _isLoading ? 'Actualizando...' : 'Actualizar Contraseña',
                  onPressed: _isLoading ? null : _submit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
