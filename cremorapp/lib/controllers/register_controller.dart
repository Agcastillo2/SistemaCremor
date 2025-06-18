import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/validators.dart';

class RegisterController {
  String? validateIdentificacion(String? value) =>
      Validators.validateIdentificacion(value);
  String? validateNombres(String? value) => Validators.validateNombres(value);
  String? validateApellidos(String? value) =>
      Validators.validateApellidos(value);
  String? validateFechaNacimiento(String? value) =>
      Validators.validateFechaNacimiento(value);
  String? validateNumeroHijos(String? value) =>
      Validators.validateNumeroHijos(value);
  String? validateDireccion(String? value) =>
      Validators.validateDireccion(value);
  String? validateTelefono(String? value) => Validators.validateTelefono(value);
  String? validateCorreo(String? value) => Validators.validateCorreo(value);
  String? validatePassword(String? value) => Validators.validatePassword(value);

  Future<String?> registerUser({
    required String numeroIdentificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String numeroHijos,
    required String tipoSangre,
    required bool genero,
    required String direccion,
    required String telefono,
    required String correo,
    required String disponibilidad,
    required String estadoCivil,
    required String tipoLicencia,
    required String vencimientoLicencia,
    required String antiguedadConduccion,
    required String password,
    required int idRol,
  }) async {
    final url = Uri.parse('http://192.168.18.8:8001/personas/');
    final body = jsonEncode({
      "numero_identificacion": numeroIdentificacion,
      "nombres": nombres,
      "apellidos": apellidos,
      "fecha_nacimiento": fechaNacimiento,
      "numero_hijos": int.tryParse(numeroHijos) ?? 0,
      "tipo_sangre": tipoSangre,
      "genero": genero,
      "direccion": direccion,
      "telefono": telefono,
      "correo": correo,
      "disponibilidad": disponibilidad,
      "estado_civil": estadoCivil,
      "tipo_licencia": tipoLicencia,
      "vencimiento_licencia":
          vencimientoLicencia.isEmpty ? null : vencimientoLicencia,
      "antiguedad_conduccion": int.tryParse(antiguedadConduccion) ?? 0,
      "password": password,
      "id_rol": idRol,
    });
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return 'Usuario registrado correctamente';
    } else {
      try {
        final data = jsonDecode(response.body);
        // Si hay errores de validación, mostrar el detalle
        if (data is Map && data.containsKey('detail')) {
          if (data['detail'] is List) {
            return (data['detail'] as List).map((e) => e['msg']).join(', ');
          }
          return data['detail'].toString();
        }
        return 'Error desconocido';
      } catch (_) {
        return 'Error al crear usuario';
      }
    }
  }
}
