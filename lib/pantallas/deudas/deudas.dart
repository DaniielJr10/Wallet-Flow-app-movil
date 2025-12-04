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
        builder: (context, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con gradiente
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.payment,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Registrar pago',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Contenido
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Saldo pendiente destacado
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF97316).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Color(0xFFF97316),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Saldo pendiente',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${FormatoNumeros.formatearParaMostrar(deuda['montoPendiente'] ?? 0)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Selector de cuentas
                      StreamBuilder<QuerySnapshot>(
                        stream: _cuentasServicio.obtenerCuentas(),
                        builder: (context, snapshot) {
                          final items = <DropdownMenuItem<String>>[];
                          items.add(const DropdownMenuItem(
                            value: 'ninguna',
                            child: Text('Selecciona una cuenta'),
                          ));
                          if (snapshot.hasData) {
                            for (var doc in snapshot.data!.docs) {
                              final data = doc.data() as Map<String, dynamic>;
                              if (data['activa'] == true) {
                                final label = data['tipo'] == 'dinero_en_mano'
                                    ? (data['alias'] ?? 'Dinero en mano')
                                    : '${data['banco'] ?? ''} - ${data['numeroCuenta'] ?? ''}';
                                items.add(DropdownMenuItem(
                                  value: doc.id,
                                  child: Text(label),
                                ));
                              }
                            }
                          }

                          // mostrar saldo disponible de la cuenta seleccionada
                          String? saldoCuentaTexto;
                          if (snapshot.hasData && _cuentaSeleccionada != 'ninguna') {
                            try {
                              final doc = snapshot.data!.docs.firstWhere(
                                (d) => d.id == _cuentaSeleccionada,
                              );
                              final data = doc.data() as Map<String, dynamic>;
                              saldoCuentaTexto = FormatoNumeros.formatearParaMostrar(
                                (data['saldo'] ?? 0).toDouble(),
                              );
                            } catch (_) {
                              saldoCuentaTexto = null;
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cuenta desde la que pagar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: items.any((i) => i.value == _cuentaSeleccionada)
                                      ? _cuentaSeleccionada
                                      : 'ninguna',
                                  items: items,
                                  onChanged: (v) => setStateDialog(
                                    () => _cuentaSeleccionada = v ?? 'ninguna',
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down),
                                ),
                              ),
                              if (saldoCuentaTexto != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Saldo disponible: \$$saldoCuentaTexto',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Campo de monto
                      const Text(
                        'Monto a pagar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _montoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFF97316)),
                          hintText: '0.00',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFF97316),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
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
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text(
                                'Confirmar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF97316),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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