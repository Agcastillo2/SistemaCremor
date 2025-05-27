import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/ui_helpers.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool obscureText;
  final void Function(String?)? onSaved;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final String? initialValue;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap; // Permitir onTap

  const CustomTextField({
    super.key,
    required this.label,
    this.icon,
    this.obscureText = false,
    this.onSaved,
    this.onChanged,
    this.validator,
    this.suffixIcon,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
    this.initialValue,
    this.controller,
    this.readOnly = false,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            icon != null ? Icon(icon, color: theme.colorScheme.primary) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIHelpers.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIHelpers.borderRadiusMedium),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabled: enabled,
        counterText: '',
      ),
      obscureText: obscureText,
      onSaved: onSaved,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap, // Pasar onTap al TextFormField
    );
  }
}
