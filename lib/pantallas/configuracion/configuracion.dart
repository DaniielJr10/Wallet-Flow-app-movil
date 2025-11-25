import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../util/web_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
// 'printing' plugin used previously for web; not required when using web_downloader
// Note: previously used `Printing.sharePdf` for web, now we use a web downloader helper.
// Keep the import commented in case you want to restore printing features later.
// import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase/base_datos_servicio.dart';
import '../../firebase/servicios/ingresos_servicio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase/autenticacion_servicio.dart';
import '../../login/iniciosesion.dart';
import '../perfil/perfil.dart';
import '../preguntas_frecuentes.dart';
import '../contactar_soporte.dart';
import '../cambiar_contrasena.dart';
import '../recordatorios_gastos.dart';

/// Pantalla de configuración de la aplicación Wallet Flow
/// 
/// Permite al usuario personalizar la experiencia de la app, gestionar
/// su perfil, configurar seguridad, notificaciones y exportar datos.
/// 
/// Características principales:
/// - Gestión de perfil de usuario
/// - Configuración de tema y moneda
/// - Opciones de seguridad y privacidad
/// - Exportación de datos y soporte
class PantallaConfiguracion extends StatefulWidget {
  const PantallaConfiguracion({super.key});

  @override
  State<PantallaConfiguracion> createState() => _PantallaConfiguracionState();
}

class _PantallaConfiguracionState extends State<PantallaConfiguracion>
    with TickerProviderStateMixin {
  
  // ===== SERVICIOS Y CONTROLADORES =====
  final AutenticacionServicio _authService = AutenticacionServicio();
  final BaseDatosServicio _baseDatosService = BaseDatosServicio();
  final IngresosServicio _ingresosService = IngresosServicio();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ===== ESTADOS DE CONFIGURACIÓN =====
  /// Controla si las notificaciones push están habilitadas
  bool _notificacionesActivas = true;
  
  /// Controla si la autenticación biométrica está habilitada
  // Autenticación biométrica eliminada: se mantuvieron otras opciones de seguridad
  
  /// Controla el tema de la aplicación (claro/oscuro)
  
  /// Controla la sincronización automática de datos
  bool _sincronizacionAutomatica = true;
  
  /// Moneda seleccionada para mostrar valores
  // Moneda y selección de idioma eliminadas: la app no muestra opciones en UI

  // ===== DATOS ESTÁTICOS =====
  /// Lista de monedas disponibles en la aplicación
  // Eliminado: lista de monedas (no se usa tras quitar la opción de Moneda)

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _cargarConfiguracion();
  }

  /// Devuelve un directorio temporal; si el plugin no está registrado, usa systemTemp
  Future<Directory> _getTempDirectory() async {
    try {
      return await getTemporaryDirectory();
    } on MissingPluginException {
      return Directory.systemTemp;
    } catch (e) {
      return Directory.systemTemp;
    }
  }

  /// Inicializa las animaciones de entrada de la pantalla
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animación de desvanecimiento gradual
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Animación de deslizamiento desde abajo
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  /// Carga la configuración del usuario desde Firebase/Local Storage
  /// TODO: Implementar carga real desde base de datos
  Future<void> _cargarConfiguracion() async {
    try {
      // Simular carga de configuración
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Aquí se cargarían las preferencias reales del usuario
      // Ejemplo: await SharedPreferences.getInstance();
      
    } catch (e) {
      debugPrint('Error al cargar configuración: $e');
    }
  }

  /// Guarda una configuración específica en la base de datos
  /// [key] La clave de la configuración
  /// [value] El valor a guardar
  Future<void> _guardarConfiguracion(String key, dynamic value) async {
    try {
      // TODO: Implementar guardado real en Firebase/SharedPreferences
      debugPrint('Guardando configuración: $key = $value');
      
      // Mostrar feedback al usuario
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar configuración'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                    _buildPerfilCard(),
                    const SizedBox(height: 24),
                    _buildSeccionSeguridad(),
                    const SizedBox(height: 24),
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

  /// Construye la barra de aplicación con gradiente y título
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

  /// Construye la tarjeta de perfil del usuario con información básica
  Widget _buildPerfilCard() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Usuario';
    final email = user?.email ?? 'correo@ejemplo.com';
    final primerNombre = displayName.split(' ')[0];

    return Container(
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
      child: Row(
        children: [
          // Avatar del usuario
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          
          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $primerNombre',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Botón editar perfil
          IconButton(
            onPressed: () {
              // TODO: Navegar a pantalla de perfil
              _navegarAPerfil();
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            tooltip: 'Editar perfil',
          ),
        ],
      ),
    );
  }

  // Sección 'General' eliminada: ya no se muestra en la pantalla de configuración

  /// Construye la sección de seguridad
  /// Incluye biometría, contraseña y 2FA
  Widget _buildSeccionSeguridad() {
    return _buildSeccion(
      titulo: 'Seguridad',
      icono: Icons.security,
      color: const Color(0xFFEF4444),
      children: [
        // Opción de autenticación biométrica eliminada por solicitud
        _buildOpcionTile(
          titulo: 'Cambiar Contraseña',
          subtitulo: 'Actualizar contraseña de tu cuenta',
          icono: Icons.lock,
          onTap: () => _cambiarContrasena(),
        ),
      ],
    );
  }

  /// Construye la sección de notificaciones
  Widget _buildSeccionNotificaciones() {
    return _buildSeccion(
      titulo: 'Notificaciones',
      icono: Icons.notifications,
      color: const Color(0xFFF59E0B),
      children: [
        _buildSwitchTile(
          titulo: 'Notificaciones Push',
          subtitulo: 'Recibir alertas importantes',
          icono: Icons.notifications_active,
          valor: _notificacionesActivas,
          onChanged: (value) async {
            setState(() {
              _notificacionesActivas = value;
            });
            await _guardarConfiguracion('notificaciones_activas', value);
            // TODO: Configurar notificaciones reales
          },
        ),
        _buildOpcionTile(
          titulo: 'Recordatorios de Gastos',
          subtitulo: 'Configurar alertas de límites',
          icono: Icons.alarm,
          onTap: () => _configurarRecordatorios(),
        ),
      ],
    );
  }

  /// Construye la sección de datos y privacidad
  Widget _buildSeccionDatos() {
    return _buildSeccion(
      titulo: 'Datos y Privacidad',
      icono: Icons.data_usage,
      color: const Color(0xFF8B5CF6),
      children: [
        _buildSwitchTile(
          titulo: 'Sincronización Automática',
          subtitulo: 'Mantener datos actualizados en tiempo real',
          icono: Icons.sync,
          valor: _sincronizacionAutomatica,
          onChanged: (value) async {
            setState(() {
              _sincronizacionAutomatica = value;
            });
            await _guardarConfiguracion('sincronizacion_automatica', value);
            // TODO: Configurar sincronización real
          },
        ),
        _buildOpcionTile(
          titulo: 'Exportar Datos',
          subtitulo: 'Descargar información en Excel/PDF',
          icono: Icons.download,
          onTap: () => _exportarDatos(),
        ),
        _buildOpcionTile(
          titulo: 'Eliminar Cuenta',
          subtitulo: 'Eliminar permanentemente tu cuenta',
          icono: Icons.delete_forever,
          onTap: () => _confirmarEliminarCuenta(),
          esDestructivo: true,
        ),
      ],
    );
  }

  /// Construye la sección de ayuda y soporte
  Widget _buildSeccionAyuda() {
    return _buildSeccion(
      titulo: 'Ayuda y Soporte',
      icono: Icons.help,
      color: const Color(0xFF06B6D4),
      children: [
        _buildOpcionTile(
          titulo: 'Preguntas Frecuentes',
          subtitulo: 'Encuentra respuestas rápidas',
          icono: Icons.quiz,
          onTap: () => _abrirFAQ(),
        ),
        _buildOpcionTile(
          titulo: 'Contactar Soporte',
          subtitulo: 'Enviar mensaje al equipo de ayuda',
          icono: Icons.support_agent,
          onTap: () => _contactarSoporte(),
        ),
        _buildOpcionTile(
          titulo: 'Acerca de',
          subtitulo: 'Versión 1.0.0 - Wallet Flow',
          icono: Icons.info,
          onTap: () => _mostrarAcercaDe(),
        ),
      ],
    );
  }

  // ===== WIDGETS AUXILIARES =====

  /// Construye una sección de configuración con título e ícono
  /// [titulo] Título de la sección
  /// [icono] Ícono representativo
  /// [color] Color temático de la sección
  /// [children] Lista de widgets hijos
  Widget _buildSeccion({
    required String titulo,
    required IconData icono,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de la sección
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icono,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Contenedor de opciones
        Container(
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
          child: Column(children: children),
        ),
      ],
    );
  }

  /// Construye un elemento de configuración con switch
  Widget _buildSwitchTile({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icono,
          color: const Color(0xFF10B981),
          size: 20,
        ),
      ),
      title: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: valor,
        onChanged: onChanged,
        activeColor: const Color(0xFF10B981),
      ),
    );
  }

  /// Construye un elemento de configuración navegable
  Widget _buildOpcionTile({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required VoidCallback onTap,
    bool esDestructivo = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: esDestructivo 
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icono,
          color: esDestructivo ? Colors.red : const Color(0xFF10B981),
          size: 20,
        ),
      ),
      title: Text(
        titulo,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: esDestructivo ? Colors.red : const Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  /// Construye el botón principal para cerrar sesión
  Widget _buildBotonCerrarSesion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () => _confirmarCerrarSesion(),
        icon: const Icon(Icons.logout),
        label: const Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // ===== MÉTODOS DE NAVEGACIÓN Y ACCIONES =====

  /// Navega a la pantalla de perfil del usuario
  Future<void> _navegarAPerfil() async {
    // Navegar a la pantalla de perfil existente y esperar si hubo cambios
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const PantallaPerfil(iniciarEnEdicion: true)),
    );

    // Si la pantalla de perfil devolvió `true`, recargar el usuario desde Firebase
    if (result == true && mounted) {
      try {
        await FirebaseAuth.instance.currentUser?.reload();
      } catch (e) {
        debugPrint('Error al recargar usuario: $e');
      }
      setState(() {
        // Forzar reconstrucción para leer los nuevos datos del usuario
      });
    }
  }

  /// Muestra el selector de moneda en un bottom sheet
  // Selector de moneda eliminado: no se muestra al usuario

  // Selector de idioma eliminado: la aplicación usa el idioma del sistema

  /// Inicia el proceso de cambio de contraseña
  void _cambiarContrasena() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CambiarContrasenaScreen()),
    );
  }

  /// Configura la autenticación de dos factores
  // Autenticación 2FA eliminada: opción eliminada de la UI por solicitud del usuario.

  /// Configura recordatorios personalizados
  void _configurarRecordatorios() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RecordatoriosGastosScreen()),
    );
  }

  /// Exporta los datos del usuario en formato Excel/PDF
  void _exportarDatos() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Exportar a PDF'),
              onTap: () async {
                Navigator.pop(context);
                await _exportAsPdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Exportar a Excel (XLSX)'),
              onTap: () async {
                Navigator.pop(context);
                await _exportAsExcel();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsPdf() async {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando PDF...')),
      );

      

            // Obtener datos: ingresos, gastos, deudas, ahorros, cuentas
            final ingresos = await _ingresosService.obtenerIngresos().first;

            final gastosSnapshot = await _baseDatosService.obtenerGastos().first;
            final gastos = gastosSnapshot.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return {
                'id': d.id,
                'nombre': data['nombre'] ?? '',
                'monto': (data['monto'] as num?)?.toDouble() ?? 0.0,
                'fecha': data['fecha'] is Timestamp ? (data['fecha'] as Timestamp).toDate() : data['fecha'],
                'categoria': data['categoria'] ?? '',
              };
            }).toList();

            final deudasSnapshot = await _baseDatosService.obtenerDeudas().first;
            final deudas = deudasSnapshot.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return {
                'id': d.id,
                'acreedor': data['nombreAcreedor'] ?? '',
                'montoTotal': (data['montoTotal'] as num?)?.toDouble() ?? 0.0,
                'montoPagado': (data['montoPagado'] as num?)?.toDouble() ?? 0.0,
                'fechaVencimiento': data['fechaVencimiento'] is Timestamp ? (data['fechaVencimiento'] as Timestamp).toDate() : data['fechaVencimiento'],
                'estado': data['estado'] ?? '',
              };
            }).toList();

            final ahorrosSnapshot = await _baseDatosService.obtenerAhorros().first;
            final ahorros = ahorrosSnapshot.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return {
                'id': d.id,
                'descripcion': data['descripcion'] ?? '',
                'montoObjetivo': (data['montoObjetivo'] as num?)?.toDouble() ?? 0.0,
                'montoActual': (data['montoActual'] as num?)?.toDouble() ?? 0.0,
                'fechaObjetivo': data['fechaObjetivo'] is Timestamp ? (data['fechaObjetivo'] as Timestamp).toDate() : data['fechaObjetivo'],
                'estado': data['estado'] ?? '',
              };
            }).toList();

            final cuentasSnapshot = await _baseDatosService.obtenerCuentas().first;
            final cuentas = cuentasSnapshot.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return {
                'id': d.id,
                'banco': data['nombreBanco'] ?? '',
                'numero': data['numeroCuenta'] ?? '',
                'tipo': data['tipoCuenta'] ?? '',
                'alias': data['alias'] ?? '',
                'saldo': (data['saldo'] as num?)?.toDouble() ?? 0.0,
              };
            }).toList();

            final doc = pw.Document();

            doc.addPage(
              pw.MultiPage(
                build: (context) => [
                  pw.Header(level: 0, child: pw.Text('Wallet Flow - Exportación de Datos')),
                  pw.SizedBox(height: 8),
                  pw.Text('Fecha: ${DateTime.now()}'),
                  pw.SizedBox(height: 12),

                  // Ingresos
                  pw.Text('Ingresos', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  if (ingresos.isEmpty)
                    pw.Text('No hay ingresos registrados')
                  else
                    pw.Table.fromTextArray(
                      headers: ['Descripción', 'Categoría', 'Monto', 'Fecha'],
                      data: ingresos.map((i) => [
                        i['descripcion'] ?? '',
                        i['categoria'] ?? '',
                        (i['monto'] as num?)?.toStringAsFixed(2) ?? '0.00',
                        (i['fecha'] is DateTime) ? i['fecha'].toString() : i['fecha'].toString(),
                      ]).toList(),
                    ),

                  pw.SizedBox(height: 12),

                  // Gastos
                  pw.Text('Gastos', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  if (gastos.isEmpty)
                    pw.Text('No hay gastos registrados')
                  else
                    pw.Table.fromTextArray(
                      headers: ['Nombre', 'Categoría', 'Monto', 'Fecha'],
                      data: gastos.map((g) => [
                        g['nombre'] ?? '',
                        g['categoria'] ?? '',
                        (g['monto'] as double).toStringAsFixed(2),
                        (g['fecha'] is DateTime) ? g['fecha'].toString() : g['fecha'].toString(),
                      ]).toList(),
                    ),

                  pw.SizedBox(height: 12),

                  // Deudas
                  pw.Text('Deudas', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  if (deudas.isEmpty)
                    pw.Text('No hay deudas registradas')
                  else
                    pw.Table.fromTextArray(
                      headers: ['Acreedor', 'Total', 'Pagado', 'Vencimiento', 'Estado'],
                      data: deudas.map((d) => [
                        d['acreedor'] ?? '',
                        (d['montoTotal'] as double).toStringAsFixed(2),
                        (d['montoPagado'] as double).toStringAsFixed(2),
                        (d['fechaVencimiento'] is DateTime) ? d['fechaVencimiento'].toString() : d['fechaVencimiento'].toString(),
                        d['estado'] ?? '',
                      ]).toList(),
                    ),

                  pw.SizedBox(height: 12),

                  // Ahorros
                  pw.Text('Ahorros', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  if (ahorros.isEmpty)
                    pw.Text('No hay ahorros registrados')
                  else
                    pw.Table.fromTextArray(
                      headers: ['Descripción', 'Objetivo', 'Actual', 'Fecha Objetivo', 'Estado'],
                      data: ahorros.map((a) => [
                        a['descripcion'] ?? '',
                        (a['montoObjetivo'] as double).toStringAsFixed(2),
                        (a['montoActual'] as double).toStringAsFixed(2),
                        (a['fechaObjetivo'] is DateTime) ? a['fechaObjetivo'].toString() : a['fechaObjetivo'].toString(),
                        a['estado'] ?? '',
                      ]).toList(),
                    ),

                  pw.SizedBox(height: 12),

                  // Cuentas
                  pw.Text('Cuentas', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  if (cuentas.isEmpty)
                    pw.Text('No hay cuentas registradas')
                  else
                    pw.Table.fromTextArray(
                      headers: ['Banco', 'Número', 'Tipo', 'Alias', 'Saldo'],
                      data: cuentas.map((c) => [
                        c['banco'] ?? '',
                        c['numero'] ?? '',
                        c['tipo'] ?? '',
                        c['alias'] ?? '',
                        (c['saldo'] as double).toStringAsFixed(2),
                      ]).toList(),
                    ),
                ],
              ),
            );

      // Guardar/descargar según plataforma
      final bytes = await doc.save();

      if (kIsWeb) {
        try {
          downloadBytesAsFile(bytes, 'walletflow_export_${DateTime.now().millisecondsSinceEpoch}.pdf', 'application/pdf');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF descargado.')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al descargar PDF en web: $e')),
            );
          }
        }
      } else {
        final dir = await _getTempDirectory();
        final file = File('${dir.path}/walletflow_export_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generado. Preparando para compartir...')),
        );

        await Share.shareFiles([file.path], text: 'Exportación de datos - Wallet Flow');
      }
    } catch (e) {
      debugPrint('Error exportando a PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar a PDF: $e')),
        );
      }
    }
  }

  Future<void> _exportAsExcel() async {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando Excel...')),
      );

      final ingresos = await _ingresosService.obtenerIngresos().first;
      final gastosSnapshot = await _baseDatosService.obtenerGastos().first;
      final gastos = gastosSnapshot.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return {
          'id': d.id,
          'nombre': data['nombre'] ?? '',
          'monto': (data['monto'] as num?)?.toDouble() ?? 0.0,
          'fecha': data['fecha'] is Timestamp ? (data['fecha'] as Timestamp).toDate() : data['fecha'],
          'categoria': data['categoria'] ?? '',
        };
      }).toList();

      final deudasSnapshot = await _baseDatosService.obtenerDeudas().first;
      final deudas = deudasSnapshot.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return {
          'acreedor': data['nombreAcreedor'] ?? '',
          'montoTotal': (data['montoTotal'] as num?)?.toDouble() ?? 0.0,
          'montoPagado': (data['montoPagado'] as num?)?.toDouble() ?? 0.0,
          'fechaVencimiento': data['fechaVencimiento'] is Timestamp ? (data['fechaVencimiento'] as Timestamp).toDate() : data['fechaVencimiento'],
          'estado': data['estado'] ?? '',
        };
      }).toList();

      final ahorrosSnapshot = await _baseDatosService.obtenerAhorros().first;
      final ahorros = ahorrosSnapshot.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return {
          'descripcion': data['descripcion'] ?? '',
          'montoObjetivo': (data['montoObjetivo'] as num?)?.toDouble() ?? 0.0,
          'montoActual': (data['montoActual'] as num?)?.toDouble() ?? 0.0,
          'fechaObjetivo': data['fechaObjetivo'] is Timestamp ? (data['fechaObjetivo'] as Timestamp).toDate() : data['fechaObjetivo'],
          'estado': data['estado'] ?? '',
        };
      }).toList();

      final cuentasSnapshot = await _baseDatosService.obtenerCuentas().first;
      final cuentas = cuentasSnapshot.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return {
          'banco': data['nombreBanco'] ?? '',
          'numero': data['numeroCuenta'] ?? '',
          'tipo': data['tipoCuenta'] ?? '',
          'alias': data['alias'] ?? '',
          'saldo': (data['saldo'] as num?)?.toDouble() ?? 0.0,
        };
      }).toList();

      final excel = Excel.createExcel();
      var ingresosSheet = excel['Ingresos'];
      ingresosSheet.appendRow(['Descripción', 'Categoría', 'Monto', 'Fecha']);
      for (final i in ingresos) {
        ingresosSheet.appendRow([
          i['descripcion'] ?? '',
          i['categoria'] ?? '',
          (i['monto'] as num?)?.toStringAsFixed(2) ?? '0.00',
          (i['fecha'] is DateTime) ? i['fecha'].toString() : i['fecha'].toString(),
        ]);
      }

      var gastosSheet = excel['Gastos'];
      gastosSheet.appendRow(['Nombre', 'Categoría', 'Monto', 'Fecha']);
      for (final g in gastos) {
        gastosSheet.appendRow([
          g['nombre'] ?? '',
          g['categoria'] ?? '',
          (g['monto'] as double).toStringAsFixed(2),
          (g['fecha'] is DateTime) ? g['fecha'].toString() : g['fecha'].toString(),
        ]);
      }

      var deudasSheet = excel['Deudas'];
      deudasSheet.appendRow(['Acreedor', 'Total', 'Pagado', 'Vencimiento', 'Estado']);
      for (final d in deudas) {
        deudasSheet.appendRow([
          d['acreedor'] ?? '',
          (d['montoTotal'] as double).toStringAsFixed(2),
          (d['montoPagado'] as double).toStringAsFixed(2),
          (d['fechaVencimiento'] is DateTime) ? d['fechaVencimiento'].toString() : d['fechaVencimiento'].toString(),
          d['estado'] ?? '',
        ]);
      }

      var ahorrosSheet = excel['Ahorros'];
      ahorrosSheet.appendRow(['Descripción', 'Objetivo', 'Actual', 'Fecha Objetivo', 'Estado']);
      for (final a in ahorros) {
        ahorrosSheet.appendRow([
          a['descripcion'] ?? '',
          (a['montoObjetivo'] as double).toStringAsFixed(2),
          (a['montoActual'] as double).toStringAsFixed(2),
          (a['fechaObjetivo'] is DateTime) ? a['fechaObjetivo'].toString() : a['fechaObjetivo'].toString(),
          a['estado'] ?? '',
        ]);
      }

      var cuentasSheet = excel['Cuentas'];
      cuentasSheet.appendRow(['Banco', 'Número', 'Tipo', 'Alias', 'Saldo']);
      for (final c in cuentas) {
        cuentasSheet.appendRow([
          c['banco'] ?? '',
          c['numero'] ?? '',
          c['tipo'] ?? '',
          c['alias'] ?? '',
          (c['saldo'] as double).toStringAsFixed(2),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception('No se pudo generar el archivo Excel');

      if (kIsWeb) {
        try {
          downloadBytesAsFile(bytes, 'walletflow_export_${DateTime.now().millisecondsSinceEpoch}.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Excel descargado.')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al descargar Excel en web: $e')),
            );
          }
        }
      } else {
        final dir = await _getTempDirectory();
        final file = File('${dir.path}/walletflow_export_${DateTime.now().millisecondsSinceEpoch}.xlsx');
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel generado. Preparando para compartir...')),
        );

        await Share.shareFiles([file.path], text: 'Exportación de datos - Wallet Flow');
      }
    } catch (e) {
      debugPrint('Error exportando a Excel: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar a Excel: $e')),
        );
      }
    }
  }

  /// Abre la sección de preguntas frecuentes
  void _abrirFAQ() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PreguntasFrecuentesScreen()),
    );
  }

  /// Abre el formulario de contacto con soporte
  void _contactarSoporte() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ContactarSoporteScreen()),
    );
  }

  /// Muestra información sobre la aplicación
  void _mostrarAcercaDe() {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Acerca de',
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        final width = MediaQuery.of(context).size.width * 0.88;
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              padding: const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo encima del título
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'images/logo.png',
                        fit: BoxFit.cover,
                        width: 96,
                        height: 96,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  const Text(
                    'Wallet Flow',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tu compañero financiero personal',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 14),

                  // Feature chips
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      Chip(label: Text('Gastos')), 
                      Chip(label: Text('Ingresos')),
                      Chip(label: Text('Ahorros')),
                      Chip(label: Text('Exportar')),
                    ],
                  ),
                  const SizedBox(height: 14),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Gestiona gastos, ingresos y objetivos con una interfaz limpia y segura. Tu información se mantiene privada y sincronizada.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.withOpacity(0.2)),
                  const SizedBox(height: 8),

                  // Developer + contact
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _SmallInfo(title: 'Desarrollador', subtitle: 'Wallet Flow Team'),
                      _SmallInfo(title: 'Contacto', subtitle: 'walletflow@gmail.com'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(animation), child: child),
        );
      },
    ).then((_) {});
  }

  /// Confirma la eliminación permanente de la cuenta
  void _confirmarEliminarCuenta() {
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
            const Text('Eliminar Cuenta'),
          ],
        ),
        content: const Text(
          'Esta acción eliminará permanentemente tu cuenta y todos tus datos financieros. Esta acción no se puede deshacer.\n\n¿Estás completamente seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar eliminación real de cuenta
              _procesarEliminacionCuenta();
            },
            child: const Text(
              'Eliminar Permanentemente',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Solicita la contraseña para reautenticación (si es necesario)
  Future<String?> _promptPasswordForReauth() async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Reautenticación requerida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Por seguridad, por favor ingresa tu contraseña para confirmar la eliminación de la cuenta.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(controller.text.trim()), child: const Text('Confirmar')),
        ],
      ),
    );

    return result;
  }

  /// Procesa la eliminación definitiva de la cuenta: borra datos en Firestore y elimina el usuario en Auth.
  Future<void> _procesarEliminacionCuenta() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final bd = BaseDatosServicio();

    // Mostrar indicador
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eliminando cuenta...'), backgroundColor: Color(0xFF10B981)),
      );
    }

    // 1) Eliminar datos en Firestore
    final errDb = await bd.eliminarUsuarioPermanente();
    if (errDb != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errDb), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // 2) Intentar eliminar usuario de Firebase Auth
    try {
      await currentUser.delete();
    } on FirebaseAuthException catch (e) {
      // Si requiere reautenticación, solicitar contraseña y reintentar
      if (e.code == 'requires-recent-login') {
        final pwd = await _promptPasswordForReauth();
        if (pwd == null || pwd.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Eliminación cancelada'), backgroundColor: Colors.orange),
            );
          }
          return;
        }

        final email = currentUser.email;
        if (email == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reautenticación no disponible: usuario sin email'), backgroundColor: Colors.orange),
            );
          }
          return;
        }

        try {
          final cred = EmailAuthProvider.credential(email: email, password: pwd);
          await currentUser.reauthenticateWithCredential(cred);
          // Intentar borrar de nuevo
          await currentUser.delete();
        } on FirebaseAuthException catch (e2) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error de reautenticación: ${e2.message}'), backgroundColor: Colors.red),
            );
          }
          return;
        } catch (e2) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error de reautenticación: $e2'), backgroundColor: Colors.red),
            );
          }
          return;
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error eliminando usuario: ${e.message}'), backgroundColor: Colors.red),
          );
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error eliminando usuario: $e'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // 3) Cerrar sesión y redirigir al login
    try {
      await _authService.cerrarSesion();
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const InicioSesionScreen()),
        (route) => false,
      );
    }
  }

  /// Confirma el cierre de sesión del usuario
  void _confirmarCerrarSesion() {
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
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Cerrar Sesión'),
          ],
        ),
        content: const Text(
          '¿Estás seguro que deseas cerrar sesión?\n\nTus datos se mantendrán seguros y podrás acceder nuevamente cuando quieras.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _procesarCerrarSesion();
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Procesa el cierre de sesión y navega al login
  Future<void> _procesarCerrarSesion() async {
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(strokeWidth: 2),
                SizedBox(width: 16),
                Text('Cerrando sesión...'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }

      // Cerrar sesión con Firebase
      await _authService.cerrarSesion();
      
      // Navegar al login y limpiar el stack de navegación
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const InicioSesionScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cerrar sesión. Intenta nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Pequeño widget usado en el diálogo "Acerca de" para mostrar pares título/valor
class _SmallInfo extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SmallInfo({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}