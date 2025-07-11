import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/asistencia_service.dart';
import '../widgets/app_drawer.dart';
import '../utils/icons.dart';
import '../utils/drawer_items_helper.dart';
import '../controllers/current_user_controller.dart';

class RegistroSalidaScreen extends StatefulWidget {
  final int idPersona;
  final String nombres;
  final String apellidos;
  final String rol;

  const RegistroSalidaScreen({
    Key? key,
    required this.idPersona,
    required this.nombres,
    required this.apellidos,
    required this.rol,
  }) : super(key: key);

  @override
  State<RegistroSalidaScreen> createState() => _RegistroSalidaScreenState();
}

class _RegistroSalidaScreenState extends State<RegistroSalidaScreen> {
  bool _isLoadingRegistroActivo = true;
  bool _isSubmitting = false;
  bool _isLoadingHistorial = true;
  Map<String, dynamic>? _registroActivoData;
  List<Map<String, dynamic>> _historialRegistros = [];

  @override
  void initState() {
    super.initState();
    _cargarRegistroActivo();
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

  Future<void> _cargarRegistroActivo() async {
    print('🔄 Cargando registro activo...');
    setState(() {
      _isLoadingRegistroActivo = true;
    });
    try {
      final registroActivo = await AsistenciaService.obtenerRegistroActivo(
        widget.idPersona,
      );
      print('✅ Registro activo cargado: $registroActivo');
      if (mounted) {
        setState(() {
          _registroActivoData = registroActivo;
          _isLoadingRegistroActivo = false;
        });
      }
    } catch (e) {
      print('❌ Error al cargar registro activo: $e');
      if (mounted) {
        // Solo mostrar error si no es el caso de "no hay registro activo"
        if (!e.toString().contains('No hay un registro activo')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar información de entrada: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _registroActivoData = null;
          _isLoadingRegistroActivo = false;
        });
      }
    }
  }

  Future<void> _registrarSalida() async {
    if (_registroActivoData == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AsistenciaService.registrarSalida(idPersona: widget.idPersona);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salida registrada con éxito')),
        );
        // Recargar la información
        await _cargarRegistroActivo();
        await _cargarHistorial();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar salida: $e')),
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

  Widget _buildRegistroActivo() {
    if (_isLoadingRegistroActivo) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_registroActivoData == null || _registroActivoData!.isEmpty) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'No hay registro activo de entrada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Primero debes registrar una entrada para poder marcar una salida',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final entrada = DateTime.parse(_registroActivoData!['fecha_hora_entrada']);
    String infoEntrada = DateFormat('dd/MM/yyyy HH:mm:ss').format(entrada);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Registro Activo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.work),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Puesto: ${_registroActivoData!['puesto']['descripcion']}',
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.login),
                      const SizedBox(width: 8),
                      Text(
                        'Entrada: $infoEntrada',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule),
                      const SizedBox(width: 8),
                      Text(
                        'Turno: ${_registroActivoData!['turno']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      drawer: AppDrawer(currentRoute: '/registro-salida', items: drawerItems),
      appBar: AppBar(
        title: const Text('Registro de Salida'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _cargarRegistroActivo();
          await _cargarHistorial();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                        'Tu hora de salida será registrada automáticamente',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Registro Activo
                _buildRegistroActivo(),

                const SizedBox(height: 20),

                // Botón de Registro
                if (_registroActivoData != null)
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _registrarSalida,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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
                                'REGISTRAR SALIDA',
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    );
  }
}
