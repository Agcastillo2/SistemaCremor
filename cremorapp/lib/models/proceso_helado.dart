class ProcesoHelado {
  final int id;
  final DateTime fecha;
  final double lecheIngresada;
  final int unidadesVainilla;
  final int unidadesChocolate;
  final int unidadesFresa;
  final int unidadesMenta;
  final String responsable;
  final bool finalizado;

  ProcesoHelado({
    required this.id,
    required this.fecha,
    required this.lecheIngresada,
    required this.unidadesVainilla,
    required this.unidadesChocolate,
    required this.unidadesFresa,
    required this.unidadesMenta,
    required this.responsable,
    required this.finalizado,
  });

  factory ProcesoHelado.fromJson(Map<String, dynamic> json) {
    return ProcesoHelado(
      id: json['id'] as int,
      fecha: DateTime.parse(json['fecha']),
      lecheIngresada: json['leche_ingresada']?.toDouble() ?? 0.0,
      unidadesVainilla: json['unidades_vainilla'] ?? 0,
      unidadesChocolate: json['unidades_chocolate'] ?? 0,
      unidadesFresa: json['unidades_fresa'] ?? 0,
      unidadesMenta: json['unidades_menta'] ?? 0,
      responsable: json['responsable'] ?? '',
      finalizado: json['finalizado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fecha': fecha.toIso8601String(),
    'leche_ingresada': lecheIngresada,
    'unidades_vainilla': unidadesVainilla,
    'unidades_chocolate': unidadesChocolate,
    'unidades_fresa': unidadesFresa,
    'unidades_menta': unidadesMenta,
    'responsable': responsable,
    'finalizado': finalizado,
  };
}
