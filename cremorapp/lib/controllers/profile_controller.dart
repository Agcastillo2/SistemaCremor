import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/user_update_model.dart';
import 'current_user_controller.dart';
import '../utils/validators.dart';

class ProfileController {
  String? validateIdentificacion(String? value) =>
      Validators.validateIdentificacion(value);

  String? validateNombres(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }

    // Validar que no contenga números
    if (RegExp(r'\d').hasMatch(value)) {
      return 'El nombre no puede contener números';
    }

    // Validar que solo contenga letras, espacios y tildes
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$').hasMatch(value)) {
      return 'El nombre solo puede contener letras';
    }

    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    return null;
  }

  String? validateApellidos(String? value) {
    if (value == null || value.isEmpty) {
      return 'Los apellidos son requeridos';
    }

    // Validar que no contenga números
    if (RegExp(r'\d').hasMatch(value)) {
      return 'Los apellidos no pueden contener números';
    }

    // Validar que solo contenga letras, espacios y tildes
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$').hasMatch(value)) {
      return 'Los apellidos solo pueden contener letras';
    }

    if (value.length < 2) {
      return 'Los apellidos deben tener al menos 2 caracteres';
    }

    return null;
  }

  String? validateTelefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }
    if (value.length != 10) {
      return 'El teléfono debe tener 10 dígitos';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El teléfono solo debe contener números';
    }
    return null;
  }

  String? validateCorreo(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es requerido';
    }
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  String? validateDireccion(String? value) {
    if (value == null || value.isEmpty) {
      return 'La dirección es requerida';
    }
    if (value.length < 5) {
      return 'La dirección debe tener al menos 5 caracteres';
    }
    return null;
  }

  String? validateCurrentPassword(String? value, String? newPassword) {
    if (newPassword != null && newPassword.isNotEmpty) {
      if (value == null || value.isEmpty) {
        return 'Ingrese la contraseña actual';
      }
      return Validators.validatePassword(value);
    }
    return null;
  }

  String? validateNewPassword(String? value, String? currentPassword) {
    if (currentPassword != null && currentPassword.isNotEmpty) {
      return Validators.validatePassword(value);
    }
    if (value == null || value.isEmpty) {
      return null; // La nueva contraseña es opcional
    }
    return Validators.validatePassword(value);
  }

  String? validateConfirmPassword(String? value, String? newPassword) {
    if (newPassword == null || newPassword.isEmpty) {
      return null;
    }
    if (value != newPassword) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  ValidationResult validateFechaNacimiento(String? value) =>
      Validators.validateFechaNacimiento(value);

  String? validateNumeroHijos(String? value) =>
      Validators.validateNumeroHijos(value);
  Future<(bool, String?)> updateProfile(UserUpdateModel userData) async {
    try {
      final currentUser = CurrentUserController.currentUser;
      if (currentUser == null) {
        return (false, 'Usuario no autenticado');
      }
      final url = Uri.parse(
        'http://192.168.18.8:8001/personas/${currentUser.idPersona}',
      );

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedUser = UserModel.fromJson(data);
        CurrentUserController.setCurrentUser(updatedUser);
        return (true, null);
      } else {
        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body);
          if (data.containsKey('detail')) {
            if (data['detail'] == 'La contraseña actual es incorrecta') {
              return (false, 'La contraseña actual es incorrecta');
            }
            return (false, data['detail'].toString());
          }
        } catch (e) {
          // JSON decode error
        }
        return (false, 'Error al actualizar el perfil');
      }
    } catch (e) {
      return (false, 'Error de conexión: $e');
    }
  }
}
