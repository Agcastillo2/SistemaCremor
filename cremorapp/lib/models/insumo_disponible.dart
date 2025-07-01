class InsumoDisponible {
  final double leche;
  final double chocolate;
  final double vainilla;
  final double fresa;
  final double menta;

  InsumoDisponible({
    required this.leche,
    required this.chocolate,
    required this.vainilla,
    required this.fresa,
    required this.menta,
  });

  factory InsumoDisponible.fromJson(Map<String, dynamic> json) {
    return InsumoDisponible(
      leche: json['leche']?.toDouble() ?? 0.0,
      chocolate: json['chocolate']?.toDouble() ?? 0.0,
      vainilla: json['vainilla']?.toDouble() ?? 0.0,
      fresa: json['fresa']?.toDouble() ?? 0.0,
      menta: json['menta']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'leche': leche,
    'chocolate': chocolate,
    'vainilla': vainilla,
    'fresa': fresa,
    'menta': menta,
  };
}
