import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/autenticacion_servicio.dart';
import '../firebase/base_datos_servicio.dart';
import '../login/iniciosesion.dart';
import 'ingresos.dart';
import 'gastos.dart';
import 'cuentas.dart';
import 'ahorros.dart';
import 'deudas.dart';


import 'configuracion.dart';
import 'perfil.dart';
import 'herramientas.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal>
    with TickerProviderStateMixin {
  final AutenticacionServicio _authService = AutenticacionServicio();
  final BaseDatosServicio _baseDatosService = BaseDatosServicio();
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _nombreUsuario = 'Usuario'; // Valor por defecto

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );


    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _cargarNombreUsuario(); // Cargar el nombre del usuario
  }

  /// Carga el nombre del usuario desde Firebase Auth o Firestore
  Future<void> _cargarNombreUsuario() async {
    try {
      // Primero intentar obtener desde Firebase Auth (displayName)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
        // Obtener solo el primer nombre del displayName
        final nombreCompleto = user.displayName!;
        final primerNombre = nombreCompleto.split(' ')[0];
        setState(() {
          _nombreUsuario = primerNombre;
        });
        return; // Salir si encontramos el nombre en Auth
      }
      
      // Si no hay displayName, intentar desde Firestore
      final perfil = await _baseDatosService.obtenerPerfilUsuario();
      if (perfil != null && perfil.exists) {
        final datos = perfil.data() as Map<String, dynamic>?;
        if (datos != null && datos['nombre'] != null) {
          // Obtener solo el primer nombre para el saludo
          final nombreCompleto = datos['nombre'] as String;
          final primerNombre = nombreCompleto.split(' ')[0];
          setState(() {
            _nombreUsuario = primerNombre;
          });
        }
      }
    } catch (e) {
      print('Error al cargar nombre del usuario: $e');
      // Mantener el valor por defecto "Usuario"
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _cerrarSesion() async {
    final bool? confirmacion = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 24,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que deseas cerrar sesión? Serás redirigido al menú principal.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmacion == true) {
      try {
        await _authService.cerrarSesion();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const InicioSesionScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: $e'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }



  Widget _buildPersonalizedGreeting() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF2ecc71),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo y nombre app centrados arriba
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/logo.png',
                    width: 38,
                    height: 38,
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    'Wallet Flow',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Foto de perfil y mensaje de bienvenida
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 4;
                      });
                    },
            child: Container(
                      width: 62,
                      height: 62,
              margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildProfileImage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, $_nombreUsuario',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 50,
          right: 0,
          child: IconButton(
            onPressed: _cerrarSesion,
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
              size: 28,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
            ),
            tooltip: 'Cerrar sesión',
          ),
        ),
      ],
    );
  }

  /// Construye la imagen de perfil con fallback a avatar por defecto
  Widget _buildProfileImage() {
    final user = FirebaseAuth.instance.currentUser;
    final photoURL = user?.photoURL;
    
    if (photoURL != null && photoURL.isNotEmpty) {
      return Image.network(
        photoURL,
        fit: BoxFit.cover,
        width: 52,
        height: 52,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  /// Avatar por defecto cuando no hay imagen
  Widget _buildDefaultAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFF10B981),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _nombreUsuario.isNotEmpty ? _nombreUsuario[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }


  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  title: 'Ingresos',
                  amount: '\$4,230',
                  icon: Icons.trending_up_rounded,
                  color: Colors.green.shade600,
                  onTap: () => _navigateToSection(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  title: 'Gastos',
                  amount: '\$1,892',
                  icon: Icons.trending_down_rounded,
                  color: Colors.red.shade600,
                  onTap: () => _navigateToSection(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
                Expanded(
                  child: _buildSummaryItem(
                    title: 'Cuentas',
                    amount: '\$8,120',
                    icon: Icons.account_balance_rounded,
                    color: Colors.purple.shade600,
                    onTap: () => _navigateToSection(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    title: 'Deudas',
                    amount: '\$2,341',
                    icon: Icons.credit_card_rounded,
                    color: Colors.orange.shade600,
                    onTap: () => _navigateToSection(5),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 16,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey.shade400,
                    size: 12,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 45), // Más espacio para bajar la tarjeta de bienvenida
            // Saludo personalizado
            _buildPersonalizedGreeting(),
            const SizedBox(height: 20),
            // Resumen financiero compacto
            const Text(
              'Resumen Financiero',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 10),
            _buildFinancialSummary(),
            const SizedBox(height: 20),
            // Menú de servicios organizados
            const Text(
              'Servicios Financieros',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 10),
            _buildFinancialServicesMenu(),
          ],
        ),
      ),
    );
  }

  void _navigateToSection(int index) {
    HapticFeedback.lightImpact();
    if (index == 7) {
      // Navegar a la pantalla de herramientas
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PantallaHerramientas()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _handleBottomNavigation(int index) {
    HapticFeedback.lightImpact();
    
    // Para navegación del bottom nav, permitir navegación directa a todas las secciones principales
    setState(() {
      _selectedIndex = index;
    });
  }


  Widget _buildFinancialServicesMenu() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Primera fila - Ahorros y Deudas
          Row(
            children: [
              _buildMenuCard(
                title: 'Ahorros',
                icon: Icons.savings_rounded,
                color: const Color(0xFF10B981),
                onTap: () => _navigateToSection(6),
              ),
              const SizedBox(width: 12),
              _buildMenuCard(
                title: 'Deudas',
                icon: Icons.credit_card_rounded,
                color: Colors.orange.shade600,
                onTap: () => _navigateToSection(5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Segunda fila - Herramientas y Configuración
          Row(
            children: [
              _buildMenuCard(
                title: 'Herramientas',
                icon: Icons.build_outlined,
                color: Colors.indigo.shade600,
                onTap: () => _navigateToSection(7),
              ),
              const SizedBox(width: 12),
              _buildMenuCard(
                title: 'Configuración',
                icon: Icons.settings_outlined,
                color: Colors.grey.shade700,
                onTap: () => _navigateToSection(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
  required String title,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Subtítulo eliminado
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderScreen(String title, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              size: 64,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Funcionalidad en desarrollo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colores personalizados para cada ítem
    final List<Color> itemColors = [
      Color(0xFF2563EB), // Inicio - azul
      Color(0xFF2ECC71), // Ingresos - verde (#2ecc71)
      Color(0xFFEF4444), // Gastos - rojo
      Color(0xFF007bff), // Cuentas - azul
      Color(0xFFF59E42), // Perfil - naranja
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),         // 0 - Dashboard
          const PantallaIngresos(),  // 1 - Ingresos
          const PantallaGastos(),    // 2 - Gastos
          const PantallaCuentas(),   // 3 - Cuentas
          const PantallaPerfil(),    // 4 - Perfil
          const PantallaDeudas(),    // 5 - Deudas
          const PantallaAhorros(),   // 6 - Ahorros (antes era 7)
          _buildPlaceholderScreen('Herramientas', Icons.build_outlined, Colors.indigo.shade600), // 7 - Herramientas (antes era 9)
          const PantallaConfiguracion(), // 8 - Configuración (antes era 10)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex <= 4 ? _selectedIndex : 0,
        onTap: _handleBottomNavigation,
        backgroundColor: Colors.white,
        selectedFontSize: 13,
        unselectedFontSize: 12,
        elevation: 10,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined, color: _selectedIndex == 0 ? itemColors[0] : Colors.grey.shade400),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_outlined, color: _selectedIndex == 1 ? itemColors[1] : Colors.grey.shade400),
            label: 'Ingresos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined, color: _selectedIndex == 2 ? itemColors[2] : Colors.grey.shade400),
            label: 'Gastos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_rounded, color: _selectedIndex == 3 ? itemColors[3] : Colors.grey.shade400),
            label: 'Cuentas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded, color: _selectedIndex == 4 ? itemColors[4] : Colors.grey.shade400),
            label: 'Perfil',
          ),
        ],
        selectedItemColor: itemColors[_selectedIndex <= 4 ? _selectedIndex : 0],
        unselectedItemColor: Colors.grey.shade400,
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header del drawer mejorado
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF10B981),
                  Color(0xFF059669),
                ],
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Wallet Flow',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Usuario Premium',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'usuario@example.com',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.diamond_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Cuenta Premium',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Acceso rápido
                _buildMenuSection(
                  title: 'Acceso Rápido',
                  items: [
                    _buildDrawerMenuItem(
                      icon: Icons.dashboard_outlined,
                      title: 'Dashboard',
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToSection(0);
                      },
                    ),
                    _buildDrawerMenuItem(
                      icon: Icons.person_rounded,
                      title: 'Mi Perfil',
                      color: Colors.purple.shade600,
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToSection(4);
                      },
                    ),
                    _buildDrawerMenuItem(
                      icon: Icons.analytics_outlined,
                      title: 'Reportes',
                      color: Colors.cyan.shade600,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implementar reportes
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Gestión financiera
                _buildMenuSection(
                  title: 'Gestión Financiera',
                  items: [
                    _buildDrawerMenuItem(
                      icon: Icons.credit_card_rounded,
                      title: 'Deudas',
                      color: Colors.orange.shade600,
                      badge: '2',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToSection(5);
                      },
                    ),

                    _buildDrawerMenuItem(
                      icon: Icons.account_balance_rounded,
                      title: 'Cuentas Bancarias',
                      color: Colors.purple.shade600,
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToSection(3); // Índice correcto para Cuentas
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Herramientas
                _buildMenuSection(
                  title: 'Herramientas',
                  items: [

                    _buildDrawerMenuItem(
                      icon: Icons.build_outlined,
                      title: 'Calculadoras',
                      color: Colors.indigo.shade600,
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToSection(7);
                      },
                    ),
                    _buildDrawerMenuItem(
                      icon: Icons.file_download_outlined,
                      title: 'Exportar Datos',
                      color: Colors.amber.shade600,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implementar exportación
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Configuración
                _buildMenuSection(
                  title: 'Configuración',
                  items: [
                    _buildDrawerMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Ajustes',
                      color: Colors.grey.shade700,
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToSection(8);
                      },
                    ),
                    _buildDrawerMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notificaciones',
                      color: Colors.pink.shade600,
                      badge: '3',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implementar notificaciones
                      },
                    ),
                    _buildDrawerMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Ayuda y Soporte',
                      color: Colors.lime.shade600,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implementar ayuda
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade600,
                  size: 20,
                ),
              ),
              title: Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              ),
              onTap: _cerrarSesion,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildDrawerMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            fontSize: 15,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 16,
              ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
