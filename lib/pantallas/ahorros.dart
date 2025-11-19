import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utilidades/formato_numeros.dart';
import '../firebase/servicios/ahorros_servicio.dart';

/// Pantalla de gestión de metas de ahorro
/// 
/// Esta pantalla permite al usuario:
/// - Ver el resumen de sus ahorros totales
/// - Listar todas sus metas de ahorro
/// - Filtrar y buscar metas específicas
/// - Crear nuevas metas de ahorro
/// - Gestionar metas existentes (editar, eliminar, agregar dinero)
class PantallaAhorros extends StatefulWidget {
  const PantallaAhorros({super.key});

  @override
  State<PantallaAhorros> createState() => _PantallaAhorrosState();
}

class _PantallaAhorrosState extends State<PantallaAhorros> with TickerProviderStateMixin {
    // Controladores para el formulario de nuevo ahorro
    final _formKeyAhorro = GlobalKey<FormState>();
    final TextEditingController _nombreController = TextEditingController();
    final TextEditingController _montoInicialController = TextEditingController();
    final TextEditingController _montoObjetivoController = TextEditingController();
    DateTime? _fechaAhorro = DateTime.now();
    String _categoriaAhorro = 'vacaciones';

  
  // === CONTROLADORES Y SERVICIOS FIREBASE ===
  final TextEditingController _busquedaController = TextEditingController();
  final AhorrosServicio _ahorrosServicio = AhorrosServicio();
  
  // === ANIMACIONES ===
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // === ESTADO DE LA APLICACIÓN ===
  String _modoFiltro = 'todas'; // 'todas', 'activas', 'completadas'
  String _busquedaMeta = '';

  // === CATEGORÍAS DE AHORRO ===
  /// Categorías disponibles para metas de ahorro con colores específicos en tonos verdes
  final List<Map<String, dynamic>> _categorias = [
    {
      'valor': 'vacaciones',
      'nombre': 'Vacaciones',
      'icono': Icons.flight_takeoff_rounded,
      'color': const Color(0xFF16A085), // Verde azulado para ahorros
    },
    {
      'valor': 'casa',
      'nombre': 'Casa',
      'icono': Icons.home_rounded,
      'color': const Color(0xFF2ECC71), // Verde principal para ahorros
    },
    {
      'valor': 'auto',
      'nombre': 'Auto',
      'icono': Icons.directions_car_rounded,
      'color': const Color(0xFF27AE60), // Verde oscuro
    },
    {
      'valor': 'emergencia',
      'nombre': 'Emergencia',
      'icono': Icons.security_rounded,
      'color': const Color(0xFF229954), // Verde seguridad
    },
    {
      'valor': 'educacion',
      'nombre': 'Educación',
      'icono': Icons.school_rounded,
      'color': const Color(0xFF1ABC9C), // Verde educación
    },
    {
      'valor': 'inversion',
      'nombre': 'Inversión',
      'icono': Icons.trending_up_rounded,
      'color': const Color(0xFF138D75), // Verde inversión
    },
    {
      'valor': 'salud',
      'nombre': 'Salud',
      'icono': Icons.health_and_safety_rounded,
      'color': const Color(0xFF117A65), // Verde salud
    },
    {
      'valor': 'otros',
      'nombre': 'Otros',
      'icono': Icons.more_horiz_rounded,
      'color': const Color(0xFF0E6B5E), // Verde otros
    },
  ];

  // === INICIALIZACIÓN ===
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Inicializa las animaciones de la pantalla
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  // === INTERFAZ PRINCIPAL ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 120,
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.savings_rounded,
                    color: Color(0xFF8570FA), // Morado solicitado para ahorros
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AHORROS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8570FA),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Gestiona y alcanza tus metas de ahorro',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _construirResumenFinanciero(),
              const SizedBox(height: 24),
              _construirBarraBusqueda(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Metas de ahorro',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    GestureDetector(
                      onTap: _mostrarDialogoAgregarMeta,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8570FA), // Morado vibrante solicitado
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Nuevo ahorro',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _construirListaMetas(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === COMPONENTES DE LA INTERFAZ ===
  
  /// Construye la barra de búsqueda y filtros
  Widget _construirBarraBusqueda() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _busquedaController,
                onChanged: (value) {
                  setState(() {
                    _busquedaMeta = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre de meta...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                  suffixIcon: _busquedaController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _busquedaController.clear();
                              _busquedaMeta = '';
                            });
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Color(0xFF2ECC71).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _construirBotonFiltros(),
        ],
      ),
    );
  }

  /// Construye el botón de filtros desplegable
  Widget _construirBotonFiltros() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.filter_alt_rounded, color: Color(0xFF8570FA)),
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF8570FA), width: 0.7),
        ),
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 6),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, color: Color(0xFF8570FA), size: 18),
                const SizedBox(width: 8),
                Text('Filtros de metas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF8570FA))),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          _crearItemFiltro('todas', 'Todas las metas', Icons.list_rounded),
          _crearItemFiltro('activas', 'Metas activas', Icons.play_circle_outline_rounded),
          _crearItemFiltro('completadas', 'Metas completadas', Icons.check_circle_rounded),
        ],
        onSelected: (value) {
          setState(() {
            _modoFiltro = value;
            _busquedaController.text = '';
            _busquedaMeta = '';
          });
        },
      ),
    );
  }

  /// Crea un item del menú de filtros
  PopupMenuItem<String> _crearItemFiltro(String valor, String texto, IconData icono) {
    return PopupMenuItem(
      value: valor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icono, color: _modoFiltro == valor ? Color(0xFF8570FA) : Colors.grey, size: 20),
          const SizedBox(width: 10),
          Text(texto, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          if (_modoFiltro == valor) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle_rounded, color: Color(0xFF8570FA), size: 18),
          ]
        ],
      ),
    );
  }

  /// Construye el resumen financiero de ahorros
  Widget _construirResumenFinanciero() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _ahorrosServicio.obtenerMetasAhorro(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 120);
        }
        double totalAhorrado = 0;
        double totalMetas = 0;
        int totalMetasCount = snapshot.data!.length;
        int metasCompletadas = 0;
        for (var meta in snapshot.data!) {
          final montoActual = (meta['montoActual'] ?? 0.0).toDouble();
          final montoObjetivo = (meta['montoObjetivo'] ?? 0.0).toDouble();
          totalAhorrado += montoActual;
          totalMetas += montoObjetivo;
          if (montoActual >= montoObjetivo) {
            metasCompletadas++;
          }
        }
        final double progresoPorcentaje = totalMetas > 0 ? (totalAhorrado / totalMetas) * 100 : 0;
        return Container(
          margin: const EdgeInsets.only(top: 32, left: 20, right: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF8570FA),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8570FA).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Ahorrado',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalMetasCount meta${totalMetasCount != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatearMoneda(totalAhorrado),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meta Total',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatearMoneda(totalMetas),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progreso',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${progresoPorcentaje.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completadas',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$metasCompletadas/$totalMetasCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye la lista de metas de ahorro
  Widget _construirListaMetas() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _ahorrosServicio.obtenerMetasAhorro(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8570FA)),
            ),
          );
        }
        if (snapshot.hasError) {
          return _construirEstadoError();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _construirEstadoVacio();
        }
        // Filtrado por búsqueda y estado
        var metas = snapshot.data!;
        // Filtrado manual
        if (_busquedaMeta.isNotEmpty) {
          metas = metas.where((meta) {
            final nombre = (meta['nombre'] ?? '').toString().toLowerCase();
            final categoria = (meta['categoria'] ?? '').toString().toLowerCase();
            return nombre.contains(_busquedaMeta.toLowerCase()) || categoria.contains(_busquedaMeta.toLowerCase());
          }).toList();
        }
        if (_modoFiltro == 'activas') {
          metas = metas.where((meta) {
            final montoActual = (meta['montoActual'] ?? 0.0).toDouble();
            final montoObjetivo = (meta['montoObjetivo'] ?? 0.0).toDouble();
            return montoActual < montoObjetivo;
          }).toList();
        } else if (_modoFiltro == 'completadas') {
          metas = metas.where((meta) {
            final montoActual = (meta['montoActual'] ?? 0.0).toDouble();
            final montoObjetivo = (meta['montoObjetivo'] ?? 0.0).toDouble();
            return montoActual >= montoObjetivo;
          }).toList();
        }
        // Ordenar por fecha de creación (más recientes primero)
        metas.sort((a, b) {
          final fechaA = a['fechaCreacion'] as DateTime?;
          final fechaB = b['fechaCreacion'] as DateTime?;
          if (fechaA == null && fechaB == null) return 0;
          if (fechaA == null) return 1;
          if (fechaB == null) return -1;
          return fechaB.compareTo(fechaA);
        });
        if (metas.isEmpty) {
          return _construirEstadoSinResultados();
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: metas.length,
          itemBuilder: (context, index) {
            final meta = metas[index];
            final id = meta['id'] as String;
            return _construirTarjetaMeta(id, meta, index);
          },
        );
      },
    );
  }

  /// Filtra las metas según los criterios de búsqueda y filtros
  List<QueryDocumentSnapshot> _filtrarMetas(List<QueryDocumentSnapshot> docs) {
    var filteredDocs = docs.where((doc) {
      final meta = doc.data() as Map<String, dynamic>;
      bool match = true;
      
      // Filtro por búsqueda
      if (_busquedaMeta.isNotEmpty) {
        final nombre = (meta['nombre'] ?? '').toString().toLowerCase();
        final categoria = (meta['categoria'] ?? '').toString().toLowerCase();
        match = nombre.contains(_busquedaMeta.toLowerCase()) ||
                categoria.contains(_busquedaMeta.toLowerCase());
      }
      
      // Filtro por estado
      if (_modoFiltro == 'activas') {
        final montoActual = (meta['montoActual'] ?? 0.0).toDouble();
        final montoObjetivo = (meta['montoObjetivo'] ?? 0.0).toDouble();
        match = match && (montoActual < montoObjetivo);
      } else if (_modoFiltro == 'completadas') {
        final montoActual = (meta['montoActual'] ?? 0.0).toDouble();
        final montoObjetivo = (meta['montoObjetivo'] ?? 0.0).toDouble();
        match = match && (montoActual >= montoObjetivo);
      }
      
      return match;
    }).toList();

    // Ordenamiento por fecha de creación (más recientes primero)
    filteredDocs.sort((a, b) {
      final fechaA = (a.data() as Map<String, dynamic>)['fechaCreacion'] as Timestamp?;
      final fechaB = (b.data() as Map<String, dynamic>)['fechaCreacion'] as Timestamp?;
      if (fechaA == null && fechaB == null) return 0;
      if (fechaA == null) return 1;
      if (fechaB == null) return -1;
      return fechaB.compareTo(fechaA);
    });

    return filteredDocs;
  }

  // === MÉTODOS AUXILIARES ===
  
  /// Construye el estado vacío cuando no hay metas
  Widget _construirEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF8570FA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.savings_outlined,
              size: 60,
              color: Color(0xFF8570FA),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tienes metas de ahorro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D29),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera meta de ahorro para\ncomenzar a construir tu futuro financiero',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el estado de error
  Widget _construirEstadoError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar las metas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta nuevamente más tarde',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el estado cuando no hay resultados de búsqueda
  Widget _construirEstadoSinResultados() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No se encontraron metas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro término de búsqueda',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la tarjeta individual de meta de ahorro
  Widget _construirTarjetaMeta(String id, Map<String, dynamic> meta, int index) {
    final categoria = meta['categoria'] ?? 'otros';
    final categoriaInfo = _categorias.firstWhere(
      (cat) => cat['valor'] == categoria,
      orElse: () => _categorias.last,
    );
    
    final montoActual = (meta['montoActual'] ?? 0.0).toDouble();
    final montoObjetivo = (meta['montoObjetivo'] ?? 0.0).toDouble();
    final progreso = montoObjetivo > 0 ? (montoActual / montoObjetivo) : 0.0;
    final fechaObjetivo = (meta['fechaObjetivo'] as Timestamp?)?.toDate() ?? DateTime.now();
    final diasRestantes = fechaObjetivo.difference(DateTime.now()).inDays;
    final esCompletada = montoActual >= montoObjetivo;

    return Container(
      margin: EdgeInsets.only(
        bottom: 16,
        top: index == 0 ? 8 : 0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _mostrarDetallesMeta(id, meta),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: esCompletada
                  ? Border.all(color: Color(0xFF8570FA), width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _construirCabeceraTarjeta(categoriaInfo, meta, esCompletada, id),
                const SizedBox(height: 16),
                _construirProgresoDinero(montoActual, montoObjetivo, diasRestantes),
                const SizedBox(height: 16),
                _construirBarraProgreso(progreso, categoriaInfo['color'], esCompletada),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye la cabecera de la tarjeta de meta
  Widget _construirCabeceraTarjeta(Map<String, dynamic> categoriaInfo, Map<String, dynamic> meta, bool esCompletada, String id) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: categoriaInfo['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            categoriaInfo['icono'],
            color: categoriaInfo['color'],
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meta['nombre'] ?? 'Meta sin nombre',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D29),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                categoriaInfo['nombre'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _construirAccionesMeta(esCompletada, id, meta),
      ],
    );
  }

  /// Construye las acciones disponibles para cada meta
  Widget _construirAccionesMeta(bool esCompletada, String id, Map<String, dynamic> meta) {
    if (esCompletada) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Color(0xFF8570FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'COMPLETADA',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[400]),
      onSelected: (value) => _manejarAccionMeta(value, id, meta),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'agregar',
          child: ListTile(
            leading: Icon(Icons.add_circle),
            title: Text('Agregar dinero'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'editar',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Editar meta'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'eliminar',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Eliminar', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  /// Construye la información del progreso monetario
  Widget _construirProgresoDinero(double montoActual, double montoObjetivo, int diasRestantes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progreso actual',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${_formatearMoneda(montoActual)} de \$${_formatearMoneda(montoObjetivo)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D29),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              diasRestantes >= 0 ? 'Días restantes' : 'Días de retraso',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${diasRestantes.abs()}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: diasRestantes >= 0 ? Color(0xFF8570FA) : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye la barra de progreso visual
  Widget _construirBarraProgreso(double progreso, Color color, bool esCompletada) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${(progreso * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8570FA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progreso,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              esCompletada ? Color(0xFF8570FA) : color,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  /// Formatea las cantidades monetarias para mostrar
  String _formatearMoneda(double cantidad) {
    return FormatoNumeros.formatearParaMostrar(cantidad);
  }

  // === MÉTODOS DE ACCIÓN ===

  /// Maneja las acciones del menú contextual de cada meta
  void _manejarAccionMeta(String accion, String id, Map<String, dynamic> meta) {
    switch (accion) {
      case 'agregar':
        _mostrarDialogoAgregarMonto(id, meta);
        break;
      case 'editar':
        _mostrarDialogoEditarMeta(id, meta);
        break;
      case 'eliminar':
        _confirmarEliminarMeta(id, meta['nombre'] ?? 'esta meta');
        break;
    }
  }

  /// Muestra el diálogo para agregar nueva meta
  void _mostrarDialogoAgregarMeta() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.80,
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8570FA),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.savings_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('Nuevo ahorro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKeyAhorro,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nombre del ahorro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nombreController,
                            validator: (value) => value == null || value.isEmpty ? 'Ingresa el nombre del ahorro' : null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('Monto inicial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _montoInicialController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Ingresa el monto inicial';
                              final num? monto = num.tryParse(value.replaceAll(',', '.'));
                              if (monto == null || monto < 0) return 'Monto inválido';
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixText: ' 24 ',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('Monto objetivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _montoObjetivoController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Ingresa el monto objetivo';
                              final num? monto = num.tryParse(value.replaceAll(',', '.'));
                              if (monto == null || monto <= 0) return 'Monto inválido';
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixText: ' 24 ',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('Fecha objetivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _fechaAhorro ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setModalState(() => _fechaAhorro = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFF8570FA), width: 2),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade50,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, color: Color(0xFF8570FA)),
                                  const SizedBox(width: 12),
                                  Text(_fechaAhorro != null ? '${_fechaAhorro!.day}/${_fechaAhorro!.month}/${_fechaAhorro!.year}' : 'Selecciona una fecha'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('Categoría', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _categoriaAhorro,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            items: _categorias.map((cat) => DropdownMenuItem<String>(
                              value: cat['valor'] as String,
                              child: Row(
                                children: [
                                  Icon(cat['icono'], color: Color(0xFF8570FA)),
                                  const SizedBox(width: 8),
                                  Text(cat['nombre']),
                                ],
                              ),
                            )).toList(),
                            onChanged: (val) => setModalState(() => _categoriaAhorro = val ?? 'vacaciones'),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                                  child: Text('Cancelar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKeyAhorro.currentState?.validate() ?? false) {
                                      // Aquí iría la lógica para guardar el ahorro en Firebase
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Ahorro creado correctamente'),
                                          backgroundColor: Color(0xFF8570FA),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF8570FA),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  /// Muestra los detalles de una meta
  void _mostrarDetallesMeta(String metaId, Map<String, dynamic> meta) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalles de: ${meta['nombre'] ?? 'Meta sin nombre'}'),
        backgroundColor: Color(0xFF8570FA),
      ),
    );
  }

  /// Muestra el diálogo para editar meta
  void _mostrarDialogoEditarMeta(String metaId, Map<String, dynamic> meta) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar: ${meta['nombre'] ?? 'Meta sin nombre'}'),
        backgroundColor: Color(0xFF8570FA),
      ),
    );
  }

  /// Muestra el diálogo para agregar monto a una meta
  void _mostrarDialogoAgregarMonto(String metaId, Map<String, dynamic> meta) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agregar dinero a: ${meta['nombre'] ?? 'Meta sin nombre'}'),
        backgroundColor: Color(0xFF8570FA),
      ),
    );
  }

  /// Confirma la eliminación de una meta
  Future<void> _confirmarEliminarMeta(String id, String nombre) async {
    final bool? confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Eliminar meta'),
        content: Text('¿Estás seguro de que deseas eliminar la meta "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      final error = await _ahorrosServicio.eliminarMetaAhorro(id);
      if (error == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Meta "$nombre" eliminada correctamente'),
              backgroundColor: Color(0xFF8570FA),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}