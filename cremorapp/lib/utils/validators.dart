class Validators {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese su usuario';
    if (value.length < 4) return 'El usuario debe tener al menos 4 caracteres';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese su contraseña';
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? validateIdentificacion(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese el número de identificación';
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return 'Cédula inválida';
    }
    if (value.length != 10) {
      return 'La cédula debe tener 10 dígitos';
    }
    return null;
  }

  static String? validateNombres(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese los nombres';
    return null;
  }

  static String? validateApellidos(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese los apellidos';
    return null;
  }

  static String? validateNumeroHijos(String? value) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null) return 'Ingrese un número válido';
    return null;
  }

  static String? validateDireccion(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese la dirección';
    return null;
  }

  static String? validateTelefono(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese el teléfono';
    if (value.length != 10) return 'El teléfono debe tener 10 dígitos';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El teléfono solo debe contener números';
    }
    return null;
  }

  static String? validateCorreo(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese el correo electrónico';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Correo electrónico inválido';
    return null;
  }

  static String? validateFechaNacimiento(String? value) {
    if (value == null || value.isEmpty) {
      return 'Seleccione la fecha de nacimiento';
    }
    // Validación simple de formato YYYY-MM-DD
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}?$');
    if (!regex.hasMatch(value)) return 'Formato de fecha inválido (YYYY-MM-DD)';
    return null;
  }
}
