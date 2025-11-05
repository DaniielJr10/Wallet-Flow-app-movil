import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../firebase/autenticacion_servicio.dart';
import '../login/iniciosesion.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal>
    with TickerProviderStateMixin {
  final AutenticacionServicio _authService = AutenticacionServicio();
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
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

  Widget _buildFinancialCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                amount,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
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

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header personalizado
            Container(
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
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido de vuelta',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tu balance total',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _cerrarSesion,
                        icon: const Icon(
                          Icons.logout_rounded,
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
                  const Text(
                    '\$12,345.67',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+2.5% desde el mes pasado',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // ...existing code...
            
            // Resumen financiero
            const Text(
              'Resumen Financiero',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            _buildFinancialCard(
              title: 'Ingresos del Mes',
              amount: '\$4,230.00',
              icon: Icons.attach_money_rounded,
              color: Colors.green.shade600,
              subtitle: 'Último: Salario \$3,500',
              onTap: () => _navigateToSection(1),
            ),
            _buildFinancialCard(
              title: 'Ahorros Totales',
              amount: '\$5,240.00',
              icon: Icons.savings_rounded,
              color: const Color(0xFF10B981),
              subtitle: '3 objetivos activos',
              onTap: () => _navigateToSection(3),
            ),
            _buildFinancialCard(
              title: 'Gastos del Mes',
              amount: '\$1,892.35',
              icon: Icons.payment_rounded,
              color: Colors.red.shade600,
              subtitle: 'Último: Supermercado \$45.20',
              onTap: () => _navigateToSection(2),
            ),
            _buildFinancialCard(
              title: 'Inversiones',
              amount: '\$8,750.22',
              icon: Icons.trending_up_rounded,
              color: Colors.blue.shade600,
              subtitle: '+12.5% este mes',
              onTap: () => _navigateToSection(5),
            ),
            _buildFinancialCard(
              title: 'Deudas Pendientes',
              amount: '\$2,340.80',
              icon: Icons.credit_card_rounded,
              color: Colors.orange.shade600,
              subtitle: '2 pagos próximos',
              onTap: () => _navigateToSection(4),
            ),
            const SizedBox(height: 32),
            // Menú de servicios organizados
            const Text(
              'Servicios Financieros',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            _buildFinancialServicesMenu(),
            const SizedBox(height: 32),
            // Análisis rápido
            const Text(
              'Análisis Rápido',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickAnalysis(),
            
            const SizedBox(height: 100), // Espacio extra para el bottom nav
          ],
        ),
      ),
    );
  }

  void _navigateToSection(int index) {
    HapticFeedback.lightImpact();
    
    // Si se presiona "Más" (índice 4), abrir el drawer
    if (index == 4) {
      Scaffold.of(context).openDrawer();
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildQuickAnalysis() {
    return Row(
      children: [
        Expanded(
          child: _buildAnalysisCard(
            title: 'Balance',
            value: '+\$2,337.65',
            subtitle: 'vs mes anterior',
            icon: Icons.trending_up_rounded,
            color: Colors.green.shade600,
            isPositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAnalysisCard(
            title: 'Gastos',
            value: '-15.2%',
            subtitle: 'vs mes anterior',
            icon: Icons.trending_down_rounded,
            color: Colors.red.shade600,
            isPositive: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAnalysisCard(
            title: 'Ahorros',
            value: '+8.5%',
            subtitle: 'meta cumplida',
            icon: Icons.savings_rounded,
            color: const Color(0xFF10B981),
            isPositive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
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
      ),
      child: Column(
        children: [
          // Primera fila
          Row(
            children: [
              _buildMenuCard(
                title: 'Deudas',
                subtitle: 'Gestionar',
                icon: Icons.credit_card_rounded,
                color: Colors.orange.shade600,
                onTap: () => _navigateToSection(4),
              ),
              const SizedBox(width: 12),
              _buildMenuCard(
                title: 'Inversiones',
                subtitle: 'Portafolio',
                icon: Icons.trending_up_rounded,
                color: Colors.blue.shade600,
                onTap: () => _navigateToSection(5),
              ),
              const SizedBox(width: 12),
              _buildMenuCard(
                title: 'Cuentas',
                subtitle: 'Bancarias',
                icon: Icons.account_balance_rounded,
                color: Colors.purple.shade600,
                onTap: () => _navigateToSection(6),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Segunda fila
          Row(
            children: [
              _buildMenuCard(
                title: 'Objetivos',
                subtitle: 'Financieros',
                icon: Icons.flag_outlined,
                color: Colors.teal.shade600,
                onTap: () => _navigateToSection(7),
              ),
              const SizedBox(width: 12),
              _buildMenuCard(
                title: 'Herramientas',
                subtitle: 'Calculadoras',
                icon: Icons.build_outlined,
                color: Colors.indigo.shade600,
                onTap: () => _navigateToSection(8),
              ),
              const SizedBox(width: 12),
              _buildMenuCard(
                title: 'Configuración',
                subtitle: 'Ajustes',
                icon: Icons.settings_outlined,
                color: Colors.grey.shade700,
                onTap: () => _navigateToSection(9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(), // 0 - Dashboard principal
          _buildPlaceholderScreen('Ingresos', Icons.attach_money_rounded, Colors.green.shade600), // 1 - Ingresos
          _buildPlaceholderScreen('Gastos', Icons.payment_rounded, Colors.red.shade600), // 2 - Gastos
          _buildPlaceholderScreen('Ahorros', Icons.savings_rounded, const Color(0xFF10B981)), // 3 - Ahorros
          _buildPlaceholderScreen('Deudas', Icons.credit_card_rounded, Colors.orange.shade600), // 4 - Deudas
          _buildPlaceholderScreen('Inversiones', Icons.trending_up_rounded, Colors.blue.shade600), // 5 - Inversiones
          _buildPlaceholderScreen('Cuentas', Icons.account_balance_rounded, Colors.purple.shade600), // 6 - Cuentas
          _buildPlaceholderScreen('Objetivos', Icons.flag_outlined, Colors.teal.shade600), // 7 - Objetivos
          _buildPlaceholderScreen('Herramientas', Icons.build_outlined, Colors.indigo.shade600), // 8 - Herramientas
          _buildPlaceholderScreen('Configuración', Icons.settings_outlined, Colors.grey.shade700), // 9 - Configuración
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _navigateToSection,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFF10B981).withOpacity(0.2),
            height: 80,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.attach_money_outlined),
                selectedIcon: Icon(Icons.attach_money_rounded),
                label: 'Ingresos',
              ),
              NavigationDestination(
                icon: Icon(Icons.payment_outlined),
                selectedIcon: Icon(Icons.payment_rounded),
                label: 'Gastos',
              ),
              NavigationDestination(
                icon: Icon(Icons.savings_outlined),
                selectedIcon: Icon(Icons.savings_rounded),
                label: 'Ahorros',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          ),
        ),
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
                        _navigateToSection(4);
                      },
                    ),
                    _buildDrawerMenuItem(
                      icon: Icons.trending_up_rounded,
                      title: 'Inversiones',
                      color: Colors.blue.shade600,
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
                        _navigateToSection(6);
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
                      icon: Icons.flag_outlined,
                      title: 'Objetivos Financieros',
                      color: Colors.teal.shade600,
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToSection(7);
                      },
                    ),
                    _buildDrawerMenuItem(
                      icon: Icons.build_outlined,
                      title: 'Calculadoras',
                      color: Colors.indigo.shade600,
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToSection(8);
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
                        _navigateToSection(9);
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
