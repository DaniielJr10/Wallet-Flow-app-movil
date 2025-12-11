import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio principal de notificaciones para ahorros
/// Sistema automático que maneja recordatorios de metas y progreso de ahorros
class ServicioNotificacionesAhorros {
  static ServicioNotificacionesAhorros? _instance;
  
  /// Singleton para acceso único
  static ServicioNotificacionesAhorros get instance {
    _instance ??= ServicioNotificacionesAhorros._();
    return _instance!;
  }
  
  ServicioNotificacionesAhorros._();
  
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const String _channelId = 'ahorros_notificaciones';
  static const String _channelName = 'Recordatorios de Ahorros';
  static const String _prefsKey = 'notificaciones_ahorros_activas';
  
  /// Inicializa el servicio de notificaciones de ahorros
  Future<bool> inicializar() async {
    try {
      // Configuración de Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuración de iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _plugin.initialize(initializationSettings);
      
      // Crear canal para Android
      await _crearCanalNotificacion();
      
      if (kDebugMode) {
        print('✅ ServicioNotificacionesAhorros inicializado correctamente');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inicializando ServicioNotificacionesAhorros: $e');
      }
      return false;
    }
  }
  
  /// Crea el canal de notificación para Android
  Future<void> _crearCanalNotificacion() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Recordatorios para metas de ahorro y progreso',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  /// Programa recordatorio para una meta de ahorro
  Future<void> programarRecordatorioMeta({
    required int metaId,
    required String nombreMeta,
    required double montoObjetivo,
    required double montoActual,
    required DateTime fechaLimite,
    required String frecuenciaRecordatorio, // 'diario', 'semanal', 'mensual'
  }) async {
    try {
      final activo = await _estanActivasLasNotificaciones();
      if (!activo) {
        if (kDebugMode) {
          print('🔇 Notificaciones de ahorros desactivadas - No se programa recordatorio');
        }
        return;
      }
      
      // Calcular próxima fecha de recordatorio
      DateTime proximaFecha = _calcularProximaFecha(frecuenciaRecordatorio);
      
      // Crear mensaje personalizado según progreso
      final porcentajeCompletado = (montoActual / montoObjetivo * 100).round();
      final montoFaltante = montoObjetivo - montoActual;
      
      String titulo = '🎯 Recordatorio: $nombreMeta';
      String mensaje = _generarMensajeProgreso(
        nombreMeta: nombreMeta,
        porcentaje: porcentajeCompletado,
        montoFaltante: montoFaltante,
        fechaLimite: fechaLimite,
      );
      
      // Programar notificación
      await _plugin.zonedSchedule(
        _generarIdNotificacion(metaId, 'recordatorio'),
        titulo,
        mensaje,
        tz.TZDateTime.from(proximaFecha, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Recordatorios de metas de ahorro',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color.fromARGB(255, 16, 185, 129), // Verde para ahorros
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      if (kDebugMode) {
        print('✅ Recordatorio programado para meta "$nombreMeta" - Próximo: $proximaFecha');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error programando recordatorio de meta: $e');
      }
    }
  }
  
  /// Programa notificación de logro de meta
  Future<void> notificarMetaCompletada({
    required int metaId,
    required String nombreMeta,
    required double montoObjetivo,
  }) async {
    try {
      final activo = await _estanActivasLasNotificaciones();
      if (!activo) return;
      
      String titulo = '🎉 ¡Meta Completada!';
      String mensaje = '¡Felicidades! Has completado tu meta "$nombreMeta" de \$${montoObjetivo.toStringAsFixed(2)}. ¡Excelente trabajo!';
      
      await _plugin.show(
        _generarIdNotificacion(metaId, 'completada'),
        titulo,
        mensaje,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            color: Color.fromARGB(255, 34, 197, 94), // Verde éxito
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      
      if (kDebugMode) {
        print('🎉 Notificación de meta completada enviada: $nombreMeta');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error enviando notificación de meta completada: $e');
      }
    }
  }
  
  /// Programa alerta por meta próxima a vencer
  Future<void> programarAlertaMetaProximaVencer({
    required int metaId,
    required String nombreMeta,
    required double montoObjetivo,
    required double montoActual,
    required DateTime fechaLimite,
  }) async {
    try {
      final activo = await _estanActivasLasNotificaciones();
      if (!activo) return;
      
      // Programar alertas: 7 días antes, 3 días antes, 1 día antes
      final alertas = [7, 3, 1];
      
      for (final diasAntes in alertas) {
        final fechaAlerta = fechaLimite.subtract(Duration(days: diasAntes));
        
        if (fechaAlerta.isAfter(DateTime.now())) {
          final montoFaltante = montoObjetivo - montoActual;
          final porcentaje = (montoActual / montoObjetivo * 100).round();
          
          String titulo = '⏰ Meta por vencer: $nombreMeta';
          String mensaje = 'Te quedan $diasAntes días para completar tu meta. '
              'Progreso actual: $porcentaje%. Faltan \$${montoFaltante.toStringAsFixed(2)}';
          
          await _plugin.zonedSchedule(
            _generarIdNotificacion(metaId, 'alerta_$diasAntes'),
            titulo,
            mensaje,
            tz.TZDateTime.from(fechaAlerta, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                _channelId,
                _channelName,
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
                color: Color.fromARGB(255, 245, 158, 11), // Ámbar para alertas
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
      
      if (kDebugMode) {
        print('⏰ Alertas de vencimiento programadas para meta: $nombreMeta');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error programando alertas de vencimiento: $e');
      }
    }
  }
  
  /// Cancela todas las notificaciones de una meta específica
  Future<void> cancelarNotificacionesMeta(int metaId) async {
    try {
      // Cancelar recordatorio
      await _plugin.cancel(_generarIdNotificacion(metaId, 'recordatorio'));
      
      // Cancelar notificación de completada
      await _plugin.cancel(_generarIdNotificacion(metaId, 'completada'));
      
      // Cancelar alertas de vencimiento
      final alertas = [7, 3, 1];
      for (final diasAntes in alertas) {
        await _plugin.cancel(_generarIdNotificacion(metaId, 'alerta_$diasAntes'));
      }
      
      if (kDebugMode) {
        print('🗑️ Notificaciones canceladas para meta ID: $metaId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelando notificaciones de meta: $e');
      }
    }
  }
  
  /// Cancela todas las notificaciones de ahorros
  Future<void> limpiarTodasLasNotificaciones() async {
    try {
      await _plugin.cancelAll();
      if (kDebugMode) {
        print('🧹 Todas las notificaciones de ahorros limpiadas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error limpiando notificaciones: $e');
      }
    }
  }
  
  /// Activa o desactiva las notificaciones de ahorros
  Future<void> configurarNotificaciones(bool activo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, activo);
      
      if (!activo) {
        await limpiarTodasLasNotificaciones();
      }
      
      if (kDebugMode) {
        print('⚙️ Notificaciones de ahorros: ${activo ? "ACTIVADAS" : "DESACTIVADAS"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error configurando notificaciones: $e');
      }
    }
  }
  
  /// Verifica si las notificaciones están activas
  Future<bool> _estanActivasLasNotificaciones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefsKey) ?? true; // Por defecto activadas
    } catch (e) {
      return true;
    }
  }
  
  /// Verifica si las notificaciones están activas (público)
  Future<bool> notificacionesActivas() async {
    return await _estanActivasLasNotificaciones();
  }
  
  /// Genera un ID único para cada notificación
  int _generarIdNotificacion(int metaId, String tipo) {
    // Combinar metaId con hash del tipo para crear ID único
    final tipoHash = tipo.hashCode.abs() % 1000; // Limitamos a 3 dígitos
    return (metaId * 1000) + tipoHash;
  }
  
  /// Calcula la próxima fecha según la frecuencia
  DateTime _calcularProximaFecha(String frecuencia) {
    final ahora = DateTime.now();
    
    switch (frecuencia) {
      case 'diario':
        return ahora.add(const Duration(days: 1));
      case 'semanal':
        return ahora.add(const Duration(days: 7));
      case 'mensual':
        return DateTime(ahora.year, ahora.month + 1, ahora.day);
      default:
        return ahora.add(const Duration(days: 7)); // Default: semanal
    }
  }
  
  /// Genera mensaje personalizado según el progreso
  String _generarMensajeProgreso({
    required String nombreMeta,
    required int porcentaje,
    required double montoFaltante,
    required DateTime fechaLimite,
  }) {
    final diasRestantes = fechaLimite.difference(DateTime.now()).inDays;
    
    if (porcentaje >= 90) {
      return '¡Ya casi lo logras! Solo faltan \$${montoFaltante.toStringAsFixed(2)} para completar "$nombreMeta". ¡El último esfuerzo!';
    } else if (porcentaje >= 70) {
      return '¡Vas muy bien! Has completado el $porcentaje% de "$nombreMeta". Faltan \$${montoFaltante.toStringAsFixed(2)}. ¡Sigue así!';
    } else if (porcentaje >= 50) {
      return '¡A medio camino! Ya tienes el $porcentaje% de "$nombreMeta". Quedan $diasRestantes días para ahorrar \$${montoFaltante.toStringAsFixed(2)} más.';
    } else if (porcentaje >= 25) {
      return 'Buen comienzo con el $porcentaje% de "$nombreMeta". Aún faltan \$${montoFaltante.toStringAsFixed(2)}. ¡Cada peso cuenta!';
    } else {
      return 'Recordatorio: tu meta "$nombreMeta" te está esperando. Faltan \$${montoFaltante.toStringAsFixed(2)}. ¡Empieza hoy!';
    }
  }
  
  /// Obtiene estadísticas del servicio
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final activo = await _estanActivasLasNotificaciones();
      final pendientes = await _plugin.pendingNotificationRequests();
      
      // Filtrar solo las notificaciones de ahorros
      final notificacionesAhorros = pendientes.where((n) => n.id >= 1000).length;
      
      return {
        'notificaciones_activas': activo,
        'notificaciones_programadas': notificacionesAhorros,
        'servicio_inicializado': true,
        'canal_configurado': true,
      };
    } catch (e) {
      return {
        'error': true,
        'mensaje': 'Error obteniendo estadísticas: $e',
      };
    }
  }
}
