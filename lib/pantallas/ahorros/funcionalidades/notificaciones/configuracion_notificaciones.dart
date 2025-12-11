/// Configuración y constantes para el sistema de notificaciones de ahorros
class ConfiguracionNotificacionesAhorros {
  
  /// Configuración de canales de notificación
  static const String canalId = 'ahorros_notificaciones';
  static const String canalNombre = 'Recordatorios de Ahorros';
  static const String canalDescripcion = 'Notificaciones para recordatorios de metas de ahorro y progreso';
  
  /// IDs de notificaciones - Rangos para evitar conflictos
  static const int rangoInicioAhorros = 10000;  // IDs desde 10000 en adelante
  static const int idRecordatorioGeneral = 999999;
  
  /// Tipos de frecuencia de recordatorios
  static const Map<String, String> frecuenciasRecordatorio = {
    'diario': 'Diario',
    'semanal': 'Semanal', 
    'mensual': 'Mensual',
  };
  
  /// Días de anticipación para alertas de vencimiento
  static const List<int> diasAlertas = [7, 3, 1];
  
  /// Mensajes predeterminados
  static const Map<String, String> mensajes = {
    'recordatorio_general': '💰 ¡No olvides ahorrar! Cada peso cuenta para alcanzar tus metas.',
    'meta_completada': '🎉 ¡Felicidades! Has completado tu meta de ahorro.',
    'progreso_excelente': '🌟 ¡Excelente progreso! Estás muy cerca de tu meta.',
    'progreso_bueno': '👍 ¡Buen trabajo! Continúa así para alcanzar tu meta.',
    'progreso_inicial': '🚀 ¡Gran comienzo! Cada ahorro te acerca más a tu objetivo.',
    'alerta_vencimiento': '⏰ Tu meta está por vencer. ¡Es momento de hacer el último esfuerzo!',
  };
  
  /// Configuración de sonidos (nombres de archivos)
  static const Map<String, String> sonidos = {
    'recordatorio': 'notification',
    'meta_completada': 'success',
    'alerta': 'alert',
  };
  
  /// Configuración de colores por tipo de notificación
  static const Map<String, int> colores = {
    'recordatorio': 0xFF10B981,    // Verde
    'meta_completada': 0xFF22C55E, // Verde éxito
    'alerta': 0xFFF59E0B,          // Ámbar
    'progreso': 0xFF3B82F6,        // Azul
  };
  
  /// Configuración de iconos
  static const Map<String, String> iconos = {
    'recordatorio': '@mipmap/ic_launcher',
    'meta_completada': '@mipmap/ic_launcher',
    'alerta': '@mipmap/ic_launcher',
    'progreso': '@mipmap/ic_launcher',
  };
  
  /// Configuración de horas para recordatorios
  static const Map<String, Map<String, int>> horasRecordatorio = {
    'diario': {'hora': 10, 'minuto': 0},      // 10:00 AM
    'semanal': {'hora': 9, 'minuto': 0},      // 9:00 AM los domingos
    'mensual': {'hora': 8, 'minuto': 0},      // 8:00 AM el día 1 de cada mes
  };
  
  /// Configuración de SharedPreferences keys
  static const String prefsKeyActivo = 'notificaciones_ahorros_activas';
  static const String prefsKeyFrecuencia = 'notificaciones_ahorros_frecuencia';
  static const String prefsKeyHoraRecordatorio = 'notificaciones_ahorros_hora';
  
  /// Límites del sistema
  static const int maxNotificacionesPorMeta = 10;  // Máximo 10 notificaciones por meta
  static const int diasMaximoAnticipacion = 30;    // Máximo 30 días de anticipación
  
  /// Configuración de formato de números
  static const String formatoMoneda = '\$';
  static const int decimalesMoneda = 2;
  
  /// Validaciones
  static bool esIdValido(int id) {
    return id >= rangoInicioAhorros;
  }
  
  static bool esFrecuenciaValida(String frecuencia) {
    return frecuenciasRecordatorio.containsKey(frecuencia);
  }
  
  static bool esMontoValido(double monto) {
    return monto > 0 && monto < 1000000; // Entre 1 peso y 1 millón
  }
  
  static bool esFechaValida(DateTime fecha) {
    final ahora = DateTime.now();
    final limiteMaximo = ahora.add(const Duration(days: 365 * 2)); // Máximo 2 años
    return fecha.isAfter(ahora) && fecha.isBefore(limiteMaximo);
  }
  
  /// Utilidades de formato
  static String formatearMonto(double monto) {
    return '$formatoMoneda${monto.toStringAsFixed(decimalesMoneda)}';
  }
  
  static String formatearPorcentaje(double porcentaje) {
    return '${porcentaje.round()}%';
  }
  
  static String obtenerMensajeSegunProgreso(int porcentaje) {
    if (porcentaje >= 90) {
      return mensajes['progreso_excelente']!;
    } else if (porcentaje >= 70) {
      return mensajes['progreso_bueno']!;
    } else if (porcentaje >= 25) {
      return mensajes['progreso_inicial']!;
    } else {
      return mensajes['recordatorio_general']!;
    }
  }
  
  /// Configuración de depuración
  static const bool debugHabilitado = true; // true para desarrollo, false para producción
  static const String tagDebug = 'NotificacionesAhorros';
  
  /// Versión del sistema de notificaciones
  static const String version = '1.0.0';
  static const String fechaVersion = '2025-12-10';
  
  /// Información del sistema
  static Map<String, dynamic> obtenerInformacionSistema() {
    return {
      'version': version,
      'fecha_version': fechaVersion,
      'canal_id': canalId,
      'canal_nombre': canalNombre,
      'rango_ids': '$rangoInicioAhorros+',
      'tipos_frecuencia': frecuenciasRecordatorio.keys.toList(),
      'dias_alertas': diasAlertas,
      'debug_habilitado': debugHabilitado,
    };
  }
}
