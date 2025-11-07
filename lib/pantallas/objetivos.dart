import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../firebase/base_datos_servicio.dart';

/// Pantalla de gestión de objetivos financieros en Wallet Flow
/// 
/// Permite al usuario crear, monitorear y gestionar sus metas financieras
/// a corto, mediano y largo plazo con seguimiento visual del progreso.
/// 
/// Características principales:
/// - Creación de objetivos de ahorro personalizados
/// - Seguimiento visual del progreso con gráficos
/// - Categorización por plazos (corto, mediano, largo)
/// - Cálculo automático de aportes necesarios
/// - Notificaciones de progreso y logros
/// - Análisis predictivo de cumplimiento
class PantallaObjetivos extends StatefulWidget {
  const PantallaObjetivos({super.key});

  @override
  State<PantallaObjetivos> createState() => _PantallaObjetivosState();
}

class _PantallaObjetivosState extends State<PantallaObjetivos>
    with TickerProviderStateMixin {

  // ===== SERVICIOS Y CONTROLADORES =====
  final BaseDatosServicio _baseDatosService = BaseDatosServicio();
  
  /// Controlador principal de animaciones
  late AnimationController _animationController;
  
  /// Controlador para animaciones de progreso
  late AnimationController _progressController;
  
  /// Controlador para animaciones de tarjetas
  late AnimationController _cardController;
  
  // Animaciones principales
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  // Animaciones de progreso
  late Animation<double> _progressAnimation;

  // ===== ESTADOS DE LA PANTALLA =====
  /// Indica si los datos están siendo cargados
  bool _estaCargando = true;
  
  /// Lista de todos los objetivos del usuario
  List<Map<String, dynamic>> _objetivos = [];
  
  /// Filtro de visualización seleccionado
  String _filtroSeleccionado = 'Todos';
  
  /// Categoría seleccionada para filtrar
  String _categoriaSeleccionada = 'Todas';

  // ===== DATOS CALCULADOS =====
  /// Total ahorrado en todos los objetivos
  double _totalAhorrado = 0.0;
  
  /// Total de metas establecidas
  double _totalMetas = 0.0;
  
  /// Porcentaje promedio de cumplimiento
  double _progresoPromedio = 0.0;
  
  /// Objetivos completados este mes
  int _objetivosCompletados = 0;
  
  /// Ahorro mensual requerido para cumplir metas
  double _ahorroMensualRequerido = 0.0;

  // ===== CONFIGURACIÓN =====
  /// Categorías de objetivos disponibles
  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Todas', 'icono': Icons.all_inclusive, 'color': Color(0xFF6B7280)},
    {'nombre': 'Vacaciones', 'icono': Icons.flight, 'color': Color(0xFF3B82F6)},
    {'nombre': 'Emergencias', 'icono': Icons.security, 'color': Color(0xFFEF4444)},
    {'nombre': 'Educación', 'icono': Icons.school, 'color': Color(0xFF8B5CF6)},
    {'nombre': 'Hogar', 'icono': Icons.home, 'color': Color(0xFF10B981)},
    {'nombre': 'Vehículo', 'icono': Icons.directions_car, 'color': Color(0xFFF59E0B)},
    {'nombre': 'Inversión', 'icono': Icons.trending_up, 'color': Color(0xFF059669)},
    {'nombre': 'Tecnología', 'icono': Icons.devices, 'color': Color(0xFF7C3AED)},
    {'nombre': 'Salud', 'icono': Icons.favorite, 'color': Color(0xFFDC2626)},
    {'nombre': 'Otro', 'icono': Icons.star, 'color': Color(0xFF6366F1)},
  ];

  /// Filtros de visualización disponibles
  final List<String> _filtrosDisponibles = [
    'Todos',
    'En Progreso',
    'Completados',
    'Pausados',
    'Próximos a Cumplir',
  ];

  /// Plazos disponibles para objetivos
  final List<Map<String, dynamic>> _plazos = [
    {'nombre': 'Corto Plazo', 'meses': 6, 'color': Color(0xFF10B981)},
    {'nombre': 'Mediano Plazo', 'meses': 18, 'color': Color(0xFFF59E0B)},
    {'nombre': 'Largo Plazo', 'meses': 36, 'color': Color(0xFF3B82F6)},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _cargarObjetivos();
  }

  /// Inicializa todas las animaciones de la pantalla
  void _initializeAnimations() {
    // Controlador principal
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Controlador de progreso
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Controlador de tarjetas
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

    // Animación de progreso
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ));

    _animationController.forward();
  }

  /// Carga todos los objetivos del usuario desde la base de datos
  Future<void> _cargarObjetivos() async {
    setState(() {
      _estaCargando = true;
    });

    try {
      // TODO: Cargar objetivos reales desde Firestore
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Datos de ejemplo - reemplazar con datos reales
      _objetivos = [
        {
          'id': '1',
          'titulo': 'Fondo de Emergencia',
          'descripcion': 'Ahorro para gastos inesperados y emergencias familiares',
          'categoria': 'Emergencias',
          'metaMonto': 3000000.0,
          'montoActual': 1850000.0,
          'fechaInicio': DateTime.now().subtract(const Duration(days: 90)),
          'fechaMeta': DateTime.now().add(const Duration(days: 90)),
          'estado': 'En Progreso',
          'prioridad': 'Alta',
          'aporteMensual': 400000.0,
          'historialAportes': [
            {'fecha': DateTime.now().subtract(const Duration(days: 30)), 'monto': 400000.0},
            {'fecha': DateTime.now().subtract(const Duration(days: 60)), 'monto': 450000.0},
            {'fecha': DateTime.now().subtract(const Duration(days: 90)), 'monto': 300000.0},
          ],
        },
        {
          'id': '2',
          'titulo': 'Vacaciones en Europa',
          'descripcion': 'Viaje familiar de 15 días por Europa en verano',
          'categoria': 'Vacaciones',
          'metaMonto': 8000000.0,
          'montoActual': 3200000.0,
          'fechaInicio': DateTime.now().subtract(const Duration(days: 180)),
          'fechaMeta': DateTime.now().add(const Duration(days: 120)),
          'estado': 'En Progreso',
          'prioridad': 'Media',
          'aporteMensual': 800000.0,
          'historialAportes': [
            {'fecha': DateTime.now().subtract(const Duration(days: 30)), 'monto': 800000.0},
            {'fecha': DateTime.now().subtract(const Duration(days: 60)), 'monto': 800000.0},
            {'fecha': DateTime.now().subtract(const Duration(days: 90)), 'monto': 600000.0},
          ],
        },
        {
          'id': '3',
          'titulo': 'MacBook Pro',
          'descripcion': 'Laptop para trabajo y proyectos personales',
          'categoria': 'Tecnología',
          'metaMonto': 6500000.0,
          'montoActual': 6500000.0,
          'fechaInicio': DateTime.now().subtract(const Duration(days: 240)),
          'fechaMeta': DateTime.now().subtract(const Duration(days: 10)),
          'estado': 'Completado',
          'prioridad': 'Alta',
          'aporteMensual': 650000.0,
          'historialAportes': [],
        },
        {
          'id': '4',
          'titulo': 'Curso de Programación',
          'descripcion': 'Bootcamp intensivo de desarrollo Full Stack',
          'categoria': 'Educación',
          'metaMonto': 2500000.0,
          'montoActual': 500000.0,
          'fechaInicio': DateTime.now().subtract(const Duration(days: 30)),
          'fechaMeta': DateTime.now().add(const Duration(days: 150)),
          'estado': 'En Progreso',
          'prioridad': 'Alta',
          'aporteMensual': 400000.0,
          'historialAportes': [
            {'fecha': DateTime.now().subtract(const Duration(days: 30)), 'monto': 500000.0},
          ],
        },
      ];

      _calcularEstadisticas();
      _cardController.forward();
      _progressController.forward();
      
    } catch (e) {
      debugPrint('Error al cargar objetivos: $e');
      _mostrarError('Error al cargar los objetivos');
    } finally {
      setState(() {
        _estaCargando = false;
      });
    }
  }

  /// Calcula estadísticas generales de los objetivos
  void _calcularEstadisticas() {
    _totalAhorrado = 0.0;
    _totalMetas = 0.0;
    _objetivosCompletados = 0;
    double progresoTotal = 0.0;
    _ahorroMensualRequerido = 0.0;

    final objetivosFiltrados = _objetivosFiltrados;

    for (var objetivo in objetivosFiltrados) {
      _totalAhorrado += objetivo['montoActual'];
      _totalMetas += objetivo['metaMonto'];
      
      if (objetivo['estado'] == 'Completado') {
        _objetivosCompletados++;
        progresoTotal += 1.0;
      } else {
        final progreso = objetivo['montoActual'] / objetivo['metaMonto'];
        progresoTotal += progreso;
        
        // Calcular aporte mensual requerido
        if (objetivo['estado'] == 'En Progreso') {
          final montoFaltante = objetivo['metaMonto'] - objetivo['montoActual'];
          final fechaMeta = objetivo['fechaMeta'] as DateTime;
          final mesesRestantes = fechaMeta.difference(DateTime.now()).inDays / 30;
          
          if (mesesRestantes > 0) {
            _ahorroMensualRequerido += montoFaltante / mesesRestantes;
          }
        }
      }
    }

    _progresoPromedio = objetivosFiltrados.isNotEmpty 
        ? (progresoTotal / objetivosFiltrados.length).clamp(0.0, 1.0)
        : 0.0;
  }

  /// Obtiene los objetivos filtrados según criterios seleccionados
  List<Map<String, dynamic>> get _objetivosFiltrados {
    var objetivosFiltrados = List<Map<String, dynamic>>.from(_objetivos);

    // Filtrar por categoría
    if (_categoriaSeleccionada != 'Todas') {
      objetivosFiltrados = objetivosFiltrados
          .where((obj) => obj['categoria'] == _categoriaSeleccionada)
          .toList();
    }

    // Filtrar por estado
    switch (_filtroSeleccionado) {
      case 'En Progreso':
        objetivosFiltrados = objetivosFiltrados
            .where((obj) => obj['estado'] == 'En Progreso')
            .toList();
        break;
      case 'Completados':
        objetivosFiltrados = objetivosFiltrados
            .where((obj) => obj['estado'] == 'Completado')
            .toList();
        break;
      case 'Pausados':
        objetivosFiltrados = objetivosFiltrados
            .where((obj) => obj['estado'] == 'Pausado')
            .toList();
        break;
      case 'Próximos a Cumplir':
        objetivosFiltrados = objetivosFiltrados.where((obj) {
          if (obj['fechaMeta'] == null || obj['estado'] != 'En Progreso') return false;
          final diasHastaMeta = obj['fechaMeta'].difference(DateTime.now()).inDays;
          final progreso = obj['montoActual'] / obj['metaMonto'];
          return diasHastaMeta <= 30 && progreso >= 0.8;
        }).toList();
        break;
    }

    // Ordenar por prioridad y progreso
    objetivosFiltrados.sort((a, b) {
      // Primero por prioridad
      const prioridadOrden = {'Alta': 0, 'Media': 1, 'Baja': 2};
      final prioridadA = prioridadOrden[a['prioridad']] ?? 3;
      final prioridadB = prioridadOrden[b['prioridad']] ?? 3;
      
      if (prioridadA != prioridadB) {
        return prioridadA.compareTo(prioridadB);
      }
      
      // Luego por progreso (completados al final)
      if (a['estado'] == 'Completado' && b['estado'] != 'Completado') return 1;
      if (b['estado'] == 'Completado' && a['estado'] != 'Completado') return -1;
      
      // Finalmente por fecha meta
      if (a['fechaMeta'] != null && b['fechaMeta'] != null) {
        return a['fechaMeta'].compareTo(b['fechaMeta']);
      }
      
      return 0;
    });

    return objetivosFiltrados;
  }

  /// Registra un nuevo aporte a un objetivo específico
  Future<void> _registrarAporte(String objetivoId, double montoAporte) async {
    try {
      final indiceObjetivo = _objetivos.indexWhere((obj) => obj['id'] == objetivoId);
      if (indiceObjetivo == -1) return;

      setState(() {
        final objetivo = _objetivos[indiceObjetivo];
        final nuevoMontoActual = (objetivo['montoActual'] as double) + montoAporte;
        
        _objetivos[indiceObjetivo]['montoActual'] = nuevoMontoActual;
        
        // Agregar al historial de aportes
        final historialAportes = List<Map<String, dynamic>>.from(
          _objetivos[indiceObjetivo]['historialAportes']
        );
        historialAportes.insert(0, {
          'fecha': DateTime.now(),
          'monto': montoAporte,
        });
        _objetivos[indiceObjetivo]['historialAportes'] = historialAportes;
        
        // Cambiar estado si se completó
        if (nuevoMontoActual >= objetivo['metaMonto']) {
          _objetivos[indiceObjetivo]['estado'] = 'Completado';
          _mostrarCelebracionObjetivo(objetivo);
        }
      });

      // TODO: Guardar en Firestore
      _calcularEstadisticas();
      _mostrarExito('Aporte registrado correctamente');
      
    } catch (e) {
      debugPrint('Error al registrar aporte: $e');
      _mostrarError('Error al registrar el aporte');
    }
  }

  /// Muestra una celebración cuando se completa un objetivo
  void _mostrarCelebracionObjetivo(Map<String, dynamic> objetivo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF10B981),
                Color(0xFF059669),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de celebración
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Mensaje de felicitación
              const Text(
                '¡Felicitaciones!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Has completado tu objetivo:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                objetivo['titulo'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Botón cerrar
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  /// Formatea números como moneda colombiana
  String _formatearMoneda(double valor) {
    return '\$${valor.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  /// Formatea fechas en formato legible
  String _formatearFecha(DateTime fecha) {
    final diferencia = fecha.difference(DateTime.now()).inDays;
    
    if (diferencia < 0) {
      return 'Meta vencida';
    } else if (diferencia == 0) {
      return 'Meta hoy';
    } else if (diferencia <= 30) {
      return 'En $diferencia días';
    } else {
      final meses = diferencia ~/ 30;
      return 'En ${meses} mes${meses > 1 ? 'es' : ''}';
    }
  }

  /// Obtiene el color de la categoría
  Color _obtenerColorCategoria(String categoria) {
    final categoriaData = _categorias.firstWhere(
      (cat) => cat['nombre'] == categoria,
      orElse: () => _categorias.last,
    );
    return categoriaData['color'];
  }

  /// Obtiene el ícono de la categoría
  IconData _obtenerIconoCategoria(String categoria) {
    final categoriaData = _categorias.firstWhere(
      (cat) => cat['nombre'] == categoria,
      orElse: () => _categorias.last,
    );
    return categoriaData['icono'];
  }

  /// Calcula el progreso de un objetivo (0.0 a 1.0)
  double _calcularProgreso(Map<String, dynamic> objetivo) {
    final montoActual = objetivo['montoActual'] as double;
    final metaMonto = objetivo['metaMonto'] as double;
    
    if (metaMonto <= 0) return 0.0;
    return (montoActual / metaMonto).clamp(0.0, 1.0);
  }

  /// Determina el plazo del objetivo
  String _determinarPlazo(Map<String, dynamic> objetivo) {
    final fechaInicio = objetivo['fechaInicio'] as DateTime;
    final fechaMeta = objetivo['fechaMeta'] as DateTime;
    final mesesDuracion = fechaMeta.difference(fechaInicio).inDays / 30;
    
    if (mesesDuracion <= 6) return 'Corto Plazo';
    if (mesesDuracion <= 18) return 'Mediano Plazo';
    return 'Largo Plazo';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
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
                          _buildResumenObjetivos(),
                          const SizedBox(height: 24),
                          _buildFiltrosCategoria(),
                          const SizedBox(height: 16),
                          _buildFiltroEstado(),
                          const SizedBox(height: 16),
                          _buildListaObjetivos(),
                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: _buildBotonNuevoObjetivo(),
    );
  }

  /// Construye la pantalla de carga
  Widget _buildCargando() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
          SizedBox(height: 24),
          Text(
            'Cargando tus objetivos...',
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
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF10B981),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Objetivos Financieros',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF10B981),
                Color(0xFF059669),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el resumen general de objetivos
  Widget _buildResumenObjetivos() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF10B981),
              Color(0xFF059669),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Progreso general con animación
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gráfico circular de progreso
                SizedBox(
                  width: 80,
                  height: 80,
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          // Círculo de fondo
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          // Progreso circular
                          CircularProgressIndicator(
                            value: _progressAnimation.value * _progresoPromedio,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 6,
                          ),
                          // Texto central
                          Center(
                            child: Text(
                              '${(_progressAnimation.value * _progresoPromedio * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progreso General',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatearMoneda(_totalAhorrado),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'de ${_formatearMoneda(_totalMetas)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Estadísticas en grid
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaObjetivo(
                    'Completados',
                    '$_objetivosCompletados',
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEstadisticaObjetivo(
                    'En Progreso',
                    '${_objetivos.where((obj) => obj['estado'] == 'En Progreso').length}',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Ahorro mensual requerido
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.savings,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ahorro Mensual Requerido',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatearMoneda(_ahorroMensualRequerido),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una estadística del resumen
  Widget _buildEstadisticaObjetivo(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icono,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            titulo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construye los filtros de categoría
  Widget _buildFiltrosCategoria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorías',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _categorias.length,
            itemBuilder: (context, index) {
              final categoria = _categorias[index];
              final esSeleccionada = categoria['nombre'] == _categoriaSeleccionada;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _categoriaSeleccionada = categoria['nombre'];
                  });
                  _calcularEstadisticas();
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: esSeleccionada 
                              ? categoria['color']
                              : categoria['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: esSeleccionada
                              ? Border.all(color: categoria['color'], width: 2)
                              : null,
                        ),
                        child: Icon(
                          categoria['icono'],
                          color: esSeleccionada 
                              ? Colors.white
                              : categoria['color'],
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoria['nombre'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: esSeleccionada 
                              ? FontWeight.bold 
                              : FontWeight.w500,
                          color: esSeleccionada 
                              ? categoria['color']
                              : const Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Construye el filtro de estado
  Widget _buildFiltroEstado() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filtroSeleccionado,
          icon: const Icon(Icons.filter_list, color: Color(0xFF6B7280)),
          isExpanded: true,
          items: _filtrosDisponibles.map((filtro) {
            return DropdownMenuItem(
              value: filtro,
              child: Text(
                filtro,
                style: const TextStyle(fontSize: 14),
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
    );
  }

  /// Construye la lista de objetivos
  Widget _buildListaObjetivos() {
    final objetivosFiltrados = _objetivosFiltrados;
    
    if (objetivosFiltrados.isEmpty) {
      return _buildListaVacia();
    }
    
    return Column(
      children: objetivosFiltrados.asMap().entries.map((entry) {
        final index = entry.key;
        final objetivo = entry.value;
        
        return AnimatedBuilder(
          animation: _cardController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0, 
                (1 - _cardController.value) * 50 * (index + 1),
              ),
              child: Opacity(
                opacity: _cardController.value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildTarjetaObjetivo(objetivo),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  /// Construye el mensaje cuando no hay objetivos
  Widget _buildListaVacia() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.track_changes,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _filtroSeleccionado == 'Todos' 
                ? '¡Crea tu primer objetivo!'
                : 'No hay objetivos en esta categoría',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _filtroSeleccionado == 'Todos'
                ? 'Define metas claras para alcanzar tus sueños'
                : 'Intenta con otro filtro o categoría',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta individual de objetivo
  Widget _buildTarjetaObjetivo(Map<String, dynamic> objetivo) {
    final colorCategoria = _obtenerColorCategoria(objetivo['categoria']);
    final iconoCategoria = _obtenerIconoCategoria(objetivo['categoria']);
    final progreso = _calcularProgreso(objetivo);
    final plazo = _determinarPlazo(objetivo);
    final esCompletado = objetivo['estado'] == 'Completado';
    
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
          color: colorCategoria.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Encabezado de la tarjeta
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorCategoria.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Ícono de categoría
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorCategoria.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconoCategoria,
                    color: colorCategoria,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              objetivo['titulo'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          // Badge de estado
                          if (esCompletado)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Completado',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            objetivo['categoria'],
                            style: TextStyle(
                              fontSize: 12,
                              color: colorCategoria,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colorCategoria.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            plazo,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorCategoria.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Menú de opciones
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: colorCategoria,
                  ),
                  onSelected: (opcion) => _manejarOpcionObjetivo(opcion, objetivo),
                  itemBuilder: (context) => [
                    if (!esCompletado)
                      const PopupMenuItem(
                        value: 'aporte',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle, color: Color(0xFF10B981)),
                            SizedBox(width: 8),
                            Text('Agregar Aporte'),
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
                    if (!esCompletado)
                      const PopupMenuItem(
                        value: 'pausar',
                        child: Row(
                          children: [
                            Icon(Icons.pause, color: Color(0xFFF59E0B)),
                            SizedBox(width: 8),
                            Text('Pausar'),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descripción
                if (objetivo['descripcion'].isNotEmpty) ...[
                  Text(
                    objetivo['descripcion'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Progreso y montos
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Progreso',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${(progreso * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorCategoria,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: _progressAnimation.value * progreso,
                                backgroundColor: colorCategoria.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(colorCategoria),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Montos
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ahorrado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatearMoneda(objetivo['montoActual']),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorCategoria,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Meta',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatearMoneda(objetivo['metaMonto']),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
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
                          color: colorCategoria,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatearFecha(objetivo['fechaMeta']),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorCategoria,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    if (!esCompletado)
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: colorCategoria,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatearMoneda(objetivo['aporteMensual'])}/mes',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorCategoria,
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

  /// Maneja las opciones del menú de cada objetivo
  void _manejarOpcionObjetivo(String opcion, Map<String, dynamic> objetivo) {
    switch (opcion) {
      case 'aporte':
        _mostrarDialogoAporte(objetivo);
        break;
      case 'editar':
        _mostrarDialogoEditar(objetivo);
        break;
      case 'historial':
        _mostrarHistorialAportes(objetivo);
        break;
      case 'pausar':
        _pausarObjetivo(objetivo);
        break;
      case 'eliminar':
        _confirmarEliminarObjetivo(objetivo);
        break;
    }
  }

  /// Muestra el diálogo para agregar un aporte
  void _mostrarDialogoAporte(Map<String, dynamic> objetivo) {
    final controller = TextEditingController();
    final montoFaltante = objetivo['metaMonto'] - objetivo['montoActual'];
    
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
                Icons.add_circle,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Agregar Aporte'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Objetivo: ${objetivo['titulo']}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Ahorrado: ${_formatearMoneda(objetivo['montoActual'])}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Faltante: ${_formatearMoneda(montoFaltante)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto del Aporte',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Sugerido: ${_formatearMoneda(objetivo['aporteMensual'])}',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
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
              final monto = double.tryParse(controller.text) ?? 0.0;
              if (monto > 0) {
                Navigator.pop(context);
                _registrarAporte(objetivo['id'], monto);
              }
            },
            child: const Text(
              'Agregar Aporte',
              style: TextStyle(color: Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra el diálogo para editar un objetivo
  void _mostrarDialogoEditar(Map<String, dynamic> objetivo) {
    // TODO: Implementar edición de objetivo
    _mostrarInfo('Próximamente: Editar objetivo');
  }

  /// Muestra el historial de aportes de un objetivo
  void _mostrarHistorialAportes(Map<String, dynamic> objetivo) {
    final historial = List<Map<String, dynamic>>.from(objetivo['historialAportes'] ?? []);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Historial de Aportes - ${objetivo['titulo']}'),
        content: SizedBox(
          width: double.maxFinite,
          child: historial.isEmpty
              ? const Text('No hay aportes registrados')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: historial.length,
                  itemBuilder: (context, index) {
                    final aporte = historial[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.add_circle,
                        color: Color(0xFF10B981),
                      ),
                      title: Text(_formatearMoneda(aporte['monto'])),
                      subtitle: Text(_formatearFecha(aporte['fecha'])),
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

  /// Pausa un objetivo temporalmente
  void _pausarObjetivo(Map<String, dynamic> objetivo) {
    // TODO: Implementar pausado de objetivo
    _mostrarInfo('Próximamente: Pausar objetivo');
  }

  /// Confirma la eliminación de un objetivo
  void _confirmarEliminarObjetivo(Map<String, dynamic> objetivo) {
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
            const Text('Eliminar Objetivo'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar el objetivo "${objetivo['titulo']}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar eliminación real
              _mostrarInfo('Próximamente: Eliminar objetivo');
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

  /// Construye el botón flotante para nuevo objetivo
  Widget _buildBotonNuevoObjetivo() {
    return FloatingActionButton.extended(
      onPressed: () => _mostrarDialogoNuevoObjetivo(),
      backgroundColor: const Color(0xFF10B981),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text(
        'Nuevo Objetivo',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Muestra el diálogo para crear un nuevo objetivo
  void _mostrarDialogoNuevoObjetivo() {
    // TODO: Implementar formulario completo para nuevo objetivo
    _mostrarInfo('Próximamente: Formulario de nuevo objetivo');
  }
}
