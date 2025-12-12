import 'package:flutter/material.dart';

// Importación del servicio de notificaciones
import '../../firebase/servicios/NotificacionesService/notificaciones_servicio.dart';
import 'funcionalidades/notificaciones/preferencias_notificaciones.dart';

// import '../perfil/perfil.dart'; // removed: profile not shown in settings
import 'funcionalidades/preguntas_frecuentes/preguntas_frecuentes.dart';
import 'funcionalidades/contactar_soporte/contactar_soporte.dart';
import 'funcionalidades/cambiar_contraseña/cambiar_contrasena.dart';

// ===== IMPORTS DE ARCHIVOS MODULARES =====
import 'funcionalidades/configuracion_secciones.dart';
import 'funcionalidades/exportar_pdf_excel/configuracion_exportar.dart';
import 'funcionalidades/configuracion_cuenta.dart';
import 'funcionalidades/configuracion_dialogs.dart';


/// Pantalla de configuración de la aplicación Wallet Flow
class PantallaConfiguracion extends StatefulWidget {
  const PantallaConfiguracion({super.key});

  @override
  State<PantallaConfiguracion> createState() => _PantallaConfiguracionState();
}

class _PantallaConfiguracionState extends State<PantallaConfiguracion>
    with TickerProviderStateMixin {
  
  // ===== CONTROLADORES DE ANIMACIÓN =====
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ===== ESTADOS DE CONFIGURACIÓN =====
  bool _notificacionesActivas = true;
  // bool _sincronizacionAutomatica = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _cargarConfiguracion();
  }



  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

  Future<void> _cargarConfiguracion() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Cargar configuración de notificaciones
      final notificacionesActivas = await NotificacionesServicio.instance.notificacionesActivas();
      
      if (mounted) {
        setState(() {
          _notificacionesActivas = notificacionesActivas;
        });
      }
      
    } catch (e) {
      debugPrint('Error al cargar configuración: $e');
    }
  }

  Future<void> _guardarConfiguracion(String key, dynamic value) async {
    try {
      debugPrint('Guardando configuración: $key = $value');
      
      // Si se cambia la configuración de notificaciones, aplicar al servicio
      if (key == 'notificaciones_activas') {
        await NotificacionesServicio.instance.configurarNotificaciones(value);
        
        // Si se desactivan las generales, desactivar todas las específicas
        if (value == false) {
          await _desactivarTodasLasNotificacionesEspecificas();
        }
        
        debugPrint('Configuración de notificaciones aplicada: $value');
        // No mostrar aviso para las notificaciones generales
        return;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Configuración actualizada: $key'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al guardar configuración: $e');
    }
  }

  /// Desactiva todas las notificaciones específicas cuando se desactivan las generales
  Future<void> _desactivarTodasLasNotificacionesEspecificas() async {
    try {
      final tiposNotificaciones = ['ingresos', 'gastos', 'deudas', 'ahorros', 'presupuesto', 'metas'];
      
      for (String tipo in tiposNotificaciones) {
        await PreferenciasNotificaciones.guardarPreferencia(tipo, false);
      }
      
      debugPrint('Todas las notificaciones específicas han sido desactivadas');
    } catch (e) {
      debugPrint('Error desactivando notificaciones específicas: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSeccionNotificaciones(),
                    const SizedBox(height: 24),
                    _buildSeccionDatos(),
                    const SizedBox(height: 24),
                    _buildSeccionAyuda(),
                    const SizedBox(height: 32),
                    _buildBotonCerrarSesion(),
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

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0,2))],
              ),
              child: const Icon(Icons.settings, color: Color(0xFF0F172A), size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Configuración',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        background: Container(
          color: Colors.white,
        ),
      ),
    );
  }

  // Perfil card removed from UI. Kept code removed to avoid unused-widget warnings.

  // Seguridad section removed; related options moved to 'Datos y Privacidad'.

  Widget _buildSeccionNotificaciones() {
    return ConfiguracionSecciones.buildSeccionNotificaciones(
      notificacionesActivas: _notificacionesActivas,
      onNotificacionesChanged: (value) => setState(() => _notificacionesActivas = value),
      guardarConfiguracion: _guardarConfiguracion,
      context: context, // Nuevo parámetro agregado
    );
  }

  Widget _buildSeccionDatos() {
    return ConfiguracionSecciones.buildSeccionDatos(
      onCambiarContrasena: _cambiarContrasena,
      onExportarDatos: _exportarDatos,
      onEliminarCuenta: () => ConfiguracionCuenta.confirmarEliminarCuenta(context),
    );
  }

  Widget _buildSeccionAyuda() {
    return ConfiguracionSecciones.buildSeccionAyuda(
      onAbrirFAQ: _abrirFAQ,
      onContactarSoporte: _contactarSoporte,
      onMostrarAcercaDe: _mostrarAcercaDe,
    );
  }







  Widget _buildBotonCerrarSesion() {
    return ConfiguracionCuenta.buildBotonCerrarSesion(context);
  }

  // Perfil navigation removed because profile card is not shown in configuration screen.

  void _cambiarContrasena() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CambiarContrasenaScreen()),
    );
  }

  void _exportarDatos() {
    ConfiguracionExportar.mostrarOpcionesExportacion(context);
  }



  void _abrirFAQ() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PreguntasFrecuentesPantalla()));
  }

  void _contactarSoporte() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ContactarSoportePantalla()));
  }

  void _mostrarAcercaDe() {
    ConfiguracionDialogs.mostrarAcercaDe(context);
  }


}

