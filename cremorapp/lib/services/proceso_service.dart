import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class ProcesoService {
  static Future<Map<String, dynamic>> iniciarProceso({
    required int idPersona,
    required int procesoX,
    required int procesoY,
    required double lecheIngresada,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/procesos/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_persona': idPersona,
          'proceso_x': procesoX,
          'proceso_y': procesoY,
          'leche_ingresada': lecheIngresada,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al iniciar proceso: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> finalizarProceso({
    required int idProceso,
    required double produccionKg,
    double? lecheSobrante,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/procesos/$idProceso'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'estado': 'Finalizado',
          'produccion_kg': produccionKg,
          if (lecheSobrante != null) 'leche_sobrante': lecheSobrante,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al finalizar proceso: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> obtenerUltimoProceso() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/procesos/ultimo'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener último proceso: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> listarProcesos({
    required int pagina,
    int limite = 6,
  }) async {
    try {
      final skip = (pagina - 1) * limite;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/procesos/?skip=$skip&limit=$limite'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error al listar procesos: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
