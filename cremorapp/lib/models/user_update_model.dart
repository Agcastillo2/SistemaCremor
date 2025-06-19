class UserUpdateModel {
  final String numeroIdentificacion;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final String direccion;
  final DateTime fechaNacimiento; // Cambiado a no opcional (obligatorio)
  final bool genero;
  final String disponibilidad;
  final String estadoCivil;
  final String tipoSangre;
  final String tipoLicencia;
  final DateTime?
  vencimientoLicencia; // Opcional pero si se usa debe ser fecha válida
  final int numeroHijos;
  final int antiguedadConduccion;
  final int idRol; // Agregado idRol para mantener la relación con el rol
  final String? currentPassword;
  final String? newPassword;

  UserUpdateModel({
    required this.numeroIdentificacion,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.direccion,
    required this.fechaNacimiento, // Requerido
    required this.genero,
    required this.disponibilidad,
    required this.estadoCivil,
    required this.tipoSangre,
    required this.tipoLicencia,
    this.vencimientoLicencia,
    required this.numeroHijos,
    required this.antiguedadConduccion,
    required this.idRol, // Requerido
    this.currentPassword,
    this.newPassword,
  });
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'numero_identificacion': numeroIdentificacion,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'correo': correo,
      'direccion': direccion,
      'fecha_nacimiento': fechaNacimiento.toIso8601String().split('T')[0],
      'genero': genero,
      'disponibilidad': disponibilidad,
      'estado_civil': estadoCivil,
      'tipo_sangre': tipoSangre,
      'tipo_licencia': tipoLicencia,
      'vencimiento_licencia':
          vencimientoLicencia?.toIso8601String().split('T')[0],
      'numero_hijos': numeroHijos,
      'antiguedad_conduccion': antiguedadConduccion,
      'id_rol': idRol,
    }; // Manejo de contraseña
    if (currentPassword != null &&
        currentPassword!.isNotEmpty &&
        newPassword != null &&
        newPassword!.isNotEmpty) {
      data['current_password'] = currentPassword;
      data['new_password'] = newPassword;
    }

    // Elimina campos nulos para evitar errores de parsing
    if (data['vencimiento_licencia'] == null) {
      data.remove('vencimiento_licencia');
    }

    return data;
  }
}
