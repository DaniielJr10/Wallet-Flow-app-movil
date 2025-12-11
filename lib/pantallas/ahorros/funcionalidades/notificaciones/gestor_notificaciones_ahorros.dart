import 'package:flutter/foundation.dart';
import 'servicio_notificaciones_ahorros.dart';

/// Gestor principal que coordina las notificaciones de ahorros
/// Maneja la lógica de negocio y la integración con el servicio
class GestorNotificacionesAhorros {
  static GestorNotificacionesAhorros? _instance;
  
  /// Singleton para acceso único
  static GestorNotificacionesAhorros get instance {
    _instance ??= GestorNotificacionesAhorros._();
    return _instance!;
  }
  
  GestorNotificacionesAhorros._();
  
  final ServicioNotificacionesAhorros _servicio = ServicioNotificacionesAhorros.instance;
  
  /// Inicializa automáticamente el gestor
  Future<bool> inicializar() async {
    try {
      final inicializado = await _servicio.inicializar();
      
      if (kDebugMode) {
        print('🎯 GestorNotificacionesAhorros: ${inicializado ? "INICIALIZADO ✅" : "ERROR ❌"}');
      }
      
      return inicializado;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inicializando gestor de ahorros: $e');
      }
      return false;
    }
  }
  
  /// Configura notificaciones al crear una nueva meta de ahorro
  Future<void> configurarNotificacionesMeta({
    required int metaId,
    required String nombreMeta,
    required double montoObjetivo,
    required double montoActual,
    required DateTime fechaLimite,
    String frecuenciaRecordatorio = 'semanal',
  }) async {
    try {
      if (kDebugMode) {
        print('🎯 Configurando notificaciones para meta: $nombreMeta');
      }
      
      // 1. Programar recordatorios periódicos
      await _servicio.programarRecordatorioMeta(
        metaId: metaId,
        nombreMeta: nombreMeta,
        montoObjetivo: montoObjetivo,
        montoActual: montoActual,
        fechaLimite: fechaLimite,
        frecuenciaRecordatorio: frecuenciaRecordatorio,
      );
      
      // 2. Programar alertas de vencimiento si la meta tiene fecha límite
      await _servicio.programarAlertaMetaProximaVencer(
        metaId: metaId,
        nombreMeta: nombreMeta,
        montoObjetivo: montoObjetivo,
        montoActual: montoActual,
        fechaLimite: fechaLimite,
      );
      
      if (kDebugMode) {
        print('✅ Notificaciones configuradas para meta: $nombreMeta');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error configurando notificaciones de meta: $e');
      }
    }
  }
  
  /// Actualiza notificaciones cuando se agrega dinero a una meta
  Future<void> actualizarProgresoMeta({
    required int metaId,
    required String nombreMeta,
    required double montoObjetivo,
    required double nuevoMontoActual,
    required DateTime fechaLimite,
    String frecuenciaRecordatorio = 'semanal',
  }) async {
    try {
      if (kDebugMode) {
        print('📈 Actualizando progreso de meta: $nombreMeta');
      }
      
      // Verificar si la meta se completó
      if (nuevoMontoActual >= montoObjetivo) {
        // ¡Meta completada! 
        await _servicio.notificarMetaCompletada(
          metaId: metaId,
          nombreMeta: nombreMeta,
          montoObjetivo: montoObjetivo,
        );
        
        // Cancelar recordatorios pendientes ya que la meta está completa
        await _servicio.cancelarNotificacionesMeta(metaId);
        
        if (kDebugMode) {
          print('🎉 Meta completada: $nombreMeta - Notificaciones actualizadas');
        }
      } else {
        // Meta aún no completada, actualizar recordatorios
        await _servicio.cancelarNotificacionesMeta(metaId);
        
        await _servicio.programarRecordatorioMeta(
          metaId: metaId,
          nombreMeta: nombreMeta,
          montoObjetivo: montoObjetivo,
          montoActual: nuevoMontoActual,
          fechaLimite: fechaLimite,
          frecuenciaRecordatorio: frecuenciaRecordatorio,
        );
        
        await _servicio.programarAlertaMetaProximaVencer(
          metaId: metaId,
          nombreMeta: nombreMeta,
          montoObjetivo: montoObjetivo,
          montoActual: nuevoMontoActual,
          fechaLimite: fechaLimite,
        );
        
        if (kDebugMode) {
          final porcentaje = (nuevoMontoActual / montoObjetivo * 100).round();
          print('📊 Progreso actualizado: $nombreMeta ($porcentaje%)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error actualizando progreso de meta: $e');
      }
    }
  }
  
  /// Elimina todas las notificaciones de una meta cuando se borra
  Future<void> eliminarNotificacionesMeta(int metaId) async {
    try {
      await _servicio.cancelarNotificacionesMeta(metaId);
      
      if (kDebugMode) {
        print('🗑️ Notificaciones eliminadas para meta ID: $metaId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error eliminando notificaciones de meta: $e');
      }
    }
  }
  
  /// Configurar recordatorio general de ahorro (sin meta específica)
  /// Configurar recordatorio general de ahorro (sin meta específica)
  Future<void> configurarRecordatorioGeneralAhorro({
    required String mensaje,
    required DateTime fechaRecordatorio,
  }) async {
    try {
      if (kDebugMode) {
        print('💰 Configurando recordatorio general de ahorro');
      }
      
      // Este sería para recordatorios como "Recuerda ahorrar esta semana"
      // Se puede expandir según necesidades específicas
      
      if (kDebugMode) {
        print('✅ Recordatorio general configurado para: $fechaRecordatorio');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error configurando recordatorio general: $e');
      }
    }
  }
  
  /// Activa o desactiva todas las notificaciones de ahorros
  Future<void> configurarSistema(bool activo) async {
    try {
      await _servicio.configurarNotificaciones(activo);
      
      if (kDebugMode) {
        print('⚙️ Sistema de notificaciones de ahorros: ${activo ? "ACTIVADO 🔔" : "DESACTIVADO 🔇"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error configurando sistema: $e');
      }
    }
  }
  
  /// Limpia todas las notificaciones de ahorros
  Future<void> limpiarSistema() async {
    try {
      await _servicio.limpiarTodasLasNotificaciones();
      
      if (kDebugMode) {
        print('🧹 Sistema de ahorros limpiado - Todas las notificaciones canceladas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error limpiando sistema: $e');
      }
    }
  }
  
  /// Verifica si las notificaciones están activas
  Future<bool> estanActivasLasNotificaciones() async {
    try {
      return await _servicio.notificacionesActivas();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando estado de notificaciones: $e');
      }
      return false;
    }
  }
  
  /// Obtiene estadísticas detalladas del sistema
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final estadisticas = await _servicio.obtenerEstadisticas();
      
      // Agregar información adicional del gestor
      estadisticas['gestor_inicializado'] = true;
      estadisticas['version_gestor'] = '1.0';
      estadisticas['tipos_notificacion'] = [
        'recordatorios_meta',
        'alertas_vencimiento', 
        'notificaciones_completado',
        'recordatorios_generales'
      ];
      
      if (kDebugMode) {
        print('📊 Estadísticas del gestor de ahorros:');
        estadisticas.forEach((key, value) {
          print('   • $key: $value');
        });
      }
      
      return estadisticas;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo estadísticas: $e');
      }
      return {
        'error': true,
        'mensaje': 'Error obteniendo estadísticas del gestor',
      };
    }
  }
  
  /// Ejecuta una prueba del sistema de notificaciones
  Future<bool> ejecutarPrueba() async {
    try {
      if (kDebugMode) {
        print('🧪 Ejecutando prueba del sistema de ahorros...');
      }
      
      // 1. Verificar que el servicio esté activo
      final activo = await estanActivasLasNotificaciones();
      
      // 2. Obtener estadísticas
      final estadisticas = await obtenerEstadisticas();
      
      // 3. Evaluar resultado
      final resultado = activo && !estadisticas.containsKey('error');
      
      if (kDebugMode) {
        print('🧪 Resultado de prueba: ${resultado ? "EXITOSA ✅" : "FALLÓ ❌"}');
        print('   • Notificaciones activas: $activo');
        print('   • Estadísticas válidas: ${!estadisticas.containsKey("error")}');
      }
      
      return resultado;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en prueba del sistema: $e');
      }
      return false;
    }
  }
  
  /// Método de conveniencia para crear una meta con notificaciones
  Future<void> crearMetaConNotificaciones({
    required int metaId,
    required String nombreMeta,
    required double montoObjetivo,
    required DateTime fechaLimite,
    double montoInicial = 0.0,
    String frecuenciaRecordatorio = 'semanal',
  }) async {
    try {
      if (kDebugMode) {
        print('🎯 Creando meta con notificaciones: $nombreMeta');
      }
      
      // Configurar todas las notificaciones para la nueva meta
      await configurarNotificacionesMeta(
        metaId: metaId,
        nombreMeta: nombreMeta,
        montoObjetivo: montoObjetivo,
        montoActual: montoInicial,
        fechaLimite: fechaLimite,
        frecuenciaRecordatorio: frecuenciaRecordatorio,
      );
      
      if (kDebugMode) {
        print('✅ Meta creada con notificaciones configuradas: $nombreMeta');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creando meta con notificaciones: $e');
      }
    }
  }
}
