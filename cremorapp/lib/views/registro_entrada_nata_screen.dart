import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../services/asistencia_service.dart';

class RegistroEntradaNataScreen extends StatefulWidget {
  final int idPersona;
  final String nombres;
  final String apellidos;
  final String rol;
  final int idRol;

  const RegistroEntradaNataScreen({
    Key? key,
    required this.idPersona,
    required this.nombres,
    required this.apellidos,
    required this.rol,
    required this.idRol,
  }) : super(key: key);

  @override
  State<RegistroEntradaNataScreen> createState() =>
      _RegistroEntradaNataScreenState();
}

class _RegistroEntradaNataScreenState extends State<RegistroEntradaNataScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _puestos = [];
  List<Map<String, dynamic>> _historialRegistros = [];
  bool _isLoadingPuestos = true;
  bool _isLoadingHistorial = true;
  bool _isSubmitting = false;
  Map<String, String> _puestosMap = {};

  final List<String> _turnos = ['MAÑANA', 'TARDE', 'NOCHE', 'COMPLETO'];
  String? _turnoSeleccionado;
  String? _puestoSeleccionado;

  @override
  void initState() {
    super.initState();
    _probarYCargarPuestos();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _isLoadingHistorial = true;
    });

    try {
      final registros = await AsistenciaService.obtenerHistorialRegistros(
        widget.idPersona,
      );
      if (mounted) {
        setState(() {
          _historialRegistros = registros;
          _isLoadingHistorial = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar historial: $e')),
        );
        setState(() {
          _isLoadingHistorial = false;
        });
      }
    }
  }

  Future<void> _probarYCargarPuestos() async {
    setState(() {
      _isLoadingPuestos = true;
    });

    try {
      // Primero probamos la conexión
      final conexionExitosa = await AsistenciaService.probarConexion();
      if (!conexionExitosa) {
        throw Exception('No se pudo conectar al servidor');
      }

      // Si la conexión es exitosa, cargamos los puestos
      final puestos = await AsistenciaService.obtenerPuestos();
      if (mounted) {
        setState(() {
          _puestos = puestos;
          _puestosMap = Map.fromEntries(
            puestos.map(
              (p) => MapEntry(
                p['id_puesto'].toString(),
                p['descripcion'].toString(),
              ),
            ),
          );
          _isLoadingPuestos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPuestos = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar puestos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _registrarEntrada() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (_puestoSeleccionado == null || _turnoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un puesto y un turno'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AsistenciaService.registrarEntrada(
        idPersona: widget.idPersona,
        idRol: widget.idRol,
        idPuesto: int.parse(_puestoSeleccionado!),
        turno: _turnoSeleccionado!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrada registrada con éxito')),
        );
        // Recargar el historial
        await _cargarHistorial();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar entrada: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildHistorialList() {
    if (_isLoadingHistorial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historialRegistros.isEmpty) {
      return const Center(child: Text('No hay registros de asistencia'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _historialRegistros.length,
      itemBuilder: (context, index) {
        final registro = _historialRegistros[index];
        final entrada = DateTime.parse(registro['fecha_hora_entrada']);
        final salida =
            registro['fecha_hora_salida'] != null
                ? DateTime.parse(registro['fecha_hora_salida'])
                : null;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text('Puesto: ${registro['puesto']['descripcion']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entrada: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(entrada)}',
                ),
                if (salida != null)
                  Text(
                    'Salida: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(salida)}',
                  )
                else
                  const Text(
                    'Salida: Pendiente',
                    style: TextStyle(color: Colors.orange),
                  ),
                Text('Turno: ${registro['turno']}'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Entrada - Nata'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _probarYCargarPuestos();
          await _cargarHistorial();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Reloj
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Hora Actual',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            return Text(
                              DateFormat('HH:mm:ss').format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const Text(
                          'Tu hora de entrada será registrada automáticamente',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Selector de Puesto
                  if (_isLoadingPuestos)
                    const Center(child: CircularProgressIndicator())
                  else
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Puesto',
                        border: OutlineInputBorder(),
                      ),
                      value: _puestoSeleccionado,
                      items:
                          _puestosMap.entries
                              .map(
                                (entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _puestoSeleccionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor selecciona un puesto';
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 20),

                  // Selector de Turno
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Turno',
                      border: OutlineInputBorder(),
                    ),
                    value: _turnoSeleccionado,
                    items:
                        _turnos
                            .map(
                              (turno) => DropdownMenuItem(
                                value: turno,
                                child: Text(turno),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _turnoSeleccionado = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona un turno';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Botón de Registro
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _registrarEntrada,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'REGISTRAR ENTRADA',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(thickness: 1),
                  ),

                  // Título del Historial
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Historial de Registros',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Lista de Historial
                  _buildHistorialList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
