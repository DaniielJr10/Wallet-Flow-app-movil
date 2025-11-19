import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utilidades/formato_numeros.dart';

/// Pantalla de gestión de deudas en Wallet Flow
/// 
/// Permite al usuario registrar, monitorear y gestionar sus deudas pendientes,
/// con alertas de vencimiento, seguimiento de pagos y análisis de progreso.
/// 
/// Características principales:
/// - Registro y edición de deudas
/// - Seguimiento de pagos realizados
/// - Alertas de vencimiento y recordatorios
/// - Cálculo automático de intereses
/// - Análisis visual del progreso de pago
/// - Categorización de tipos de deuda
class PantallaDeudas extends StatefulWidget {
  const PantallaDeudas({super.key});

  @override
  State<PantallaDeudas> createState() => _PantallaDeudasState();
}

class _PantallaDeudasState extends State<PantallaDeudas>
    with TickerProviderStateMixin {

  // ===== SERVICIOS Y CONTROLADORES =====
  /// Controlador principal de animaciones
  late AnimationController _animationController;
  
  /// Controlador para animaciones de tarjetas
  late AnimationController _cardController;
  
  // Animaciones principales
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // ===== ESTADOS DE LA PANTALLA =====
  /// Indica si los datos están siendo cargados
  bool _estaCargando = true;
  
  /// Lista de todas las deudas del usuario
  List<Map<String, dynamic>> _deudas = [];
  
  /// Filtro de visualización seleccionado
  String _filtroSeleccionado = 'Todas';
  
  /// Orden de visualización de las deudas
  String _ordenSeleccionado = 'Vencimiento';

  // ===== DATOS CALCULADOS =====
  /// Total de deuda pendiente
  double _totalDeudaPendiente = 0.0;
  
  /// Promedio de días para vencimiento
  int _diasPromedioVencimiento = 0;
  
  /// Número de deudas vencidas
  int _deudasVencidas = 0;
  
  /// Pago mínimo mensual requerido
  double _pagoMinimoMensual = 0.0;

  // ===== CONFIGURACIÓN =====
  /// Lista de filtros disponibles
  final List<String> _filtrosDisponibles = [
    'Todas',
    'Pendientes',
    'Vencidas',
    'Próximas a Vencer',
    'Pagadas',
  ];

  /// Lista de opciones de ordenamiento
  final List<String> _opcionesOrden = [
    'Vencimiento',
    'Monto Mayor',
    'Monto Menor',
    'Alfabético',
    'Fecha Creación',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _cargarDeudas();
  }

  /// Inicializa todas las animaciones de la pantalla
  void _initializeAnimations() {
    // Controlador principal
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Controlador para tarjetas
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animación de desvanecimiento
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Animación de deslizamiento
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    // Animación de escala
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  /// Carga todas las deudas del usuario desde la base de datos
  Future<void> _cargarDeudas() async {
    setState(() {
      _estaCargando = true;
    });

    try {
      // TODO: Cargar deudas reales desde Firestore
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Datos de ejemplo - reemplazar con datos reales
      _deudas = [
        {
          'id': '1',
          'titulo': 'Tarjeta de Crédito Principal',
          'tipo': 'Tarjeta de Crédito',
          'montoOriginal': 2500000.0,
          'montoPendiente': 1850000.0,
          'tasaInteres': 24.0,
          'fechaVencimiento': DateTime.now().add(const Duration(days: 15)),
          'pagoMinimo': 185000.0,
          'estado': 'Pendiente',
          'fechaCreacion': DateTime.now().subtract(const Duration(days: 120)),
          'acreedor': 'Banco Nacional',
          'numeroCuenta': '**** 1234',
          'historialPagos': [
            {'fecha': DateTime.now().subtract(const Duration(days: 30)), 'monto': 200000.0},
            {'fecha': DateTime.now().subtract(const Duration(days: 60)), 'monto': 250000.0},
          ],
        },
        {
          'id': '2',
          'titulo': 'Préstamo Personal Urgente',
          'tipo': 'Préstamo Personal',
          'montoOriginal': 5000000.0,
          'montoPendiente': 3200000.0,
          'tasaInteres': 18.5,
          'fechaVencimiento': DateTime.now().subtract(const Duration(days: 5)),
          'pagoMinimo': 320000.0,
          'estado': 'Vencida',
          'fechaCreacion': DateTime.now().subtract(const Duration(days: 180)),
          'acreedor': 'Cooperativa Financiera',
          'numeroCuenta': 'PR-789456',
          'historialPagos': [
            {'fecha': DateTime.now().subtract(const Duration(days: 45)), 'monto': 400000.0},
          ],
        },
        {
          'id': '3',
          'titulo': 'Financiación Vehículo',
          'tipo': 'Préstamo Vehicular',
          'montoOriginal': 25000000.0,
          'montoPendiente': 18500000.0,
          'tasaInteres': 14.2,
          'fechaVencimiento': DateTime.now().add(const Duration(days: 45)),
          'pagoMinimo': 850000.0,
          'estado': 'Pendiente',
          'fechaCreacion': DateTime.now().subtract(const Duration(days: 365)),
          'acreedor': 'Financiera Automotriz',
          'numeroCuenta': 'VH-456789',
          'historialPagos': [
            {'fecha': DateTime.now().subtract(const Duration(days: 30)), 'monto': 850000.0},
            {'fecha': DateTime.now().subtract(const Duration(days: 60)), 'monto': 850000.0},
            {'fecha': DateTime.now().subtract(const Duration(days: 90)), 'monto': 850000.0},
          ],
        },
      ];

      _calcularEstadisticas();
      _cardController.forward();
      
    } catch (e) {
      debugPrint('Error al cargar deudas: $e');
      _mostrarError('Error al cargar las deudas');
    } finally {
      setState(() {
        _estaCargando = false;
      });
    }
  }

  /// Calcula estadísticas generales de las deudas
  void _calcularEstadisticas() {
    _totalDeudaPendiente = 0.0;
    _pagoMinimoMensual = 0.0;
    _deudasVencidas = 0;
    
    int diasTotales = 0;
    int deudasConVencimiento = 0;

    for (var deuda in _deudasFiltradas) {
      // Sumar montos pendientes
      _totalDeudaPendiente += deuda['montoPendiente'];
      _pagoMinimoMensual += deuda['pagoMinimo'];
      
      // Contar deudas vencidas
      if (deuda['estado'] == 'Vencida') {
        _deudasVencidas++;
      }
      
      // Calcular días promedio hasta vencimiento
      if (deuda['fechaVencimiento'] != null && deuda['estado'] != 'Vencida') {
        final diasHastaVencimiento = deuda['fechaVencimiento'].difference(DateTime.now()).inDays as int;
        if (diasHastaVencimiento >= 0) {
          diasTotales += diasHastaVencimiento;
          deudasConVencimiento++;
        }
      }
    }

    _diasPromedioVencimiento = deudasConVencimiento > 0 
        ? (diasTotales / deudasConVencimiento).round() 
        : 0;
  }

  /// Obtiene las deudas filtradas según el filtro seleccionado
  List<Map<String, dynamic>> get _deudasFiltradas {
    var deudasFiltradas = List<Map<String, dynamic>>.from(_deudas);

    // Aplicar filtro
    switch (_filtroSeleccionado) {
      case 'Pendientes':
        deudasFiltradas = deudasFiltradas.where((d) => d['estado'] == 'Pendiente').toList();
        break;
      case 'Vencidas':
        deudasFiltradas = deudasFiltradas.where((d) => d['estado'] == 'Vencida').toList();
        break;
      case 'Próximas a Vencer':
        deudasFiltradas = deudasFiltradas.where((d) {
          if (d['fechaVencimiento'] == null) return false;
          final diasHastaVencimiento = d['fechaVencimiento'].difference(DateTime.now()).inDays;
          return diasHastaVencimiento >= 0 && diasHastaVencimiento <= 7;
        }).toList();
        break;
      case 'Pagadas':
        deudasFiltradas = deudasFiltradas.where((d) => d['estado'] == 'Pagada').toList();
        break;
    }

    // Aplicar orden
    switch (_ordenSeleccionado) {
      case 'Vencimiento':
        deudasFiltradas.sort((a, b) {
          if (a['fechaVencimiento'] == null) return 1;
          if (b['fechaVencimiento'] == null) return -1;
          return a['fechaVencimiento'].compareTo(b['fechaVencimiento']);
        });
        break;
      case 'Monto Mayor':
        deudasFiltradas.sort((a, b) => b['montoPendiente'].compareTo(a['montoPendiente']));
        break;
      case 'Monto Menor':
        deudasFiltradas.sort((a, b) => a['montoPendiente'].compareTo(b['montoPendiente']));
        break;
      case 'Alfabético':
        deudasFiltradas.sort((a, b) => a['titulo'].compareTo(b['titulo']));
        break;
      case 'Fecha Creación':
        deudasFiltradas.sort((a, b) => b['fechaCreacion'].compareTo(a['fechaCreacion']));
        break;
    }

    return deudasFiltradas;
  }

  /// Registra un nuevo pago para una deuda específica
  Future<void> _registrarPago(String deudaId, double montoPago) async {
    try {
      // Buscar la deuda
      final indiceDeuda = _deudas.indexWhere((d) => d['id'] == deudaId);
      if (indiceDeuda == -1) return;

      // Actualizar la deuda
      final deuda = _deudas[indiceDeuda];
      final nuevoMontoPendiente = (deuda['montoPendiente'] as double) - montoPago;
      
      setState(() {
        _deudas[indiceDeuda]['montoPendiente'] = nuevoMontoPendiente.clamp(0.0, double.infinity);
        
        // Agregar al historial de pagos
        final historialPagos = List<Map<String, dynamic>>.from(_deudas[indiceDeuda]['historialPagos']);
        historialPagos.insert(0, {
          'fecha': DateTime.now(),
          'monto': montoPago,
        });
        _deudas[indiceDeuda]['historialPagos'] = historialPagos;
        
        // Cambiar estado si está completamente pagada
        if (nuevoMontoPendiente <= 0) {
          _deudas[indiceDeuda]['estado'] = 'Pagada';
        }
      });

      // TODO: Guardar en Firestore
      _calcularEstadisticas();
      _mostrarExito('Pago registrado correctamente');
      
    } catch (e) {
      debugPrint('Error al registrar pago: $e');
      _mostrarError('Error al registrar el pago');
    }
  }

  /// Elimina una deuda de la lista
  Future<void> _eliminarDeuda(String deudaId) async {
    try {
      setState(() {
        _deudas.removeWhere((d) => d['id'] == deudaId);
      });

      // TODO: Eliminar de Firestore
      _calcularEstadisticas();
      _mostrarExito('Deuda eliminada correctamente');
      
    } catch (e) {
      debugPrint('Error al eliminar deuda: $e');
      _mostrarError('Error al eliminar la deuda');
    }
  }

  // ===== MÉTODOS DE UTILIDAD =====

  /// Muestra un mensaje de error
  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(mensaje)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Muestra un mensaje de éxito
  void _mostrarExito(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(mensaje)),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Formatea números como moneda colombiana
  String _formatearMoneda(double valor) {
    return '\$${FormatoNumeros.formatearParaMostrar(valor)}';
  }

  /// Formatea fechas en formato legible
  String _formatearFecha(DateTime fecha) {
    final diferencia = fecha.difference(DateTime.now()).inDays;
    
    if (diferencia < 0) {
      return 'Vencida hace ${(-diferencia)} días';
    } else if (diferencia == 0) {
      return 'Vence hoy';
    } else if (diferencia == 1) {
      return 'Vence mañana';
    } else if (diferencia <= 7) {
      return 'Vence en $diferencia días';
    } else {
      final meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun',
                    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
      return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
    }
  }

  /// Calcula el color según el estado de la deuda
  Color _obtenerColorEstado(Map<String, dynamic> deuda) {
    switch (deuda['estado']) {
      case 'Vencida':
        return Colors.red;
      case 'Pagada':
        return const Color(0xFF10B981);
      default:
        // Verificar si está próxima a vencer
        if (deuda['fechaVencimiento'] != null) {
          final diasHastaVencimiento = deuda['fechaVencimiento'].difference(DateTime.now()).inDays;
          if (diasHastaVencimiento <= 3) {
            return Colors.orange;
          }
        }
        return const Color(0xFF3B82F6);
    }
  }

  /// Calcula el porcentaje de progreso de pago
  double _calcularProgresoPago(Map<String, dynamic> deuda) {
    final montoOriginal = deuda['montoOriginal'] as double;
    final montoPendiente = deuda['montoPendiente'] as double;
    
    if (montoOriginal <= 0) return 0.0;
    
    return ((montoOriginal - montoPendiente) / montoOriginal).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  // ===== CONSTRUCCIÓN DE UI =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _estaCargando
              ? _buildCargando()
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildResumenDeudas(),
                          const SizedBox(height: 24),
                          _buildFiltrosYOrden(),
                          const SizedBox(height: 16),
                          _buildListaDeudas(),
                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Construye la pantalla de carga
  Widget _buildCargando() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
          ),
          SizedBox(height: 24),
          Text(
            'Cargando tus deudas...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la barra de aplicación
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 96,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFEF4444),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Gestión de Deudas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEF4444),
                Color(0xFFDC2626),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el resumen general de deudas
  Widget _buildResumenDeudas() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEF4444),
              Color(0xFFDC2626),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Total deuda pendiente
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 22,
                ),
                  const SizedBox(width: 8),
                Column(
                  children: [
                      const Text(
                        'Total Deuda Pendiente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatearMoneda(_totalDeudaPendiente),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
              const SizedBox(height: 12),
            
            // Estadísticas en grid
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaResumen(
                    'Deudas Vencidas',
                    '$_deudasVencidas',
                    Icons.warning,
                  ),
                ),
                  const SizedBox(width: 12),
                Expanded(
                  child: _buildEstadisticaResumen(
                    'Pago Mínimo',
                    _formatearMoneda(_pagoMinimoMensual),
                    Icons.payment,
                  ),
                ),
              ],
            ),
            
              const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaResumen(
                    'Total Deudas',
                    '${_deudas.length}',
                    Icons.list_alt,
                  ),
                ),
                  const SizedBox(width: 12),
                Expanded(
                  child: _buildEstadisticaResumen(
                    'Promedio Vencimiento',
                    '$_diasPromedioVencimiento días',
                    Icons.schedule,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una estadística del resumen
  Widget _buildEstadisticaResumen(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icono,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            titulo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construye los controles de filtros y ordenamiento
  Widget _buildFiltrosYOrden() {
    return Row(
      children: [
        // Filtro
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filtroSeleccionado,
                icon: const Icon(Icons.filter_list, color: Color(0xFF6B7280)),
                items: _filtrosDisponibles.map((filtro) {
                  return DropdownMenuItem(
                    value: filtro,
                    child: Text(
                      filtro,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (nuevoFiltro) {
                  if (nuevoFiltro != null) {
                    setState(() {
                      _filtroSeleccionado = nuevoFiltro;
                    });
                    _calcularEstadisticas();
                  }
                },
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Ordenamiento
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _ordenSeleccionado,
                icon: const Icon(Icons.sort, color: Color(0xFF6B7280)),
                items: _opcionesOrden.map((orden) {
                  return DropdownMenuItem(
                    value: orden,
                    child: Text(
                      orden,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (nuevoOrden) {
                  if (nuevoOrden != null) {
                    setState(() {
                      _ordenSeleccionado = nuevoOrden;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye la lista de deudas
  Widget _buildListaDeudas() {
    final deudasFiltradas = _deudasFiltradas;
    
    if (deudasFiltradas.isEmpty) {
      return _buildListaVacia();
    }
    
    return Column(
      children: deudasFiltradas.asMap().entries.map((entry) {
        final index = entry.key;
        final deuda = entry.value;
        
        return AnimatedBuilder(
          animation: _cardController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0, 
                (1 - _cardController.value) * 30 * (index + 1),
              ),
              child: Opacity(
                opacity: _cardController.value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: _buildTarjetaDeuda(deuda),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  /// Construye el mensaje cuando no hay deudas
  Widget _buildListaVacia() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            _filtroSeleccionado == 'Todas' 
                ? '¡Sin deudas registradas!'
                : 'No hay deudas en esta categoría',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _filtroSeleccionado == 'Todas'
                ? 'Mantén un control financiero saludable'
                : 'Intenta con otro filtro',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta individual de deuda
  Widget _buildTarjetaDeuda(Map<String, dynamic> deuda) {
    final colorEstado = _obtenerColorEstado(deuda);
    final progresoPago = _calcularProgresoPago(deuda);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorEstado.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Encabezado de la tarjeta
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Ícono del tipo de deuda
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _obtenerIconoTipoDeuda(deuda['tipo']),
                    color: colorEstado,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                
                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deuda['titulo'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${deuda['tipo']} • ${deuda['acreedor']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorEstado.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Menú de opciones
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: colorEstado,
                  ),
                  onSelected: (opcion) => _manejarOpcionDeuda(opcion, deuda),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'pagar',
                      child: Row(
                        children: [
                          Icon(Icons.payment, color: Color(0xFF10B981)),
                          SizedBox(width: 8),
                          Text('Registrar Pago'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF3B82F6)),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'historial',
                      child: Row(
                        children: [
                          Icon(Icons.history, color: Color(0xFF8B5CF6)),
                          SizedBox(width: 8),
                          Text('Ver Historial'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Contenido de la tarjeta
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Montos y porcentaje
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monto Pendiente',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatearMoneda(deuda['montoPendiente']),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorEstado,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Pago Mínimo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatearMoneda(deuda['pagoMinimo']),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Barra de progreso
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progreso de Pago',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(progresoPago * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorEstado,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progresoPago,
                      backgroundColor: colorEstado.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(colorEstado),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Información adicional
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: colorEstado,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatearFecha(deuda['fechaVencimiento']),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorEstado,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.percent,
                          color: colorEstado,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${deuda['tasaInteres']}% anual',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorEstado,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el ícono según el tipo de deuda
  IconData _obtenerIconoTipoDeuda(String tipo) {
    switch (tipo) {
      case 'Tarjeta de Crédito':
        return Icons.credit_card;
      case 'Préstamo Personal':
        return Icons.person;
      case 'Préstamo Hipotecario':
        return Icons.home;
      case 'Préstamo Vehicular':
        return Icons.directions_car;
      case 'Préstamo Estudiantil':
        return Icons.school;
      case 'Línea de Crédito':
        return Icons.account_balance;
      case 'Factoring':
        return Icons.business;
      default:
        return Icons.receipt_long;
    }
  }

  /// Maneja las opciones del menú de cada deuda
  void _manejarOpcionDeuda(String opcion, Map<String, dynamic> deuda) {
    switch (opcion) {
      case 'pagar':
        _mostrarDialogoPago(deuda);
        break;
      case 'editar':
        _mostrarDialogoEditar(deuda);
        break;
      case 'historial':
        _mostrarHistorialPagos(deuda);
        break;
      case 'eliminar':
        _confirmarEliminarDeuda(deuda);
        break;
    }
  }

  /// Muestra el diálogo para registrar un pago
  void _mostrarDialogoPago(Map<String, dynamic> deuda) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.payment,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Registrar Pago'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deuda: ${deuda['titulo']}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Pendiente: ${_formatearMoneda(deuda['montoPendiente'])}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto del Pago',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Mínimo: ${_formatearMoneda(deuda['pagoMinimo'])}',
              ),
              inputFormatters: [
                FormateadorNumeros(),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final monto = FormatoNumeros.convertirANumero(controller.text) ?? 0.0;
              if (monto > 0) {
                Navigator.pop(context);
                _registrarPago(deuda['id'], monto);
              }
            },
            child: const Text(
              'Registrar Pago',
              style: TextStyle(color: Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra el diálogo para editar una deuda
  void _mostrarDialogoEditar(Map<String, dynamic> deuda) {
    // TODO: Implementar edición de deuda
    _mostrarInfo('Próximamente: Editar deuda');
  }

  /// Muestra el historial de pagos de una deuda
  void _mostrarHistorialPagos(Map<String, dynamic> deuda) {
    final historial = List<Map<String, dynamic>>.from(deuda['historialPagos'] ?? []);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Historial de Pagos - ${deuda['titulo']}'),
        content: SizedBox(
          width: double.maxFinite,
          child: historial.isEmpty
              ? const Text('No hay pagos registrados')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: historial.length,
                  itemBuilder: (context, index) {
                    final pago = historial[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.payment,
                        color: Color(0xFF10B981),
                      ),
                      title: Text(_formatearMoneda(pago['monto'])),
                      subtitle: Text(_formatearFecha(pago['fecha'])),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Confirma la eliminación de una deuda
  void _confirmarEliminarDeuda(Map<String, dynamic> deuda) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Eliminar Deuda'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar la deuda "${deuda['titulo']}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarDeuda(deuda['id']);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Note: Floating action button and "nueva deuda" dialog removed per request.

  /// Muestra un mensaje informativo
  void _mostrarInfo(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(mensaje)),
            ],
          ),
          backgroundColor: const Color(0xFF3B82F6),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
