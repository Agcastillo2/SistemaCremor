import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/validators.dart';
import './current_user_controller.dart';

class LoginController {
  String? validateIdentificacion(String? value) =>
      Validators.validateIdentificacion(value);
  String? validatePassword(String? value) => Validators.validatePassword(value);

  Future<(UserModel?, String?)> login(
    String identificacion,
    String password,
  ) async {
    try {
      final url = Uri.parse('http://192.168.18.8:8001/personas/login');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "numero_identificacion": identificacion,
          "password": password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        CurrentUserController.setCurrentUser(user);
        return (user, null);
      } else {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('detail')) {
          return (null, data['detail'].toString());
        }
        return (null, 'Error al iniciar sesión');
      }
    } catch (e) {
      return (null, 'Error de conexión: $e');
    }
  }
}
