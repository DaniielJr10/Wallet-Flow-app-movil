import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../firebase/base_datos_servicio.dart';

class PantallaAhorros extends StatefulWidget {
  const PantallaAhorros({super.key});

  @override
  State<PantallaAhorros> createState() => _PantallaAhorrosState();
}

class _PantallaAhorrosState extends State<PantallaAhorros>
    with TickerProviderStateMixin {
  final BaseDatosServicio _baseDatosService = BaseDatosServicio();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<Map<String, dynamic>> _metas = [];
  bool _isLoading = true;
  double _totalAhorrado = 0.0;
  double _totalMetas = 0.0;

  // Categorías de ahorro disponibles
  final List<Map<String, dynamic>> _categorias = [
    {
      'nombre': 'Vacaciones',
      'icono': Icons.flight_takeoff,
      'color': const Color(0xFF3B82F6),
      'gradiente': [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]
    },
    {
      'nombre': 'Casa',
      'icono': Icons.home,
      'color': const Color(0xFF10B981),
      'gradiente': [const Color(0xFF10B981), const Color(0xFF059669)]
    },
    {
      'nombre': 'Auto',
      'icono': Icons.directions_car,
      'color': const Color(0xFFF59E0B),
      'gradiente': [const Color(0xFFF59E0B), const Color(0xFFD97706)]
    },
    {
      'nombre': 'Emergencia',
      'icono': Icons.security,
      'color': const Color(0xFFEF4444),
      'gradiente': [const Color(0xFFEF4444), const Color(0xFFDC2626)]
    },
    {
      'nombre': 'Educación',
      'icono': Icons.school,
      'color': const Color(0xFF8B5CF6),
      'gradiente': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)]
    },
    {
      'nombre': 'Inversión',
      'icono': Icons.trending_up,
      'color': const Color(0xFF06B6D4),
      'gradiente': [const Color(0xFF06B6D4), const Color(0xFF0891B2)]
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _cargarMetas();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  Future<void> _cargarMetas() async {
    try {
      // TODO: Implementar carga desde Firebase
      // Por ahora usamos datos de ejemplo
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _metas = [
          {
            'id': '1',
            'nombre': 'Vacaciones en Europa',
            'categoria': 'Vacaciones',
            'montoObjetivo': 5000.0,
            'montoActual': 2800.0,
            'fechaObjetivo': DateTime.now().add(const Duration(days: 180)),
            'descripcion': 'Viaje de 15 días por Europa visitando París, Roma y Barcelona',
          },
          {
            'id': '2',
            'nombre': 'Fondo de Emergencia',
            'categoria': 'Emergencia',
            'montoObjetivo': 10000.0,
            'montoActual': 6500.0,
            'fechaObjetivo': DateTime.now().add(const Duration(days: 365)),
            'descripcion': 'Fondo para gastos inesperados equivalente a 6 meses de gastos',
          },
          {
            'id': '3',
            'nombre': 'Auto Nuevo',
            'categoria': 'Auto',
            'montoObjetivo': 25000.0,
            'montoActual': 8200.0,
            'fechaObjetivo': DateTime.now().add(const Duration(days: 730)),
            'descripcion': 'Ahorro para la cuota inicial de un auto híbrido',
          },
        ];
        
        _calcularTotales();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calcularTotales() {
    _totalAhorrado = _metas.fold(0.0, (sum, meta) => sum + (meta['montoActual'] ?? 0.0));
    _totalMetas = _metas.fold(0.0, (sum, meta) => sum + (meta['montoObjetivo'] ?? 0.0));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading ? _buildLoadingScreen() : _buildMainContent(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando tus metas de ahorro...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildResumenCard(),
                  const SizedBox(height: 24),
                  _buildSeccionMetas(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF10B981),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Mis Ahorros',
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
      actions: [
        IconButton(
          onPressed: _cargarMetas,
          icon: const Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildResumenCard() {
    final double progresoPorcentaje = _totalMetas > 0 ? (_totalAhorrado / _totalMetas) * 100 : 0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF334155),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.savings,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Resumen de Ahorros',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Ahorrado',
                  '\$${_totalAhorrado.toStringAsFixed(0)}',
                  Icons.account_balance_wallet,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Meta Total',
                  '\$${_totalMetas.toStringAsFixed(0)}',
                  Icons.flag,
                  const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progreso General',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${progresoPorcentaje.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progresoPorcentaje / 100,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionMetas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Mis Metas de Ahorro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_metas.isEmpty)
          _buildEstadoVacio()
        else
          ..._metas.asMap().entries.map((entry) {
            final index = entry.key;
            final meta = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildMetaCard(meta, index),
            );
          }),
      ],
    );
  }

  Widget _buildEstadoVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.savings_outlined,
              size: 48,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes metas de ahorro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera meta de ahorro y comienza a construir tu futuro financiero',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogoNuevaMeta(),
            icon: const Icon(Icons.add),
            label: const Text('Crear Meta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(Map<String, dynamic> meta, int index) {
    final categoria = _categorias.firstWhere(
      (cat) => cat['nombre'] == meta['categoria'],
      orElse: () => _categorias[0],
    );
    
    final double progreso = (meta['montoActual'] ?? 0.0) / (meta['montoObjetivo'] ?? 1.0);
    final DateTime fechaObjetivo = meta['fechaObjetivo'] ?? DateTime.now();
    final int diasRestantes = fechaObjetivo.difference(DateTime.now()).inDays;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: categoria['gradiente'],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: categoria['color'].withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _mostrarDetallesMeta(meta),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                categoria['icono'],
                                color: Colors.white,
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
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    meta['categoria'] ?? 'Sin categoría',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                              onSelected: (value) {
                                switch (value) {
                                  case 'agregar':
                                    _mostrarDialogoAgregarMonto(meta);
                                    break;
                                  case 'editar':
                                    _mostrarDialogoEditarMeta(meta);
                                    break;
                                  case 'eliminar':
                                    _confirmarEliminarMeta(meta);
                                    break;
                                }
                              },
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${(meta['montoActual'] ?? 0.0).toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'de \$${(meta['montoObjetivo'] ?? 0.0).toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progreso',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(progreso * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 1000 + (index * 200)),
                                tween: Tween(begin: 0.0, end: progreso),
                                builder: (context, animatedProgress, child) {
                                  return LinearProgressIndicator(
                                    value: animatedProgress,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    minHeight: 8,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              diasRestantes > 0 
                                ? '$diasRestantes días restantes'
                                : diasRestantes == 0 
                                  ? '¡Hoy es el día!'
                                  : '${-diasRestantes} días de retraso',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _mostrarDialogoNuevaMeta(),
      backgroundColor: const Color(0xFF10B981),
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(Icons.add),
      label: const Text(
        'Nueva Meta',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _mostrarDialogoNuevaMeta() {
    // TODO: Implementar diálogo para crear nueva meta
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Crear nueva meta'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _mostrarDetallesMeta(Map<String, dynamic> meta) {
    // TODO: Implementar pantalla de detalles de meta
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalles de: ${meta['nombre']}'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _mostrarDialogoAgregarMonto(Map<String, dynamic> meta) {
    // TODO: Implementar diálogo para agregar monto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agregar dinero a: ${meta['nombre']}'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _mostrarDialogoEditarMeta(Map<String, dynamic> meta) {
    // TODO: Implementar diálogo para editar meta
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar: ${meta['nombre']}'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _confirmarEliminarMeta(Map<String, dynamic> meta) {
    // TODO: Implementar confirmación de eliminación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Eliminar: ${meta['nombre']}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}