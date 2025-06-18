class UserModel {
  final int idPersona; // Agregado idPersona
  final String numeroIdentificacion;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final String direccion;
  final DateTime fechaNacimiento;
  final bool genero;
  final String disponibilidad;
  final String estadoCivil;
  final String rol;
  final int idRol;
  final int numeroHijos;
  final String tipoSangre;
  final String tipoLicencia;
  final DateTime? vencimientoLicencia;
  final int antiguedadConduccion;
  UserModel({
    required this.idPersona, // Agregado al constructor
    required this.numeroIdentificacion,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.direccion,
    required this.fechaNacimiento,
    required this.genero,
    required this.disponibilidad,
    required this.estadoCivil,
    required this.rol,
    required this.idRol,
    required this.numeroHijos,
    required this.tipoSangre,
    required this.tipoLicencia,
    this.vencimientoLicencia,
    required this.antiguedadConduccion,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idPersona: json['id_persona'], // Ajustado para usar el campo correcto
      numeroIdentificacion: json['numero_identificacion'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      telefono: json['telefono'] ?? '',
      correo: json['correo'] ?? '',
      direccion: json['direccion'] ?? '',
      fechaNacimiento:
          json['fecha_nacimiento'] != null
              ? DateTime.parse(json['fecha_nacimiento'])
              : DateTime.now(),
      genero: json['genero'] ?? false,
      disponibilidad: json['disponibilidad'] ?? '',
      estadoCivil: json['estado_civil'] ?? '',
      rol: json['rol']['nombre_rol'],
      idRol: json['rol']['id_rol'],
      numeroHijos: json['numero_hijos'] ?? 0,
      tipoSangre: json['tipo_sangre'] ?? '',
      tipoLicencia: json['tipo_licencia'] ?? '',
      vencimientoLicencia:
          json['vencimiento_licencia'] != null
              ? DateTime.parse(json['vencimiento_licencia'])
              : null,
      antiguedadConduccion: json['antiguedad_conduccion'] ?? 0,
    );
  }

  String get nombreCompleto => '$nombres $apellidos';

  String getRolRoute() {
    switch (rol) {
      case 'JEFE_NATA':
        return '/jefe-nata';
      case 'JEFE_HELADOS':
        return '/jefe-helados';
      case 'TRABAJADOR_NATA':
        return '/trabajador-nata';
      case 'TRABAJADOR_HELADOS':
        return '/trabajador-helados';
      case 'SUPERVISOR':
        return '/supervisor';
      default:
        return '/login';
    }
  }
}
