import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class AsistenciaService {
  // IP de la computadora en la red local
  static const String baseUrl = 'http://192.168.18.8:8001';

  static Future<Map<String, dynamic>> registrarEntrada({
    required int idPersona,
    required int idRol,
    required int idPuesto,
    required String turno,
    String? observaciones,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/asistencia/entrada'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_persona': idPersona,
        'id_rol': idRol,
        'id_puesto': idPuesto,
        'turno': turno,
        'observaciones': observaciones,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrar entrada: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> registrarSalida({
    required int idPersona,
    String? observaciones,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/asistencia/salida/$idPersona'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'observaciones': observaciones}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrar salida: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerPuestos() async {
    try {
      print('Intentando obtener puestos de: $baseUrl/puestos');

      // Primero probar la conexión
      bool conexion = await probarConexion();
      if (!conexion) {
        throw Exception('No hay conexión con el servidor');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/puestos'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('Timeout al intentar obtener puestos');
              throw TimeoutException('La conexión tardó demasiado');
            },
          );

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        final result = List<Map<String, dynamic>>.from(data);
        print('Puestos obtenidos: $result');
        return result;
      } else {
        print('Error del servidor: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Error del servidor: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error al obtener puestos: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerHistorialRegistros(
    int idPersona,
  ) async {
    try {
      print('🔄 Obteniendo historial de registros para persona $idPersona');
      final response = await http.get(
        Uri.parse('$baseUrl/asistencia/?persona_id=$idPersona'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // Convertir a lista de mapas y ordenar por fecha_hora_entrada descendente
        var registros = List<Map<String, dynamic>>.from(data);
        registros.sort((a, b) {
          // Comparar primero por fecha_hora_entrada
          var dateA = DateTime.parse(a['fecha_hora_entrada']);
          var dateB = DateTime.parse(b['fecha_hora_entrada']);
          return dateB.compareTo(
            dateA,
          ); // Orden descendente (más reciente primero)
        });
        return registros;
      } else {
        print(
          '❌ Error al obtener historial: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Error al obtener historial: ${response.body}');
      }
    } catch (e) {
      print('❌ Error al obtener historial: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerRegistroActivo(
    int idPersona,
  ) async {
    try {
      print('🔄 Obteniendo registro activo para persona $idPersona');
      final response = await http.get(
        Uri.parse('$baseUrl/asistencia/?persona_id=$idPersona'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Código de respuesta: ${response.statusCode}');
      print('📦 Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> registros = jsonDecode(response.body);
        try {
          final registroActivo = registros.firstWhere(
            (registro) => registro['fecha_hora_salida'] == null,
          );
          print('✅ Registro activo encontrado: $registroActivo');
          return Map<String, dynamic>.from(registroActivo);
        } on StateError {
          print('ℹ️ No hay registro activo');
          return <
            String,
            dynamic
          >{}; // Retornamos un mapa vacío tipado explícitamente
        }
      } else {
        print(
          '❌ Error al obtener registros: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'No se pudo obtener el registro activo: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error al obtener registro activo: $e');
      rethrow;
    }
  }

  static Future<bool> probarConexion() async {
    try {
      print('🔍 Probando conexión a: $baseUrl');
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('⏰ Timeout en prueba de conexión');
              throw TimeoutException('La conexión tardó demasiado');
            },
          );
      print('📡 Respuesta: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error en prueba de conexión: $e');
      return false;
    }
  }
}
