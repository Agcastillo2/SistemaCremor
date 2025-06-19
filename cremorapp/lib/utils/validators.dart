class ValidationResult {
  final String? error;
  final bool needsConfirmation;
  final String? confirmationMessage;

  ValidationResult({
    this.error,
    this.needsConfirmation = false,
    this.confirmationMessage,
  });
}

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

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese nombre';
    }
    if (!RegExp(r"^[A-Za-zÀ-ÿ\s]+$").hasMatch(value)) {
      return 'El nombre solo puede contener letras';
    }
    return null;
  }

  static String? validateSurname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese apellido';
    }
    if (!RegExp(r"^[A-Za-zÀ-ÿ\s]+$").hasMatch(value)) {
      return 'El apellido solo puede contener letras';
    }
    return null;
  }

  static String? validateNombres(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese sus nombres';
    }
    if (!RegExp(r'^[A-Za-zÀ-ÿ\s]+$').hasMatch(value)) {
      return 'Los nombres solo pueden contener letras';
    }
    return null;
  }

  static String? validateApellidos(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese sus apellidos';
    }
    if (!RegExp(r'^[A-Za-zÀ-ÿ\s]+$').hasMatch(value)) {
      return 'Los apellidos solo pueden contener letras';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese edad';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Edad inválida';
    }
    if (age < 16) {
      return 'Debe tener al menos 16 años';
    }
    // Note: ages 16-17 require parental confirmation handled in controller
    return null;
  }

  static ValidationResult validateFechaNacimiento(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult(error: 'Seleccione la fecha de nacimiento');
    }

    try {
      final fecha = DateTime.parse(value);
      final now = DateTime.now();
      final age =
          now.year -
          fecha.year -
          ((now.month > fecha.month ||
                  (now.month == fecha.month && now.day >= fecha.day))
              ? 0
              : 1);

      if (age < 16) {
        return ValidationResult(
          error: 'No se puede registrar a una persona menor de 16 años',
        );
      }

      if (age < 18) {
        return ValidationResult(
          needsConfirmation: true,
          confirmationMessage:
              'La persona es menor de edad (entre 16 y 18 años). ¿Desea continuar con el registro?',
        );
      }

      return ValidationResult(); // Sin error y sin necesidad de confirmación
    } catch (e) {
      return ValidationResult(error: 'Fecha de nacimiento inválida');
    }
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
}
