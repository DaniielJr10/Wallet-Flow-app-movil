import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase/servicios/DeudaService/deudas_servicio.dart';
import '../../../firebase/servicios/CuentaService/cuentas_servicio.dart';

// Importación de funcionalidades modularizadas
import 'funcionalidades/app_bar_deudas.dart';
import 'funcionalidades/resumen_deudas.dart';
import 'funcionalidades/filtros_deudas.dart';
import 'funcionalidades/lista_deudas_builder.dart';
import 'funcionalidades/estados_deudas.dart';
import 'funcionalidades/formulario_deuda.dart';
import 'funcionalidades/detalle_deuda.dart';
import 'funcionalidades/dialogos_deudas.dart';
import 'funcionalidades/modal_filtros_deudas.dart';

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
  String _modoBusqueda = 'categorÃ­a';
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
      // ConversiÃ³n de timestamps
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
    // ya no se calculan el promedio de dÃ­as a vencimiento ni el pago mÃ­nimo global

    final filtradas = _obtenerDeudasFiltradas();

    for (var deuda in filtradas) {
      _totalDeudaPendiente += deuda['montoPendiente'];
      
      if (deuda['estado'] == 'Pendiente') _deudasPorPagar++;
      if (deuda['estado'] == 'Pagada') _deudasPagadas++;
      
      
    }
    // El promedio de vencimiento ya no se muestra en el resumen principal.
  }

  String _obtenerNombreMes(int mes) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return mes >= 1 && mes <= 12 ? meses[mes - 1] : '';
  }

  List<Map<String, dynamic>> _obtenerDeudasFiltradas() {
    var lista = List<Map<String, dynamic>>.from(_deudas);
    
    if (_textoBusqueda.isNotEmpty) {
      final q = _textoBusqueda.toLowerCase();
      
      if (_modoBusqueda == 'categorÃ­a') {
        // Buscar por categorÃ­a (tipo, tÃ­tulo, acreedor)
        lista = lista.where((d) {
          final titulo = (d['titulo'] ?? '').toString().toLowerCase();
          final tipo = (d['tipo'] ?? '').toString().toLowerCase();
          final acreedor = (d['acreedor'] ?? '').toString().toLowerCase();
          return titulo.contains(q) || tipo.contains(q) || acreedor.contains(q);
        }).toList();
      } else if (_modoBusqueda == 'mes') {
        // Buscar por mes/aÃ±o (formato: "enero 2024", "01/2024", "enero", etc.)
        lista = lista.where((d) {
          final fechaVenc = d['fechaVencimiento'] as DateTime?;
          final fechaCreacion = d['fechaCreacion'] as DateTime?;
          
          if (fechaVenc != null) {
            final mesNombre = _obtenerNombreMes(fechaVenc.month).toLowerCase();
            final anio = fechaVenc.year.toString();
            final mesNumero = fechaVenc.month.toString().padLeft(2, '0');
            
            // Buscar por nombre de mes, numero de mes, anio, o combinacion
            if (mesNombre.contains(q) || 
                anio.contains(q) || 
                mesNumero.contains(q) ||
                '$mesNombre $anio'.contains(q) ||
                '$mesNumero/$anio'.contains(q)) {
              return true;
            }
          }
          
          if (fechaCreacion != null) {
            final mesNombre = _obtenerNombreMes(fechaCreacion.month).toLowerCase();
            final anio = fechaCreacion.year.toString();
            final mesNumero = fechaCreacion.month.toString().padLeft(2, '0');
            
            if (mesNombre.contains(q) || 
                anio.contains(q) || 
                mesNumero.contains(q) ||
                '$mesNombre $anio'.contains(q) ||
                '$mesNumero/$anio'.contains(q)) {
              return true;
            }
          }
          
          return false;
        }).toList();
      }
    }

    switch (_filtroSeleccionado) {
      case 'Pendientes': lista = lista.where((d) => d['estado'] == 'Pendiente').toList(); break;
      case 'Pagadas': lista = lista.where((d) => d['estado'] == 'Pagada').toList(); break;
      case 'PrÃ³ximas a Vencer':
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
      case 'AlfabÃ©tico': lista.sort((a, b) => a['titulo'].compareTo(b['titulo'])); break;
      case 'Fecha CreaciÃ³n': lista.sort((a, b) => b['fechaCreacion'].compareTo(a['fechaCreacion'])); break;
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
                        modoBusqueda: _modoBusqueda,
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
    ModalFiltrosBusquedaDeudas.mostrar(
      context: context,
      filterButtonKey: _filterButtonKey,
      modoBusquedaActual: _modoBusqueda,
      onModoCambiado: (nuevoModo) {
        setState(() => _modoBusqueda = nuevoModo);
      },
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

  void _mostrarDialogoPago(Map<String, dynamic> deuda) async {
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => DialogoPagoDeuda(
        deuda: deuda,
        onPagoRegistrado: () {},
      ),
    );

    if (resultado == null) return;

    final pago = resultado['monto'] as double;
    final cuentaId = resultado['cuentaId'] as String;

    setState(() { _estaCargando = true; });
    try {
      // Verificar cuenta y saldo
      final cuentaDoc = await _cuentasServicio.obtenerCuentaPorId(cuentaId);
      if (cuentaDoc == null) {
        _mostrarMensaje('Cuenta no encontrada', esError: true);
        return;
      }
      final cuentaData = cuentaDoc.data() as Map<String, dynamic>;
      final saldoActual = (cuentaData['saldo'] ?? 0).toDouble();

      // No permitir pagar mÃ¡s que la deuda: ajustar pago al pendiente
      final montoPend = (deuda['montoPendiente'] ?? 0).toDouble();
      final pagoFinal = pago > montoPend ? montoPend : pago;

      if (pagoFinal > saldoActual) {
        _mostrarMensaje('Saldo insuficiente en la cuenta seleccionada', esError: true);
        return;
      }

      // Actualizar saldo de la cuenta con el pagoFinal
      final nuevoSaldoCuenta = saldoActual - pagoFinal;
      final cuentaError = await _cuentasServicio.actualizarSaldo(cuentaId: cuentaId, nuevoSaldo: nuevoSaldoCuenta);
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
      historial.add({'monto': pago, 'fecha': DateTime.now(), 'cuenta': cuentaId});

      await _deudasServicio.editarDeuda(deuda['id'], {
        'montoPendiente': nuevoPend,
        'estado': nuevoEstado,
        'historialPagos': historial,
      });

      _cargarDeudas();
      _mostrarMensaje('Pago registrado', esError: false);
    } catch (e) {
      debugPrint('Error al registrar pago: $e');
      _mostrarMensaje('Error al registrar el pago', esError: true);
    } finally {
      setState(() { _estaCargando = false; });
    }
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
