import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/proceso_service.dart';
import '../controllers/current_user_controller.dart';
import 'package:intl/intl.dart';
import '../widgets/app_drawer.dart';

import '../utils/icons.dart';
import '../utils/drawer_items_helper.dart';

class ProcesosScreen extends StatefulWidget {
  const ProcesosScreen({Key? key}) : super(key: key);

  @override
  State<ProcesosScreen> createState() => _ProcesosScreenState();
}

class _ProcesosScreenState extends State<ProcesosScreen> {
  // Lista de items base para el drawer
  List<DrawerItem> get baseItems => [
    DrawerItem(titleKey: 'dashboard', icon: AppIcons.home, route: '/jefe-nata'),
    DrawerItem(titleKey: 'profile', icon: AppIcons.profile, route: '/profile'),
    DrawerItem(
      titleKey: 'processes',
      icon: AppIcons.assignments,
      route: '/procesos',
    ),
    DrawerItem(titleKey: 'logout', icon: AppIcons.logout, route: '/login'),
  ];

  // Lista completa de items para el drawer incluyendo registros
  List<DrawerItem> get drawerItems {
    final currentUser = CurrentUserController.currentUser;
    if (currentUser == null) {
      // Si no hay usuario, redirigir al login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return baseItems;
    }
    return insertRegisterItems(baseItems, context, currentUser);
  }

  int? selectedProcesoX;
  int? selectedProcesoY;
  bool isLoading = false;
  bool procesosCongelados =
      false; // Nueva variable para controlar si los procesos están congelados
  Map<String, dynamic>? ultimoProceso;
  List<Map<String, dynamic>> historialProcesos = [];
  int paginaActual = 1;
  int totalPaginas = 5;

  // Definición de los procesos
  final procesosX = {
    1: 'Ingresar leche al tanque X',
    2: 'Filtrar materia prima X',
    3: 'Extracción inicial de nata X',
    4: 'Homogeneización X',
    5: 'Pasteurización X',
    6: 'Enfriamiento y almacenamiento X',
  };

  final procesosY = {
    1: 'Ingresar leche al tanque Y',
    2: 'Filtrar materia prima Y',
    3: 'Extracción inicial de nata Y',
    4: 'Homogeneización Y',
    5: 'Pasteurización Y',
    6: 'Enfriamiento y almacenamiento Y',
  };

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);
    try {
      final ultimo = await ProcesoService.obtenerUltimoProceso();
      final historial = await ProcesoService.listarProcesos(
        pagina: paginaActual,
      );
      setState(() {
        ultimoProceso = ultimo;
        historialProcesos = historial;
        // Actualizar el estado de congelamiento basado en el último proceso
        procesosCongelados = ultimo['estado'] == 'En progreso';
        // Si no está en progreso, limpiar las selecciones
        if (!procesosCongelados) {
          selectedProcesoX = null;
          selectedProcesoY = null;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<double?> _mostrarDialogoIngresarLeche() async {
    String? lecheIngresada;
    double? resultado;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Ingresar cantidad de leche'),
            content: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Cantidad en litros',
                suffixText: 'L',
              ),
              onChanged: (value) => lecheIngresada = value,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  resultado = null;
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (lecheIngresada == null || lecheIngresada!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingrese una cantidad válida'),
                      ),
                    );
                    return;
                  }
                  resultado = double.parse(lecheIngresada!);
                  Navigator.pop(context);
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
    );

    return resultado;
  }

  Future<void> _mostrarDialogoFinalizarProceso() async {
    String? produccionKg;
    String? lecheSobrante;
    final bool requiereSobrante =
        selectedProcesoX == 6 || selectedProcesoY == 6;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Finalizar proceso'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Producción en kilogramos',
                    suffixText: 'Kg',
                  ),
                  onChanged: (value) => produccionKg = value,
                ),
                if (requiereSobrante) ...[
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Leche sobrante en litros',
                      suffixText: 'L',
                    ),
                    onChanged: (value) => lecheSobrante = value,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (produccionKg == null || produccionKg!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ingrese la producción')),
                    );
                    return;
                  }

                  if (requiereSobrante &&
                      (lecheSobrante == null || lecheSobrante!.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingrese la leche sobrante'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  await _finalizarProceso(
                    double.parse(produccionKg!),
                    lecheSobrante != null ? double.parse(lecheSobrante!) : null,
                  );
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
    );
  }

  // Validar selección de procesos y mostrar mensaje apropiado
  String? _validarSeleccionProcesos() {
    // Verificar si hay un proceso en progreso
    if (ultimoProceso != null && ultimoProceso!['estado'] == 'En progreso') {
      return 'Ya hay un proceso en curso. Debe finalizarlo antes de iniciar uno nuevo.';
    }

    // Validar selección de subprocesos
    if (selectedProcesoX == null && selectedProcesoY == null) {
      return 'Por favor, seleccione los subprocesos para X e Y';
    }
    if (selectedProcesoX == null) {
      return 'Por favor, seleccione un subproceso para X';
    }
    if (selectedProcesoY == null) {
      return 'Por favor, seleccione un subproceso para Y';
    }
    if (selectedProcesoX == selectedProcesoY) {
      return 'No se pueden seleccionar los mismos subprocesos para X e Y';
    }
    return null;
  }

  // Mostrar mensaje de error
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Iniciar proceso with validaciones
  Future<void> _iniciarProceso() async {
    final error = _validarSeleccionProcesos();
    if (error != null) {
      _mostrarError(error);
      return;
    }

    // Validar el orden de los procesos
    final ordenValido = await _validarOrdenProcesos();
    if (!ordenValido) {
      return;
    }

    try {
      // Solo mostrar diálogo de leche si alguno de los procesos es 1
      if (selectedProcesoX == 1 || selectedProcesoY == 1) {
        final lecheIngresada = await _mostrarDialogoIngresarLeche();
        if (lecheIngresada == null) {
          // Usuario canceló el diálogo
          return;
        }
        await _crearProceso(lecheIngresada);
      } else {
        // Si ningún proceso es 1, iniciar con valor por defecto de leche (0)
        await _crearProceso(0);
      }
    } catch (e) {
      _mostrarError('Error al iniciar el proceso: ${e.toString()}');
    }
  }

  Future<void> _crearProceso(double lecheIngresada) async {
    final currentUser = CurrentUserController.currentUser;
    if (currentUser == null) return;

    try {
      await ProcesoService.iniciarProceso(
        idPersona: currentUser.idPersona,
        procesoX: selectedProcesoX!,
        procesoY: selectedProcesoY!,
        lecheIngresada: lecheIngresada,
      );

      setState(() {
        procesosCongelados = true; // Congelar la selección de procesos
      });

      await _cargarDatos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proceso iniciado con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al iniciar proceso: $e')));
      }
    }
  }

  Future<void> _finalizarProceso(
    double produccionKg,
    double? lecheSobrante,
  ) async {
    if (ultimoProceso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay proceso activo para finalizar')),
      );
      return;
    }

    try {
      await ProcesoService.finalizarProceso(
        idProceso: ultimoProceso!['id_proceso'],
        produccionKg: produccionKg,
        lecheSobrante: lecheSobrante,
      );

      setState(() {
        procesosCongelados = false; // Descongelar la selección de procesos
        selectedProcesoX = null; // Limpiar selección
        selectedProcesoY = null; // Limpiar selección
      });

      await _cargarDatos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proceso finalizado con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al finalizar proceso: $e')),
        );
      }
    }
  }

  Widget _buildProcesoCard(
    String titulo,
    Map<int, String> procesos,
    int? selectedProceso,
    Function(int?) onSelect,
  ) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  titulo.contains('X') ? Icons.call_split : Icons.merge_type,
                  color: titulo.contains('X') ? Colors.blue : Colors.green,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
              physics: const NeverScrollableScrollPhysics(),
              children:
                  procesos.entries.map((entry) {
                    final isSelected = selectedProceso == entry.key;
                    return Material(
                      elevation: isSelected ? 4 : 1,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap:
                            procesosCongelados
                                ? null
                                : () => onSelect(entry.key),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color:
                                procesosCongelados
                                    ? (isSelected
                                        ? Colors.grey[200]
                                        : Colors.grey[100])
                                    : isSelected
                                    ? (titulo.contains('X')
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1))
                                    : Colors.grey[50],
                            border: Border.all(
                              color:
                                  procesosCongelados
                                      ? (isSelected
                                          ? Colors.grey
                                          : Colors.grey[300]!)
                                      : isSelected
                                      ? (titulo.contains('X')
                                          ? Colors.blue
                                          : Colors.green)
                                      : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${entry.key}',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            procesosCongelados
                                                ? Colors.grey
                                                : isSelected
                                                ? (titulo.contains('X')
                                                    ? Colors.blue
                                                    : Colors.green)
                                                : Colors.black45,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          entry.value
                                              .replaceAll(' X', '')
                                              .replaceAll(' Y', ''),
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.2,
                                            color:
                                                procesosCongelados
                                                    ? Colors.grey[600]
                                                    : isSelected
                                                    ? Colors.black87
                                                    : Colors.black54,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(
                                    Icons.check_circle,
                                    color:
                                        procesosCongelados
                                            ? Colors.grey
                                            : titulo.contains('X')
                                            ? Colors.blue
                                            : Colors.green,
                                    size: 20,
                                  ),
                                ),
                              if (procesosCongelados)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.grey[400],
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUltimoProcesoCard() {
    if (ultimoProceso == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay registros de procesos'),
        ),
      );
    }

    final fecha = DateTime.parse(ultimoProceso!['fecha']);
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Último Proceso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Proceso X')),
                  DataColumn(label: Text('Proceso Y')),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Responsable')),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text(formatoFecha.format(fecha))),
                      DataCell(Text(ultimoProceso!['proceso_x'].toString())),
                      DataCell(Text(ultimoProceso!['proceso_y'].toString())),
                      DataCell(
                        Text(
                          ultimoProceso!['estado'],
                          style:
                              ultimoProceso!['estado'] == 'En progreso'
                                  ? const TextStyle(fontWeight: FontWeight.bold)
                                  : null,
                        ),
                      ),
                      DataCell(Text(ultimoProceso!['nombre_persona'])),
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

  Widget _buildHistorialTable() {
    if (historialProcesos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay registros en el historial'),
        ),
      );
    }

    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de Procesos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Proceso X')),
                  DataColumn(label: Text('Proceso Y')),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Responsable')),
                ],
                rows:
                    historialProcesos.map((proceso) {
                      final fecha = DateTime.parse(proceso['fecha']);
                      return DataRow(
                        cells: [
                          DataCell(Text(formatoFecha.format(fecha))),
                          DataCell(Text(proceso['proceso_x'].toString())),
                          DataCell(Text(proceso['proceso_y'].toString())),
                          DataCell(
                            Text(
                              proceso['estado'],
                              style:
                                  proceso['estado'] == 'En progreso'
                                      ? const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )
                                      : null,
                            ),
                          ),
                          DataCell(Text(proceso['nombre_persona'])),
                        ],
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed:
                      paginaActual > 1
                          ? () {
                            setState(() {
                              paginaActual--;
                              _cargarDatos();
                            });
                          }
                          : null,
                ),
                Text('Página $paginaActual de $totalPaginas'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed:
                      paginaActual < totalPaginas
                          ? () {
                            setState(() {
                              paginaActual++;
                              _cargarDatos();
                            });
                          }
                          : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBarWithSettings(
    BuildContext context,
    String title,
  ) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Implementar configuración si es necesario
          },
        ),
      ],
    );
  }

  Future<bool> _validarOrdenProcesos() async {
    // Si es el primer proceso (no hay último proceso), permitir solo X=1, Y=1
    if (ultimoProceso == null) {
      if (selectedProcesoX != 1 || selectedProcesoY != 1) {
        _mostrarError('Debe iniciar con los procesos X=1 y Y=1');
        return false;
      }
      return true;
    }

    // Si el último proceso está finalizado, validar la secuencia
    if (ultimoProceso!['estado'] == 'Finalizado') {
      final procesoXAnterior = int.parse(
        ultimoProceso!['proceso_x'].toString(),
      );
      final procesoYAnterior = int.parse(
        ultimoProceso!['proceso_y'].toString(),
      );
      final siguienteXEsperado =
          procesoXAnterior == 6 ? 1 : procesoXAnterior + 1;
      final siguienteYEsperado =
          procesoYAnterior == 6 ? 1 : procesoYAnterior + 1;
      if (selectedProcesoX != siguienteXEsperado ||
          selectedProcesoY != siguienteYEsperado) {
        bool continuar = false;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('¡Advertencia de Secuencia!'),
              content: Text(
                'El orden seleccionado no es el recomendado.\n\n'
                'Después de X=$procesoXAnterior y Y=$procesoYAnterior,\n'
                'se recomienda seleccionar X=$siguienteXEsperado y Y=$siguienteYEsperado.\n\n'
                'Ha seleccionado X=$selectedProcesoX y Y=$selectedProcesoY\n'
                '\nEsta acción podría afectar la calidad del proceso.',
                style: const TextStyle(height: 1.3),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    continuar = false;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    continuar = true;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Sí, continuar de todos modos'),
                ),
              ],
            );
          },
        );
        return continuar;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithSettings(context, 'Procesos'),
      drawer: AppDrawer(items: drawerItems, currentRoute: '/procesos'),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Procesos X e Y
                    _buildProcesoCard(
                      'Proceso X',
                      procesosX,
                      selectedProcesoX,
                      (value) => setState(() => selectedProcesoX = value),
                    ),
                    const SizedBox(height: 16),
                    _buildProcesoCard(
                      'Proceso Y',
                      procesosY,
                      selectedProcesoY,
                      (value) => setState(() => selectedProcesoY = value),
                    ),
                    const SizedBox(height: 24),

                    // Botones de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                ultimoProceso != null &&
                                        ultimoProceso!['estado'] ==
                                            'En progreso'
                                    ? null
                                    : _iniciarProceso,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text(
                              'Iniciar Proceso',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                ultimoProceso != null &&
                                        ultimoProceso!['estado'] ==
                                            'En progreso'
                                    ? _mostrarDialogoFinalizarProceso
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle),
                            label: const Text(
                              'Finalizar Proceso',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Último proceso y historial
                    _buildUltimoProcesoCard(),
                    const SizedBox(height: 24),
                    _buildHistorialTable(),
                  ],
                ),
              ),
    );
  }
}
