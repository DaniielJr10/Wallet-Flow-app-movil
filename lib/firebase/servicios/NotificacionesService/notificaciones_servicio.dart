/// SERVICIO PRINCIPAL DE NOTIFICACIONES
/// 
/// Maneja todas las notificaciones locales de la aplicación de forma organizada.
/// Arquitectura modular que separa responsabilidades en archivos específicos.
/// 
/// Funcionalidades:
/// - Configuración inicial y permisos
/// - Programación de notificaciones para ingresos frecuentes
/// - Gestión de canales de notificación
/// - Utilidades para manejo de IDs únicos y mensajes

import 'funcionalidades/configuracion_notificaciones.dart';
import 'funcionalidades/programacion_notificaciones.dart';
import 'funcionalidades/utils_notificaciones.dart';

/// Servicio principal que combina todas las funcionalidades de notificaciones
class NotificacionesServicio {
  
  // Instancias de las funcionalidades
  final ConfiguracionNotificaciones _configuracion = ConfiguracionNotificaciones();
  final ProgramacionNotificaciones _programacion = ProgramacionNotificaciones();
  final UtilsNotificaciones _utils = UtilsNotificaciones();
  
  // Singleton para evitar múltiples instancias
  static NotificacionesServicio? _instance;
  
  /// Constructor privado para singleton
  NotificacionesServicio._();
  
  /// Getter para acceder a la instancia única
  static NotificacionesServicio get instance {
    _instance ??= NotificacionesServicio._();
    return _instance!;
  }
  
  /// ===== MÉTODOS DE CONFIGURACIÓN =====
  
  /// Inicializa el servicio de notificaciones
  /// Debe llamarse en el arranque de la app
  Future<bool> inicializar() async {
    try {
      return await _configuracion.inicializar();
    } catch (e) {
      print('Error inicializando notificaciones: $e');
      return false;
    }
  }
  
  /// Verifica y solicita permisos necesarios
  Future<bool> verificarPermisos() async {
    return await _configuracion.verificarPermisos();
  }
  
  /// ===== MÉTODOS DE PROGRAMACIÓN =====
  
  /// Programa una notificación para recordar un ingreso frecuente
  Future<void> programarRecordatorioIngreso({
    required String ingresoId,
    required double monto,
    required String descripcion,
    required DateTime fechaRecordatorio,
  }) async {
    await _programacion.programarRecordatorioIngreso(
      ingresoId: ingresoId,
      monto: monto,
      descripcion: descripcion,
      fechaRecordatorio: fechaRecordatorio,
    );
  }
  
  /// Cancela una notificación programada
  Future<void> cancelarNotificacion(String ingresoId) async {
    await _programacion.cancelarNotificacion(ingresoId);
  }
  
  /// Cancela todas las notificaciones programadas
  Future<void> cancelarTodasLasNotificaciones() async {
    await _programacion.cancelarTodasLasNotificaciones();
  }
  
  /// ===== MÉTODOS DE UTILIDAD =====
  
  /// Obtiene un ID único para la notificación basado en el ID del ingreso
  int obtenerIdNotificacion(String ingresoId) {
    return _utils.obtenerIdNotificacion(ingresoId);
  }
  
  /// Formatea el mensaje de la notificación
  String formatearMensajeNotificacion({
    required double monto,
    required String descripcion,
  }) {
    return _utils.formatearMensajeNotificacion(
      monto: monto,
      descripcion: descripcion,
    );
  }
  
  /// ===== MÉTODOS DE CONFIGURACIÓN DE USUARIO =====
  
  /// Activa/desactiva las notificaciones
  Future<void> configurarNotificaciones(bool activas) async {
    await _configuracion.configurarNotificaciones(activas);
  }
  
  /// Verifica si las notificaciones están activadas por el usuario
  Future<bool> notificacionesActivas() async {
    return await _configuracion.notificacionesActivas();
  }
}