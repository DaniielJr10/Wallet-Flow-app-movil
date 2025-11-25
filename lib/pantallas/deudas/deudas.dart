import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utilidades/formato_numeros.dart';
import '../../firebase/servicios/deudas_servicio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  /// Cambiado a `false` para mostrar la pantalla inmediatamente
  /// y evitar el mensaje de carga "Cargando tus deudas...".
  bool _estaCargando = false;
  
  /// Lista de todas las deudas del usuario
  List<Map<String, dynamic>> _deudas = [];
  final DeudasServicio _deudasServicio = DeudasServicio();
  
  /// Filtro de visualización seleccionado
  String _filtroSeleccionado = 'Todas';
  
  /// Orden de visualización de las deudas
  String _ordenSeleccionado = 'Vencimiento';

  /// Texto de búsqueda (barra superior)
  String _textoBusqueda = '';
  
  /// Modo de búsqueda del filtro ("categoría" o "mes")
  String _modoBusqueda = 'categoría';
  
  /// Key para ubicar el botón de filtro y anclar el popup
  final GlobalKey _filterButtonKey = GlobalKey();

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
    setState(() { _estaCargando = true; });
    try {
      final deudas = await _deudasServicio.obtenerDeudas();
      // Convertir fechas de Firestore (Timestamp) a DateTime
      _deudas = deudas.map((d) {
        if (d['fechaVencimiento'] is Timestamp) {
          d['fechaVencimiento'] = (d['fechaVencimiento'] as Timestamp).toDate();
        }
        if (d['fechaCreacion'] is Timestamp) {
          d['fechaCreacion'] = (d['fechaCreacion'] as Timestamp).toDate();
        }
        // Convertir historialPagos fechas
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
      _mostrarError('Error al cargar las deudas');
    } finally {
      setState(() { _estaCargando = false; });
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
    // Aplica búsqueda por texto (título, tipo, acreedor)
    if (_textoBusqueda.trim().isNotEmpty) {
      final q = _textoBusqueda.toLowerCase();
      deudasFiltradas = deudasFiltradas.where((d) {
        final titulo = (d['titulo'] ?? '').toString().toLowerCase();
        final tipo = (d['tipo'] ?? '').toString().toLowerCase();
        final acreedor = (d['acreedor'] ?? '').toString().toLowerCase();
        return titulo.contains(q) || tipo.contains(q) || acreedor.contains(q);
      }).toList();
    }

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

  // La lógica de registro de pagos fue removida porque ya no hay un flujo
  // directo que invoque este helper desde la UI actual (se maneja vía modal).

  /// Elimina una deuda de la lista
  Future<void> _eliminarDeuda(String deudaId) async {
    try {
      await _deudasServicio.eliminarDeuda(deudaId);
      await _cargarDeudas();
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
          backgroundColor: const Color(0xFFF97316),
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

  // El cálculo de progreso de pago fue eliminado al no usarse en la UI actual.

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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
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
      backgroundColor: const Color(0xFFF97316),
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
                Color(0xFFF97316),
                Color(0xFFEA580C),
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
              Color(0xFFF97316),
              Color(0xFFEA580C),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF97316).withOpacity(0.3),
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
    // Cabecera igual a la de 'ingresos': search bar grande + botón circular de filtro
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (v) {
                          setState(() {
                            _textoBusqueda = v;
                            _calcularEstadisticas();
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Buscar por categoría...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Small filter button styled like the attached icon (white rounded square + green funnel)
            Container(
              key: _filterButtonKey,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => _mostrarModalFiltroBusqueda(),
                icon: const Icon(Icons.filter_alt_rounded, color: Color(0xFFF97316), size: 20),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Title row: left title, right green action button (visual only)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Historial de Deudas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            ElevatedButton.icon(
                  onPressed: () => _mostrarFormularioNuevaDeuda(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Nueva deuda'),
                style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
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

    // Mostrar la lista en estilo compacto similar a la pantalla de ingresos
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: deudasFiltradas.length,
      itemBuilder: (context, index) {
        final deuda = deudasFiltradas[index];
        return _buildTarjetaDeudaCompact(deuda, index);
      },
    );
  }

  /// Construye una tarjeta compacta para una deuda (estilo similar a ingresos)
  Widget _buildTarjetaDeudaCompact(Map<String, dynamic> deuda, int index) {
    final colorEstado = _obtenerColorEstado(deuda);
    // Color naranja consistente con la pantalla de Deudas
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarHistorialPagos(deuda),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _obtenerIconoTipoDeuda(deuda['tipo']),
              color: colorEstado,
              size: 20,
            ),
          ),
          title: Text(
            deuda['titulo'],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${deuda['tipo']} • ${deuda['acreedor']}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                '${deuda['fechaVencimiento'] != null ? '${deuda['fechaVencimiento'].day}/${deuda['fechaVencimiento'].month}/${deuda['fechaVencimiento'].year}' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          trailing: SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '-${FormatoNumeros.formatearParaMostrar(deuda['montoPendiente'])}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colorEstado == const Color(0xFF10B981) ? Colors.green : Colors.red,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                // Reemplazado el menú de tres puntos por una flecha (estilo Ingresos)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
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

  // Opciones de menú antiguas eliminadas (no usadas en la versión compacta)

  // La función de diálogo de pago fue eliminada porque ya no se usa
  // (la UI ahora muestra los pagos y acciones en el modal de detalles).

  /// Muestra el diálogo para editar una deuda
  void _mostrarDialogoEditar(Map<String, dynamic> deuda) {
    final formKey = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController(text: deuda['titulo'] ?? '');
    final montoCtrl = TextEditingController(text: deuda['montoOriginal']?.toString() ?? deuda['montoPendiente']?.toString() ?? '0');
    final pagoMinCtrl = TextEditingController(text: deuda['pagoMinimo']?.toString() ?? '0');
    final acreedorCtrl = TextEditingController(text: deuda['acreedor'] ?? '');
    String tipoSeleccionado = deuda['tipo'] ?? 'Préstamo Personal';
    DateTime fechaVenc = deuda['fechaVencimiento'] ?? DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF97316).withOpacity(0.95),
                        const Color(0xFFFB923C).withOpacity(0.95),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.white, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Editar Deuda',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: tituloCtrl,
                            decoration: const InputDecoration(labelText: 'Título'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un título' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: tipoSeleccionado,
                            items: const [
                              DropdownMenuItem(value: 'Préstamo Personal', child: Text('Préstamo Personal')),
                              DropdownMenuItem(value: 'Tarjeta de Crédito', child: Text('Tarjeta de Crédito')),
                              DropdownMenuItem(value: 'Préstamo Vehicular', child: Text('Préstamo Vehicular')),
                              DropdownMenuItem(value: 'Préstamo Hipotecario', child: Text('Préstamo Hipotecario')),
                              DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                            ],
                            onChanged: (v) => setStateModal(() { tipoSeleccionado = v ?? tipoSeleccionado; }),
                            decoration: const InputDecoration(labelText: 'Categoría'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: montoCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Monto'),
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              return (n == null || n <= 0) ? 'Ingresa un monto válido' : null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: pagoMinCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Pago mínimo'),
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              return (n == null || n < 0) ? 'Ingresa un pago mínimo válido' : null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: acreedorCtrl,
                            decoration: const InputDecoration(labelText: 'Acreedor / Banco'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Fecha de vencimiento:'),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: fechaVenc,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) setStateModal(() { fechaVenc = picked; });
                                },
                                child: Text('${fechaVenc.day}/${fechaVenc.month}/${fechaVenc.year}'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.grey.shade800,
                                    side: BorderSide(color: Colors.grey.shade300),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (formKey.currentState?.validate() ?? false) {
                                      final datosActualizados = {
                                        'titulo': tituloCtrl.text.trim(),
                                        'montoOriginal': double.tryParse(montoCtrl.text) ?? 0.0,
                                        'montoPendiente': double.tryParse(montoCtrl.text) ?? 0.0,
                                        'pagoMinimo': double.tryParse(pagoMinCtrl.text) ?? 0.0,
                                        'acreedor': acreedorCtrl.text.trim(),
                                        'tipo': tipoSeleccionado,
                                        'fechaVencimiento': fechaVenc,
                                      };
                                      await _deudasServicio.editarDeuda(deuda['id'], datosActualizados);
                                      Navigator.pop(context);
                                      await _cargarDeudas();
                                      _mostrarExito('Deuda actualizada correctamente');
                                    }
                                  },
                                  child: const Text('Guardar Cambios'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF97316),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Muestra el historial de pagos de una deuda
  void _mostrarHistorialPagos(Map<String, dynamic> deuda) {
    final historial = List<Map<String, dynamic>>.from(deuda['historialPagos'] ?? []);

    final colorEstado = _obtenerColorEstado(deuda);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [const Color(0xFFF97316), const Color(0xFFEA580C)],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _obtenerIconoTipoDeuda(deuda['tipo']),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detalles de la Deuda',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                deuda['titulo'],
                                style: const TextStyle(color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Column(
                        children: [
                          // Amount box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colorEstado.withOpacity(0.25), width: 2),
                            ),
                            child: Text(
                              '-${FormatoNumeros.formatearParaMostrar(deuda['montoPendiente'])}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFF97316),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Details list
                          _buildDetalleRow('Descripción', deuda['titulo'], Icons.description_outlined),
                          const SizedBox(height: 12),
                          _buildDetalleRow('Tipo', deuda['tipo'], Icons.category_outlined),
                          const SizedBox(height: 12),
                          _buildDetalleRow('Acreedor', deuda['acreedor'] ?? '', Icons.account_balance_outlined),
                          const SizedBox(height: 12),
                          _buildDetalleRow('Fecha vencimiento', deuda['fechaVencimiento'] != null ? '${deuda['fechaVencimiento'].day}/${deuda['fechaVencimiento'].month}/${deuda['fechaVencimiento'].year}' : '—', Icons.calendar_today_outlined),
                          const SizedBox(height: 12),
                          _buildDetalleRow('Pago mínimo', _formatearMoneda(deuda['pagoMinimo'] ?? 0.0), Icons.payment_outlined),
                          const SizedBox(height: 12),
                          _buildDetalleRow('Tasa interés', '${deuda['tasaInteres'] ?? 0}% anual', Icons.percent),
                          const SizedBox(height: 18),

                          // Historial de pagos
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Historial de pagos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey[800])),
                          ),
                          const SizedBox(height: 8),
                          historial.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('No hay pagos registrados'),
                                )
                              : Column(
                                  children: historial.map((pago) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.payment, color: Color(0xFFF97316)),
                                      title: Text(_formatearMoneda(pago['monto'])),
                                      subtitle: Text(_formatearFecha(pago['fecha'])),
                                    );
                                  }).toList(),
                                ),
                          const SizedBox(height: 26),
                        ],
                      ),
                    ),
                  ),

                  // Actions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _mostrarDialogoEditar(deuda);
                            },
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: const Text('Editar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _confirmarEliminarDeuda(deuda);
                            },
                            icon: const Icon(Icons.delete_rounded, size: 18),
                            label: const Text('Eliminar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Construye una fila de detalle con icono, título y valor para el modal
  Widget _buildDetalleRow(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: Colors.grey.shade700, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(valor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
              ],
            ),
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

  /// Muestra el formulario para crear una nueva deuda (modal)
  void _mostrarFormularioNuevaDeuda() {
    final _formKeyNueva = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    final pagoMinCtrl = TextEditingController();
    final acreedorCtrl = TextEditingController();
    String tipoSeleccionado = 'Préstamo Personal';
    DateTime fechaVenc = DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF97316).withOpacity(0.95),
                        const Color(0xFFFB923C).withOpacity(0.95),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.white, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Crear Deuda',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKeyNueva,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: tituloCtrl,
                            decoration: InputDecoration(
                              labelText: 'Título',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un título' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: tipoSeleccionado,
                            items: const [
                              DropdownMenuItem(value: 'Préstamo Personal', child: Text('Préstamo Personal')),
                              DropdownMenuItem(value: 'Tarjeta de Crédito', child: Text('Tarjeta de Crédito')),
                              DropdownMenuItem(value: 'Préstamo Vehicular', child: Text('Préstamo Vehicular')),
                              DropdownMenuItem(value: 'Préstamo Hipotecario', child: Text('Préstamo Hipotecario')),
                              DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                            ],
                            onChanged: (v) => setStateModal(() { tipoSeleccionado = v ?? tipoSeleccionado; }),
                            decoration: const InputDecoration(labelText: 'Categoría'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: montoCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Monto',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              return (n == null || n <= 0) ? 'Ingresa un monto válido' : null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: pagoMinCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Pago mínimo',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              return (n == null || n < 0) ? 'Ingresa un pago mínimo válido' : null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: acreedorCtrl,
                            decoration: InputDecoration(
                              labelText: 'Acreedor / Banco',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Fecha de vencimiento:'),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: fechaVenc,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) setStateModal(() { fechaVenc = picked; });
                                },
                                child: Text('${fechaVenc.day}/${fechaVenc.month}/${fechaVenc.year}'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.grey.shade800,
                                    side: BorderSide(color: Colors.grey.shade300),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKeyNueva.currentState?.validate() ?? false) {
                                      final nuevaDeuda = {
                                        'titulo': tituloCtrl.text.trim(),
                                        'tipo': tipoSeleccionado,
                                        'montoOriginal': double.tryParse(montoCtrl.text) ?? 0.0,
                                        'montoPendiente': double.tryParse(montoCtrl.text) ?? 0.0,
                                        'tasaInteres': 0.0,
                                        'fechaVencimiento': fechaVenc,
                                        'pagoMinimo': double.tryParse(pagoMinCtrl.text) ?? 0.0,
                                        'estado': 'Pendiente',
                                        'fechaCreacion': DateTime.now(),
                                        'acreedor': acreedorCtrl.text.trim(),
                                        'numeroCuenta': '',
                                        'historialPagos': [],
                                      };
                                      await _deudasServicio.crearDeuda(nuevaDeuda);
                                      Navigator.pop(context);
                                      await _cargarDeudas();
                                      _mostrarExito('Deuda creada correctamente');
                                    }
                                  },
                                  child: const Text('Crear'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF97316),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Muestra el modal flotante de opciones de búsqueda (Por categoría / Por mes)
  void _mostrarModalFiltroBusqueda() {
    // Try to anchor a popup to the filter button. If key is not available, fallback to dialog.
    final keyContext = _filterButtonKey.currentContext;
    if (keyContext == null) {
      // fallback: simple dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Modo de búsqueda'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'categoría',
                groupValue: _modoBusqueda,
                title: const Text('Por categoría'),
                onChanged: (v) { setState(() { _modoBusqueda = v ?? _modoBusqueda; }); Navigator.pop(context); },
              ),
              RadioListTile<String>(
                value: 'mes',
                groupValue: _modoBusqueda,
                title: const Text('Por mes'),
                onChanged: (v) { setState(() { _modoBusqueda = v ?? _modoBusqueda; }); Navigator.pop(context); },
              ),
            ],
          ),
        ),
      );
      return;
    }

    final renderBox = keyContext.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Mostrar el popup debajo del botón (como en la imagen). Calculamos la posición
    // y la recortamos para que no salga de la pantalla.
    const double menuApproxHeight = 140.0;
    double desiredTop = offset.dy + size.height + 8;
    // Ajuste fino: subir el popup más arriba según solicitud
    desiredTop -= 40; // subir 40px
    // Si queda fuera inferior, subirlo para que quepa; también limitar el top mínimo
    if (desiredTop + menuApproxHeight > screenSize.height - 8.0) {
      desiredTop = (screenSize.height - menuApproxHeight - 8.0).clamp(8.0, double.infinity);
    }
    final top = desiredTop.clamp(8.0, screenSize.height - menuApproxHeight - 8.0);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        top,
        offset.dx + size.width,
        offset.dy,
      ),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            children: const [
                  Icon(Icons.tune, color: Color(0xFFF97316)),
                  SizedBox(width: 8),
                  Text('Modo de búsqueda', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.w700)),
                ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'categoría',
          child: Row(
              children: [
              const Icon(Icons.category, color: Color(0xFFF97316)),
              const SizedBox(width: 10),
              const Expanded(child: Text('Por categoría')),
              if (_modoBusqueda == 'categoría') const Icon(Icons.check_circle, color: Color(0xFFF97316)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'mes',
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: Color(0xFF64748B)),
              const SizedBox(width: 10),
              const Expanded(child: Text('Por mes')),
              if (_modoBusqueda == 'mes') const Icon(Icons.check_circle, color: Color(0xFFF97316)),
            ],
          ),
        ),
      ],
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ).then((value) {
      if (value != null) setState(() { _modoBusqueda = value; });
    });
    // no await required; state will be updated in then
  }

  // Note: Floating action button and "nueva deuda" dialog removed per request.

  // Nota: helper '_mostrarInfo' eliminado porque no se usa en este archivo.
}
