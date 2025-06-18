import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordRecoveryController {
  Future<(Map<String, dynamic>?, String?)> buscarUsuario(
    String identificacion,
  ) async {
    try {
      final url = Uri.parse(
        'http://192.168.18.8:8001/personas/by-id/$identificacion',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (
          {'nombres': data['nombres'], 'apellidos': data['apellidos']},
          null,
        );
      } else {
        final data = jsonDecode(response.body);
        return (null, data['detail']?.toString() ?? 'Usuario no encontrado');
      }
    } catch (e) {
      return (null, 'Error de conexión: $e');
    }
  }

  Future<String?> cambiarPassword(
    String identificacion,
    String newPassword,
  ) async {
    try {
      final url = Uri.parse('http://192.168.18.8:8001/personas/reset-password');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "numero_identificacion": identificacion,
          "new_password": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['detail']?.toString() ?? 'Error al cambiar la contraseña';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }
}
