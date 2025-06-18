import 'dart:convert';
import 'package:http/http.dart' as http;

class RolModel {
  final int id;
  final String nombreRol;
  final String descripcionRol;
  final String departamento;
  final bool activo;
  final String nombreMostrado;

  RolModel({
    required this.id,
    required this.nombreRol,
    required this.descripcionRol,
    required this.departamento,
    required this.activo,
  }) : nombreMostrado = _obtenerDescripcion(nombreRol);

  static String _obtenerDescripcion(String nombreRol) {
    final descripciones = {
      'JEFE_NATA': 'Jefe de Nata',
      'JEFE_HELADOS': 'Jefe de Helados',
      'TRABAJADOR_NATA': 'Trabajador de Nata',
      'TRABAJADOR_HELADOS': 'Trabajador de Helados',
      'SUPERVISOR': 'Supervisor',
    };
    return descripciones[nombreRol] ?? nombreRol;
  }

  factory RolModel.fromJson(Map<String, dynamic> json) {
    return RolModel(
      id: json['id_rol'],
      nombreRol: json['nombre_rol'],
      descripcionRol: json['descripcion_rol'] ?? '',
      departamento: json['departamento'] ?? '',
      activo: json['activo'] ?? true,
    );
  }

  static Future<List<RolModel>> fetchRoles() async {
    try {
      final url = Uri.parse('http://192.168.18.8:8001/roles/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => RolModel.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load roles');
      }
    } catch (e) {
      throw Exception('Failed to fetch roles: $e');
    }
  }

  @override
  String toString() => nombreMostrado;
}
