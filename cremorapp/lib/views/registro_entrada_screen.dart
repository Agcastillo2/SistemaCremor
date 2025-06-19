import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../services/asistencia_service.dart';
import '../controllers/current_user_controller.dart';
import '../widgets/app_drawer.dart';
import '../utils/icons.dart';
import '../utils/drawer_items_helper.dart';

class RegistroEntradaScreen extends StatefulWidget {
  final int idPersona;
  final String nombres;
  final String apellidos;
  final String rol;
  final int idRol;

  const RegistroEntradaScreen({
    Key? key,
    required this.idPersona,
    required this.nombres,
    required this.apellidos,
    required this.rol,
    required this.idRol,
  }) : super(key: key);

  @override
  State<RegistroEntradaScreen> createState() => _RegistroEntradaScreenState();
}

class _RegistroEntradaScreenState extends State<RegistroEntradaScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _puestos = [];
  List<Map<String, dynamic>> _historialRegistros = [];
  bool _isLoadingPuestos = true;
  bool _isLoadingHistorial = true;
  bool _isSubmitting = false;
  Map<String, String> _puestosMap = {}; // Para el dropdown

  final List<String> _turnos = ['MAÑANA', 'TARDE', 'NOCHE'];
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

  Future<void> _cargarPuestos() async {
    setState(() {
      _isLoadingPuestos = true;
    });

    try {
      print('🔄 Iniciando carga de puestos...');
      final conexionExitosa = await AsistenciaService.probarConexion();

      if (!conexionExitosa) {
        throw Exception('No se pudo conectar al servidor');
      }

      print('✅ Conexión exitosa, obteniendo puestos...');
      final puestos = await AsistenciaService.obtenerPuestos();
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar puestos: $e')));
      }
      setState(() {
        _isLoadingPuestos = false;
      });
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
        // Recargar el historial en lugar de salir
        await _cargarHistorial();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar entrada: $e')),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
  // Los selectores están ahora directamente en el método build

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

        // Calcular tiempo trabajado
        String tiempoTrabajado = '';
        if (salida != null) {
          final diferencia = salida.difference(entrada);
          final horas = diferencia.inHours;
          final minutos = diferencia.inMinutes.remainder(60);
          tiempoTrabajado = '$horas horas y $minutos minutos';
        }

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
                if (salida != null) ...[
                  Text(
                    'Salida: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(salida)}',
                  ),
                  Text(
                    'Tiempo trabajado: $tiempoTrabajado',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ] else
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

  // Lista de items base para el drawer
  List<DrawerItem> get baseItems => [
    DrawerItem(
      titleKey: 'dashboard',
      icon: AppIcons.home,
      route: widget.rol.contains('NATA') ? '/jefe-nata' : '/jefe-helados',
    ),
    DrawerItem(titleKey: 'profile', icon: AppIcons.profile, route: '/profile'),
    DrawerItem(
      titleKey: 'processes',
      icon: AppIcons.assignments,
      route: '/procesos',
    ),
    DrawerItem(titleKey: 'logout', icon: AppIcons.logout, route: '/login'),
  ];

  // Lista completa de items para el drawer
  List<DrawerItem> get drawerItems => insertRegisterItems(
    baseItems,
    context,
    CurrentUserController.currentUser!,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentRoute: '/registro-entrada', items: drawerItems),
      appBar: AppBar(
        title: const Text('Registro de Entrada'),
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

// Se eliminó el widget _HoraActualWidget ya que el reloj está implementado directamente en el build
