// filepath: c:\Registros\Proyecto\Dev\CREMOR\v4\SistemaCremor\cremorapp\lib\views\login_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../controllers/login_controller.dart';
import '../controllers/app_settings_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/settings_buttons.dart';
import '../widgets/app_logo.dart';
import '../utils/theme.dart';
import '../utils/ui_helpers.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = LoginController();
  String _identificacion = '';
  String _password = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      _formKey.currentState?.save();

      final (user, error) = await _controller.login(_identificacion, _password);

      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      if (user != null && mounted) {
        // Store the current user and navigate to the corresponding role view
        Navigator.of(context).pushReplacementNamed(user.getRolRoute());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDarkMode = AppSettingsController.isDarkMode(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [SettingsButtons(mini: true), SizedBox(width: 8)],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDarkMode
                    ? const [Color(0xFF121212), Color(0xFF1F1F1F)]
                    : const [Color(0xFF0F2027), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(width: 400, height: 200),
                const SizedBox(height: 40),
                Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      UIHelpers.borderRadiusXLarge,
                    ),
                  ),
                  color:
                      isDarkMode
                          ? Colors.grey[850]
                          : Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 40,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t.login,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          UIHelpers.vSpaceLarge,
                          CustomTextField(
                            label: t.identification,
                            icon: AppIcons.id,
                            onSaved: (v) => _identificacion = v ?? '',
                            validator: _controller.validateIdentificacion,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          UIHelpers.vSpaceMedium,
                          CustomTextField(
                            label: t.password,
                            icon: AppIcons.password,
                            obscureText: _obscurePassword,
                            onSaved: (v) => _password = v ?? '',
                            validator: _controller.validatePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? AppIcons.visibility
                                    : AppIcons.visibilityOff,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                            ),
                          ),
                          UIHelpers.vSpaceMedium,
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  UIHelpers.borderRadiusSmall,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  UIHelpers.hSpaceSmall,
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          UIHelpers.vSpaceLarge,
                          CustomButton(
                            text: _isLoading ? '${t.login}...' : t.login,
                            onPressed: _isLoading ? null : _submit,
                            icon: AppIcons.login,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
