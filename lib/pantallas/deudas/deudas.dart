import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase/servicios/DeudaService/deudas_servicio.dart';
import '../../../firebase/servicios/CuentaService/cuentas_servicio.dart';
import '../../utilidades/formato_numeros.dart';

// Importación de funcionalidades modularizadas
import 'funcionalidades/app_bar_deudas.dart';
import 'funcionalidades/resumen_deudas.dart';
import 'funcionalidades/filtros_deudas.dart';
import 'funcionalidades/lista_deudas_builder.dart';
import 'funcionalidades/estados_deudas.dart';
import 'funcionalidades/formulario_deuda.dart';
import 'funcionalidades/detalle_deuda.dart';
import 'funcionalidades/dialogos_deudas.dart';
import 'funcionalidades/utils_deudas.dart';

class PantallaDeudas extends StatefulWidget {
  const PantallaDeudas({super.key});

  @override
  State<PantallaDeudas> createState() => _PantallaDeudasState();
}

class _PantallaDeudasState extends State<PantallaDeudas> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final DeudasServicio _deudasServicio = DeudasServicio();
  final CuentasServicio _cuentasServicio = CuentasServicio();
  final GlobalKey _filterButtonKey = GlobalKey();

  List<Map<String, dynamic>> _deudas = [];
  bool _estaCargando = false;
  String _textoBusqueda = '';
  String _modoBusqueda = 'categoría';
  String _filtroSeleccionado = 'Todas';
  String _ordenSeleccionado = 'Vencimiento';

  double _totalDeudaPendiente = 0.0;
  int _deudasPorPagar = 0;
  int _deudasPagadas = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _cargarDeudas();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _cardController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic)),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  Future<void> _cargarDeudas() async {
    setState(() { _estaCargando = true; });
    try {
      final deudas = await _deudasServicio.obtenerDeudas();
      // Conversión de timestamps
      _deudas = deudas.map((d) {
        if (d['fechaVencimiento'] is Timestamp) {
          d['fechaVencimiento'] = (d['fechaVencimiento'] as Timestamp).toDate();
        }
        if (d['fechaCreacion'] is Timestamp) {
          d['fechaCreacion'] = (d['fechaCreacion'] as Timestamp).toDate();
        }
        if (d['historialPagos'] != null) {
          d['historialPagos'] = List<Map<String, dynamic>>.from((d['historialPagos'] as List).map((p) {
            if (p['fecha'] is Timestamp) {
              p['fecha'] = (p['fecha'] as Timestamp).toDate();
            }
            return p;
          }));
        }
        return d;
      }).toList();
      
      _calcularEstadisticas();
      _cardController.forward();
    } catch (e) {
      debugPrint('Error al cargar deudas: $e');
      _mostrarMensaje('Error al cargar las deudas', esError: true);
    } finally {
      setState(() { _estaCargando = false; });
    }
  }

  void _calcularEstadisticas() {
    _totalDeudaPendiente = 0.0;
    _deudasPorPagar = 0;
    _deudasPagadas = 0;
    // ya no se calculan el promedio de días a vencimiento ni el pago mínimo global

    final filtradas = _obtenerDeudasFiltradas();

    for (var deuda in filtradas) {
      _totalDeudaPendiente += deuda['montoPendiente'];
      
      if (deuda['estado'] == 'Pendiente') _deudasPorPagar++;
      if (deuda['estado'] == 'Pagada') _deudasPagadas++;
      
      
    }
    // El promedio de vencimiento ya no se muestra en el resumen principal.
  }

  List<Map<String, dynamic>> _obtenerDeudasFiltradas() {
    var lista = List<Map<String, dynamic>>.from(_deudas);
    
    if (_textoBusqueda.isNotEmpty) {
      final q = _textoBusqueda.toLowerCase();
      lista = lista.where((d) {
        final titulo = (d['titulo'] ?? '').toString().toLowerCase();
        final tipo = (d['tipo'] ?? '').toString().toLowerCase();
        final acreedor = (d['acreedor'] ?? '').toString().toLowerCase();
        return titulo.contains(q) || tipo.contains(q) || acreedor.contains(q);
      }).toList();
    }

    switch (_filtroSeleccionado) {
      case 'Pendientes': lista = lista.where((d) => d['estado'] == 'Pendiente').toList(); break;
      case 'Pagadas': lista = lista.where((d) => d['estado'] == 'Pagada').toList(); break;
      case 'Próximas a Vencer':
        lista = lista.where((d) {
          if (d['fechaVencimiento'] == null) return false;
          final dias = d['fechaVencimiento'].difference(DateTime.now()).inDays;
          return dias >= 0 && dias <= 7;
        }).toList();
        break;
    }

    switch (_ordenSeleccionado) {
      case 'Vencimiento':
        lista.sort((a, b) {
          if (a['fechaVencimiento'] == null) return 1;
          if (b['fechaVencimiento'] == null) return -1;
          return a['fechaVencimiento'].compareTo(b['fechaVencimiento']);
        });
        break;
      case 'Monto Mayor': lista.sort((a, b) => b['montoPendiente'].compareTo(a['montoPendiente'])); break;
      case 'Monto Menor': lista.sort((a, b) => a['montoPendiente'].compareTo(b['montoPendiente'])); break;
      case 'Alfabético': lista.sort((a, b) => a['titulo'].compareTo(b['titulo'])); break;
      case 'Fecha Creación': lista.sort((a, b) => b['fechaCreacion'].compareTo(a['fechaCreacion'])); break;
    }
    return lista;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deudasFiltradas = _obtenerDeudasFiltradas();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: const AppBarDeudas(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _estaCargando
              ? const EstadoCargandoDeudas()
              : Column(
                  children: [
                    ResumenDeudas(
                      totalDeudaPendiente: _totalDeudaPendiente,
                      deudasPorPagar: _deudasPorPagar,
                      deudasPagadas: _deudasPagadas,
                      totalDeudas: deudasFiltradas.length,
                      scaleAnimation: _scaleAnimation,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FiltrosYOrdenDeudas(
                        filterButtonKey: _filterButtonKey,
                        onSearchChanged: (v) => setState(() {
                          _textoBusqueda = v;
                          _calcularEstadisticas();
                        }),
                        onFilterPressed: _mostrarModalFiltro,
                        onNuevaDeudaPressed: () => _mostrarFormulario(esEdicion: false),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListaDeudasBuilder(
                          deudas: deudasFiltradas,
                          filtroSeleccionado: _filtroSeleccionado,
                          onTapDeuda: _mostrarDetalles,
                          onPagar: _mostrarDialogoPago,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _mostrarModalFiltro() {
    final keyContext = _filterButtonKey.currentContext;
    if (keyContext == null) return;
    final renderBox = keyContext.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Tap fuera del modal para cerrar
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Modal posicionado cerca del botón
            Positioned(
              top: offset.dy + size.height - 50,
              right: MediaQuery.of(context).size.width - offset.dx - size.width,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: UtilsDeudas.colorPrincipal.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        const Row(
                          children: [
                            Icon(Icons.filter_list, color: UtilsDeudas.colorPrincipal, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Modo de búsqueda',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: UtilsDeudas.colorPrincipal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Opción: Por categoría
                        _buildOpcionFiltro(
                          icon: Icons.category_outlined,
                          texto: 'Por categoría',
                          seleccionado: _modoBusqueda == 'categoría',
                          onTap: () {
                            setState(() => _modoBusqueda = 'categoría');
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 12),
                        // Opción: Por mes
                        _buildOpcionFiltro(
                          icon: Icons.calendar_today_outlined,
                          texto: 'Por mes',
                          seleccionado: _modoBusqueda == 'mes',
                          onTap: () {
                            setState(() => _modoBusqueda = 'mes');
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOpcionFiltro({
    required IconData icon,
    required String texto,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: seleccionado ? UtilsDeudas.colorPrincipal.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: seleccionado ? UtilsDeudas.colorPrincipal : Colors.grey[700],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
                  color: seleccionado ? UtilsDeudas.colorPrincipal : Colors.grey[800],
                ),
              ),
            ),
            if (seleccionado)
              const Icon(
                Icons.check_circle,
                color: UtilsDeudas.colorPrincipal,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarFormulario({required bool esEdicion, Map<String, dynamic>? deuda}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FormularioDeuda(
        esEdicion: esEdicion,
        deudaExistente: deuda,
        onGuardar: () {
          _cargarDeudas();
          _mostrarMensaje(esEdicion ? 'Deuda actualizada' : 'Deuda creada', esError: false);
        },
      ),
    );
  }

  void _mostrarDetalles(Map<String, dynamic> deuda) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => DetalleHistorialDeuda(
          deuda: deuda,
          onEditar: () => _mostrarFormulario(esEdicion: true, deuda: deuda),
          onEliminar: () => _confirmarEliminar(deuda),
        ),
      ),
    );
  }

  void _confirmarEliminar(Map<String, dynamic> deuda) {
    showDialog(
      context: context,
      builder: (context) => DialogoConfirmarEliminarDeuda(
        tituloDeuda: deuda['titulo'],
        onConfirmar: () async {
          await _deudasServicio.eliminarDeuda(deuda['id']);
          _cargarDeudas();
          _mostrarMensaje('Deuda eliminada', esError: false);
        },
      ),
    );
  }

  void _mostrarDialogoPago(Map<String, dynamic> deuda) {
    final TextEditingController _montoCtrl = TextEditingController();

    String _cuentaSeleccionada = 'ninguna';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.only(top: 18, bottom: 8),
          title: Center(
            child: Text('Registrar pago', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Saldo pendiente: ${FormatoNumeros.formatearParaMostrar(deuda['montoPendiente'] ?? 0)}', style: const TextStyle(fontWeight: FontWeight.w600))),
              const SizedBox(height: 12),
              // Selector de cuentas
              StreamBuilder<QuerySnapshot>(
                stream: _cuentasServicio.obtenerCuentas(),
                builder: (context, snapshot) {
                  final items = <DropdownMenuItem<String>>[];
                  items.add(const DropdownMenuItem(value: 'ninguna', child: Text('Selecciona una cuenta')));
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['activa'] == true) {
                        final label = data['tipo'] == 'dinero_en_mano'
                            ? (data['alias'] ?? 'Dinero en mano')
                            : '${data['banco'] ?? ''} - ${data['numeroCuenta'] ?? ''}';
                        items.add(DropdownMenuItem(value: doc.id, child: Text(label)));
                      }
                    }
                  }

                  // mostrar saldo disponible de la cuenta seleccionada
                  String? saldoCuentaTexto;
                  if (snapshot.hasData && _cuentaSeleccionada != 'ninguna') {
                    try {
                      final doc = snapshot.data!.docs.firstWhere((d) => d.id == _cuentaSeleccionada);
                      final data = doc.data() as Map<String, dynamic>;
                      saldoCuentaTexto = FormatoNumeros.formatearParaMostrar((data['saldo'] ?? 0).toDouble());
                    } catch (_) {
                      saldoCuentaTexto = null;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: items.any((i) => i.value == _cuentaSeleccionada) ? _cuentaSeleccionada : 'ninguna',
                        items: items,
                        onChanged: (v) => setStateDialog(() => _cuentaSeleccionada = v ?? 'ninguna'),
                        decoration: const InputDecoration(labelText: 'Cuenta desde la que pagar'),
                      ),
                      if (saldoCuentaTexto != null) ...[
                        const SizedBox(height: 6),
                        Text('Saldo disponible: $saldoCuentaTexto', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monto a pagar',
                  prefixText: '\$',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: TextStyle(color: Colors.purple[700])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: UtilsDeudas.colorPrincipal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                elevation: 4,
              ),
              onPressed: () async {
                final raw = _montoCtrl.text.replaceAll(',', '.').replaceAll('\$', '').trim();
                final pago = double.tryParse(raw) ?? 0.0;
                if (pago <= 0) {
                  _mostrarMensaje('Ingresa un monto válido', esError: true);
                  return;
                }
                if (_cuentaSeleccionada == 'ninguna') {
                  _mostrarMensaje('Selecciona una cuenta para pagar', esError: true);
                  return;
                }

                Navigator.of(context).pop();
                setState(() { _estaCargando = true; });
                try {
                  // Verificar cuenta y saldo
                  final cuentaDoc = await _cuentasServicio.obtenerCuentaPorId(_cuentaSeleccionada);
                  if (cuentaDoc == null) {
                    _mostrarMensaje('Cuenta no encontrada', esError: true);
                    return;
                  }
                  final cuentaData = cuentaDoc.data() as Map<String, dynamic>;
                  final saldoActual = (cuentaData['saldo'] ?? 0).toDouble();

                  // No permitir pagar más que la deuda: ajustar pago al pendiente
                  final montoPend = (deuda['montoPendiente'] ?? 0).toDouble();
                  final pagoFinal = pago > montoPend ? montoPend : pago;

                  if (pagoFinal > saldoActual) {
                    _mostrarMensaje('Saldo insuficiente en la cuenta seleccionada', esError: true);
                    return;
                  }

                  // Actualizar saldo de la cuenta con el pagoFinal
                  final nuevoSaldoCuenta = saldoActual - pagoFinal;
                  final cuentaError = await _cuentasServicio.actualizarSaldo(cuentaId: _cuentaSeleccionada, nuevoSaldo: nuevoSaldoCuenta);
                  if (cuentaError != null) {
                    _mostrarMensaje('Error al actualizar cuenta: $cuentaError', esError: true);
                    return;
                  }

                  // Actualizar deuda
                  double nuevoPend = montoPend - pagoFinal;
                  String nuevoEstado = deuda['estado'] ?? 'Pendiente';
                  if (nuevoPend <= 0) {
                    nuevoPend = 0.0;
                    nuevoEstado = 'Pagada';
                  }

                  final historial = List<Map<String, dynamic>>.from(deuda['historialPagos'] ?? []);
                  historial.add({'monto': pago, 'fecha': DateTime.now(), 'cuenta': _cuentaSeleccionada});

                  await _deudasServicio.editarDeuda(deuda['id'], {
                    'montoPendiente': nuevoPend,
                    'estado': nuevoEstado,
                    'historialPagos': historial,
                  });

                  _cargarDeudas();
                  _mostrarMensaje('Pago registrado', esError: false);
                } catch (e) {
                  _mostrarMensaje('Error al registrar pago', esError: true);
                } finally {
                  setState(() { _estaCargando = false; });
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarMensaje(String mensaje, {required bool esError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : const Color(0xFFF97316),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}