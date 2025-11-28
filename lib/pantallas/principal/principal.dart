/// ORQUESTADOR PRINCIPAL (HOME)
/// Gestiona el estado de navegación (Tabs), la lógica de sesión (AuthService)
/// y la carga de datos del usuario (Nombre, Foto). Ensambla el Scaffold principal.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase/autenticacion_servicio.dart';
import '../../firebase/base_datos_servicio.dart';
import '../../firebase/servicios/PrincipalService/principal_servicio.dart';
import '../../login/iniciosesion/iniciosesion.dart';

// Pantallas de navegación
import '../ingresos/ingresos.dart';
import '../gastos/gastos.dart';
import '../cuentas/cuentas.dart';
import '../deudas/deudas.dart';
import '../ahorros/ahorros.dart';
import '../configuracion/configuracion.dart';
import '../perfil/perfil.dart';
import '../herramientass/herramientas.dart';

// Funcionalidades modularizadas
import 'funcionalidades/dashboard_body.dart';
import 'funcionalidades/app_bar_drawer.dart';
import 'funcionalidades/bottom_nav_principal.dart';
import 'funcionalidades/dialogos_principal.dart';
import 'funcionalidades/utils_principal.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> with TickerProviderStateMixin {
  final AutenticacionServicio _authService = AutenticacionServicio();
  final BaseDatosServicio _baseDatosService = BaseDatosServicio();
  final PrincipalServicio _principalServicio = PrincipalServicio();
  
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _nombreUsuario = 'Usuario';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
        setState(() => _nombreUsuario = user.displayName!.split(' ')[0]);
        return;
      }
      
      final perfil = await _baseDatosService.obtenerPerfilUsuario();
      if (perfil != null && perfil.exists) {
        final datos = perfil.data() as Map<String, dynamic>?;
        if (datos != null && datos['nombre'] != null) {
          setState(() => _nombreUsuario = (datos['nombre'] as String).split(' ')[0]);
        }
      }
    } catch (e) {
      // Mantener valor por defecto
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await DialogosPrincipal.confirmarCierreSesion(context);
    if (confirmar == true) {
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  void _navigateToSection(int index) {
    HapticFeedback.lightImpact();
    switch (index) {
      case 1: Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaIngresos())); break;
      case 2: Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaGastos())); break;
      case 3: Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaCuentas())); break;
      case 5: Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaDeudas())); break;
      case 6: Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaAhorros())); break;
      case 7: Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaHerramientas())); break;
      case 4: // Perfil (Navegación interna)
      case 8: // Config (Navegación interna a tab config si se usa indice 2)
      default:
        setState(() {
          // Mapeo de índices externos a índices del IndexedStack interno
          // 0: Dashboard, 4: Perfil -> 1, 8: Config -> 2
          if (index == 4) _selectedIndex = 1;
          else if (index == 8) _selectedIndex = 2;
          else _selectedIndex = index;
        });
    }
  }

  void _handleBottomNavigation(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtilsPrincipal.colorFondo,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardBody(
            fadeAnimation: _fadeAnimation,
            nombreUsuario: _nombreUsuario,
            servicio: _principalServicio,
            onAvatarTap: () => setState(() => _selectedIndex = 1), // Ir a perfil
            onLogoutTap: _cerrarSesion,
            onNavigate: _navigateToSection,
          ),
          const PantallaPerfil(),
          const PantallaConfiguracion(),
        ],
      ),
      bottomNavigationBar: BottomNavPrincipal(
        currentIndex: _selectedIndex,
        onTap: _handleBottomNavigation,
      ),
      drawer: PrincipalDrawer(
        onNavigate: _navigateToSection,
        onLogout: _cerrarSesion,
      ),
    );
  }
}