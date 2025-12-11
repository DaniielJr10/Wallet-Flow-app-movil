/// Exporta todas las funcionalidades del sistema de notificaciones de ahorros
/// 
/// Este archivo facilita la importación de todas las clases y widgets
/// relacionados con las notificaciones de ahorros en una sola línea.

// Servicios principales
export 'servicio_notificaciones_ahorros.dart';
export 'gestor_notificaciones_ahorros.dart';

// Inicializador y configuración
export 'inicializador_notificaciones.dart';
export 'configuracion_notificaciones.dart';

// Widgets de interfaz
export 'widgets_notificaciones.dart';

// Importaciones para la clase de conveniencia
import 'servicio_notificaciones_ahorros.dart';
import 'gestor_notificaciones_ahorros.dart';
import 'inicializador_notificaciones.dart';

/// Clase de conveniencia para acceder a las funcionalidades principales
/// ¡SISTEMA COMPLETAMENTE AUTOMÁTICO! No requiere inicialización manual.
class NotificacionesAhorros {
  /// Servicio principal de notificaciones (auto-inicializable)
  static ServicioNotificacionesAhorros get servicio => ServicioNotificacionesAhorros.instance;
  
  /// Gestor principal del sistema (auto-inicializable)
  static GestorNotificacionesAhorros get gestor => GestorNotificacionesAhorros.instance;
  
  /// Inicializador automático del sistema
  static InicializadorNotificacionesAhorros get inicializador => InicializadorNotificacionesAhorros.instance;
  
  // === MÉTODOS DE CONVENIENCIA ===
  
  /// Crea una meta con notificaciones automáticamente configuradas
  static Future<void> crearMetaConNotificaciones({
    required int metaId,
    required String nombreMeta,
    required double montoObjetivo,
    required DateTime fechaLimite,
    double montoInicial = 0.0,
    String frecuenciaRecordatorio = 'semanal',
  }) async {
    await gestor.crearMetaConNotificaciones(
      metaId: metaId,
      nombreMeta: nombreMeta,
      montoObjetivo: montoObjetivo,
      fechaLimite: fechaLimite,
      montoInicial: montoInicial,
      frecuenciaRecordatorio: frecuenciaRecordatorio,
    );
  }
  
  /// Actualiza el progreso de una meta (auto-detecta si se completó)
  static Future<void> actualizarProgreso({
    required int metaId,
    required String nombreMeta,
    required double montoObjetivo,
    required double nuevoMontoActual,
    required DateTime fechaLimite,
    String frecuenciaRecordatorio = 'semanal',
  }) async {
    await gestor.actualizarProgresoMeta(
      metaId: metaId,
      nombreMeta: nombreMeta,
      montoObjetivo: montoObjetivo,
      nuevoMontoActual: nuevoMontoActual,
      fechaLimite: fechaLimite,
      frecuenciaRecordatorio: frecuenciaRecordatorio,
    );
  }
  
  /// Elimina una meta y todas sus notificaciones
  static Future<void> eliminarMeta(int metaId) async {
    await gestor.eliminarNotificacionesMeta(metaId);
  }
  
  /// Activa o desactiva el sistema completo
  static Future<void> configurarSistema(bool activo) async {
    await gestor.configurarSistema(activo);
  }
  
  /// Limpia todas las notificaciones programadas
  static Future<void> limpiarSistema() async {
    await gestor.limpiarSistema();
  }
  
  /// Verifica si las notificaciones están activas
  static Future<bool> estanActivas() async {
    return await gestor.estanActivasLasNotificaciones();
  }
  
  /// Obtiene estadísticas completas del sistema
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    return await gestor.obtenerEstadisticas();
  }
  
  /// Ejecuta una prueba completa del sistema
  static Future<bool> ejecutarPrueba() async {
    return await gestor.ejecutarPrueba();
  }
  
  // === MÉTODOS DE INFORMACIÓN ===
  
  /// Verifica si el sistema está inicializado y funcionando
  static Future<bool> estaFuncionando() async {
    try {
      final estadisticas = await obtenerEstadisticas();
      return !estadisticas.containsKey('error');
    } catch (e) {
      return false;
    }
  }
  
  /// Obtiene información completa del estado del sistema
  static Future<Map<String, dynamic>> obtenerEstadoCompleto() async {
    try {
      final estadisticas = await obtenerEstadisticas();
      final activas = await estanActivas();
      final inicializado = inicializador.estaInicializado;
      
      return {
        'sistema_inicializado': inicializado,
        'notificaciones_activas': activas,
        'funcionando_correctamente': !estadisticas.containsKey('error'),
        'estadisticas_detalladas': estadisticas,
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
    } catch (e) {
      return {
        'error': true,
        'mensaje': 'Error obteniendo estado completo: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}

/// Auto-inicialización del sistema al importar este archivo
/// No es necesario hacer nada más - el sistema se inicializa automáticamente
final _autoInicio = NotificacionesAhorros.inicializador;
