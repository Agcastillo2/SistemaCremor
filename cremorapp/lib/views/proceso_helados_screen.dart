import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../controllers/current_user_controller.dart';
import '../models/proceso_helado.dart';
import '../models/insumo_disponible.dart';
import '../utils/ui_helpers.dart' hide AppIcons;
import '../widgets/info_card.dart';
import '../widgets/list_card.dart';

class ProcesoHeladosScreen extends StatefulWidget {
  const ProcesoHeladosScreen({super.key});

  @override
  State<ProcesoHeladosScreen> createState() => _ProcesoHeladosScreenState();
}

class _ProcesoHeladosScreenState extends State<ProcesoHeladosScreen> {
  InsumoDisponible? _insumos;
  Map<String, double> _insumosIngresados = {
    'vainilla': 0,
    'chocolate': 0,
    'fresa': 0,
    'menta': 0,
  };
  Map<String, int> _resultadosPosibles = {
    'vainilla': 0,
    'chocolate': 0,
    'fresa': 0,
    'menta': 0,
  };
  ProcesoHelado? _ultimo;
  List<ProcesoHelado> _historial = [];
  int? _procesoId;
  bool _procesoActivo = false;

  final _controladoresInicio = {
    'leche': TextEditingController(),
    'vainilla': TextEditingController(),
    'chocolate': TextEditingController(),
    'fresa': TextEditingController(),
    'menta': TextEditingController(),
  };

  final _controladoresFinalizacion = {
    'vainilla': TextEditingController(),
    'chocolate': TextEditingController(),
    'fresa': TextEditingController(),
    'menta': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    for (var controller in [
      ..._controladoresInicio.values,
      ..._controladoresFinalizacion.values,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      await Future.wait([
        _cargarInsumosDisponibles(),
        _cargarUltimoProceso(),
        _cargarHistorial(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error al cargar datos')));
      }
    }
  }

  // Cabeceras de autenticación
  Map<String, String> _authHeaders() {
    final id = CurrentUserController.currentUser!.idPersona;
    return {'Content-Type': 'application/json', 'X-Id-Persona': id.toString()};
  }

  Future<void> _cargarInsumosDisponibles() async {
    final url = Uri.parse('$baseUrl/produccion/insumos_disponibles');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      setState(
        () => _insumos = InsumoDisponible.fromJson(jsonDecode(response.body)),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar insumos disponibles')),
        );
      }
    }
  }

  Future<void> _cargarUltimoProceso() async {
    final url = Uri.parse('$baseUrl/produccion/ultimo');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      setState(() {
        _ultimo = ProcesoHelado.fromJson(jsonDecode(response.body));
        _procesoActivo = !_ultimo!.finalizado;
        _procesoId = _ultimo!.id;
      });
    } else if (response.statusCode == 404) {
      // Es normal no tener último proceso la primera vez
      setState(() {
        _ultimo = null;
        _procesoActivo = false;
        _procesoId = null;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar último proceso')),
        );
      }
    }
  }

  Future<void> _cargarHistorial() async {
    final url = Uri.parse('$baseUrl/produccion/historial');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      setState(() {
        _historial =
            (jsonDecode(response.body) as List)
                .map((i) => ProcesoHelado.fromJson(i))
                .toList();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar historial')),
        );
      }
    }
  }

  Future<void> _iniciarProceso() async {
    try {
      final url = Uri.parse('$baseUrl/produccion/iniciar');
      final payload = {
        'leche_ingresada':
            double.tryParse(_controladoresInicio['leche']!.text) ?? 0,
        'vainilla_ingresada':
            double.tryParse(_controladoresInicio['vainilla']!.text) ?? 0,
        'chocolate_ingresada':
            double.tryParse(_controladoresInicio['chocolate']!.text) ?? 0,
        'fresa_ingresada':
            double.tryParse(_controladoresInicio['fresa']!.text) ?? 0,
        'menta_ingresada':
            double.tryParse(_controladoresInicio['menta']!.text) ?? 0,
      };

      print('Enviando payload: ${jsonEncode(payload)}'); // Para debug

      final response = await http.post(
        url,
        headers: _authHeaders(),
        body: jsonEncode(payload),
      );

      print(
        'Respuesta: ${response.statusCode} - ${response.body}',
      ); // Para debug

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _insumosIngresados = {
            'vainilla':
                double.tryParse(_controladoresInicio['vainilla']!.text) ?? 0,
            'chocolate':
                double.tryParse(_controladoresInicio['chocolate']!.text) ?? 0,
            'fresa': double.tryParse(_controladoresInicio['fresa']!.text) ?? 0,
            'menta': double.tryParse(_controladoresInicio['menta']!.text) ?? 0,
          };
          _resultadosPosibles = {
            'vainilla': data['unidades_vainilla'] ?? 0,
            'chocolate': data['unidades_chocolate'] ?? 0,
            'fresa': data['unidades_fresa'] ?? 0,
            'menta': data['unidades_menta'] ?? 0,
          };
          _procesoActivo = true;
        });
        await _cargarDatos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proceso iniciado correctamente')),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${errorData['detail'] ?? 'Error al iniciar el proceso'}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _finalizarProceso() async {
    final unidades = {
      'unidades_vainilla':
          int.tryParse(_controladoresFinalizacion['vainilla']!.text) ?? 0,
      'unidades_chocolate':
          int.tryParse(_controladoresFinalizacion['chocolate']!.text) ?? 0,
      'unidades_fresa':
          int.tryParse(_controladoresFinalizacion['fresa']!.text) ?? 0,
      'unidades_menta':
          int.tryParse(_controladoresFinalizacion['menta']!.text) ?? 0,
    };

    final url = Uri.parse('$baseUrl/produccion/finalizar/$_procesoId');
    final response = await http.post(
      url,
      headers: _authHeaders(),
      body: jsonEncode(unidades),
    );

    if (response.statusCode == 200) {
      setState(() => _procesoActivo = false);
      await _cargarDatos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proceso finalizado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al finalizar el proceso')),
      );
    }
  }

  Future<void> _mostrarDialogoInicio() async {
    // Limpiar controladores
    _controladoresInicio.values.forEach((c) => c.clear());

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ingreso de Insumos'),
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._controladoresInicio.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: e.value,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Helados ${e.key.capitalize()} (Kg)',
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                isDark ? Colors.grey[600]! : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                        fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                        filled: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _iniciarProceso();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Ingresar datos'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDialogoFinalizacion() async {
    // Limpiar controladores
    _controladoresFinalizacion.values.forEach((c) => c.clear());

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cantidad de Helados Obtenidos'),
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._controladoresFinalizacion.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: e.value,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Helados ${e.key.capitalize()} (unidades)',
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                isDark ? Colors.grey[600]! : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                        fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                        filled: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _finalizarProceso();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Finalizar proceso'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Proceso de Helados')),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Insumos Disponibles Card
            HorizontalItemsCard(
              title: 'Insumos Disponibles',
              backgroundColor: isDark ? Colors.grey[850] : Colors.white,
              items: [
                CardItem(
                  title: 'Leche',
                  value: '${_insumos?.leche ?? 0.0} L',
                  icon: Icons.water_drop,
                  color: Colors.blue,
                ),
                CardItem(
                  title: 'Vainilla',
                  value: '${_insumos?.vainilla ?? 0.0} Kg',
                  icon: Icons.cookie,
                  color: Colors.amber,
                ),
                CardItem(
                  title: 'Chocolate',
                  value: '${_insumos?.chocolate ?? 0.0} Kg',
                  icon: Icons.bakery_dining,
                  color: Colors.brown,
                ),
                CardItem(
                  title: 'Fresa',
                  value: '${_insumos?.fresa ?? 0.0} Kg',
                  icon: Icons.icecream,
                  color: Colors.red,
                ),
                CardItem(
                  title: 'Menta',
                  value: '${_insumos?.menta ?? 0.0} Kg',
                  icon: Icons.grass,
                  color: Colors.green,
                ),
              ],
            ),
            UIHelpers.vSpaceMedium,

            // Insumos Ingresados Card
            HorizontalItemsCard(
              title: 'Insumos Ingresados',
              backgroundColor: isDark ? Colors.grey[850] : Colors.white,
              items: [
                CardItem(
                  title: 'Vainilla',
                  value: '${_insumosIngresados['vainilla']} Kg',
                  icon: Icons.cookie,
                  color: Colors.amber,
                ),
                CardItem(
                  title: 'Chocolate',
                  value: '${_insumosIngresados['chocolate']} Kg',
                  icon: Icons.bakery_dining,
                  color: Colors.brown,
                ),
                CardItem(
                  title: 'Fresa',
                  value: '${_insumosIngresados['fresa']} Kg',
                  icon: Icons.icecream,
                  color: Colors.red,
                ),
                CardItem(
                  title: 'Menta',
                  value: '${_insumosIngresados['menta']} Kg',
                  icon: Icons.grass,
                  color: Colors.green,
                ),
              ],
            ),
            UIHelpers.vSpaceMedium,

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: !_procesoActivo ? _mostrarDialogoInicio : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar Proceso'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      _procesoActivo ? _mostrarDialogoFinalizacion : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Finalizar Proceso'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            UIHelpers.vSpaceMedium,

            // Resultados Posibles Card
            HorizontalItemsCard(
              title: 'Resultados Posibles',
              backgroundColor: isDark ? Colors.grey[850] : Colors.white,
              items:
                  _resultadosPosibles.isEmpty
                      ? [
                        CardItem(
                          title: 'Sin cálculos',
                          value: 'Inicie un proceso',
                          icon: Icons.calculate,
                          color: Colors.grey,
                        ),
                      ]
                      : [
                        CardItem(
                          title: 'Vainilla',
                          value: '${_resultadosPosibles['vainilla']} unid.',
                          icon: Icons.cookie,
                          color: Colors.amber,
                        ),
                        CardItem(
                          title: 'Chocolate',
                          value: '${_resultadosPosibles['chocolate']} unid.',
                          icon: Icons.bakery_dining,
                          color: Colors.brown,
                        ),
                        CardItem(
                          title: 'Fresa',
                          value: '${_resultadosPosibles['fresa']} unid.',
                          icon: Icons.icecream,
                          color: Colors.red,
                        ),
                        CardItem(
                          title: 'Menta',
                          value: '${_resultadosPosibles['menta']} unid.',
                          icon: Icons.grass,
                          color: Colors.green,
                        ),
                      ],
            ),
            UIHelpers.vSpaceMedium,

            // Último Proceso Card
            if (_ultimo != null)
              HorizontalItemsCard(
                title: 'Último Proceso',
                backgroundColor: isDark ? Colors.grey[850] : Colors.white,
                items: [
                  CardItem(
                    title: 'Fecha',
                    value: _ultimo!.fecha.toString(),
                    icon: Icons.calendar_today,
                    color: Colors.blue,
                  ),
                  CardItem(
                    title: 'Estado',
                    value: _ultimo!.finalizado ? 'Finalizado' : 'En Proceso',
                    icon:
                        _ultimo!.finalizado
                            ? Icons.check_circle
                            : Icons.pending,
                    color: _ultimo!.finalizado ? Colors.green : Colors.orange,
                  ),
                  CardItem(
                    title: 'Responsable',
                    value: _ultimo!.responsable,
                    icon: Icons.person,
                    color: Colors.purple,
                  ),
                ],
              ),
            UIHelpers.vSpaceMedium,

            // Historial como texto para no sobrecargar la vista
            Card(
              color: isDark ? Colors.grey[850] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historial',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    UIHelpers.vSpaceMedium,
                    ..._historial.map(
                      (proceso) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              proceso.finalizado
                                  ? Icons.check_circle
                                  : Icons.pending,
                              color:
                                  proceso.finalizado
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                            UIHelpers.hSpaceSmall,
                            Expanded(
                              child: Text(
                                'Proceso #${proceso.id} - ${proceso.fecha.toString()}\n${proceso.responsable}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class HorizontalItemsCard extends StatelessWidget {
  final String title;
  final List<CardItem> items;
  final Color? backgroundColor;

  const HorizontalItemsCard({
    Key? key,
    required this.title,
    required this.items,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIHelpers.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            UIHelpers.vSpaceMedium,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: items.map((item) => _buildItem(item)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(CardItem item) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: item.color.withOpacity(0.2),
            child: Icon(item.icon, color: item.color),
          ),
          UIHelpers.vSpaceSmall,
          Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          UIHelpers.vSpaceTiny,
          Text(
            item.value,
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CardItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const CardItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
