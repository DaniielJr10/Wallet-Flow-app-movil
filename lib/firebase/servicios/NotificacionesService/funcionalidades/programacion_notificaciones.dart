/// PROGRAMACIÓN DE NOTIFICACIONES
/// 
/// Se encarga de programar, cancelar y gestionar todas las notificaciones programadas.
/// Especializada en recordatorios para ingresos frecuentes.

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'configuracion_notificaciones.dart';
import 'utils_notificaciones.dart';

/// Clase que maneja la programación de notificaciones
class ProgramacionNotificaciones {
  
  final ConfiguracionNotificaciones _config = ConfiguracionNotificaciones();
  final UtilsNotificaciones _utils = UtilsNotificaciones();
  
  /// Inicializar timezone (necesario para notificaciones programadas)
  Future<void> _inicializarTimezone() async {
    try {
      tz.initializeTimeZones();
      // Configurar timezone local (puedes ajustar según tu región)
      tz.setLocalLocation(tz.getLocation('America/Bogota')); 
    } catch (e) {
      print('Error inicializando timezone: $e');
      // Fallback a UTC
      tz.setLocalLocation(tz.UTC);
    }
  }
  
  /// Programa una notificación para recordar un ingreso frecuente
  Future<void> programarRecordatorioIngreso({
    required String ingresoId,
    required double monto,
    required String descripcion,
    required DateTime fechaRecordatorio,
  }) async {
    try {
      // Verificar si las notificaciones están activas
      if (!await _config.notificacionesActivas()) {
        print('Notificaciones desactivadas por el usuario');
        return;
      }
      
      // Verificar que la fecha sea futura
      if (fechaRecordatorio.isBefore(DateTime.now())) {
        print('No se puede programar notificación en el pasado');
        return;
      }
      
      // Inicializar timezone si es necesario
      await _inicializarTimezone();
      
      // Generar ID único para la notificación
      final notificationId = _utils.obtenerIdNotificacion(ingresoId);
      
      // Formatear el mensaje
      final mensaje = _utils.formatearMensajeNotificacion(
        monto: monto,
        descripcion: descripcion,
      );
      
      // Configurar detalles de la notificación para Android
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'ingresos_frecuentes', // ID del canal
        'Recordatorios de Ingresos', // Nombre del canal
        channelDescription: 'Notificaciones para recordar ingresos frecuentes',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF4CAF50), // Verde para ingresos
        playSound: true,
        enableVibration: true,
      );
      
      // Configurar detalles de la notificación para iOS
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      // Combinar configuraciones
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // Convertir DateTime a TZDateTime
      final scheduledDate = tz.TZDateTime.from(fechaRecordatorio, tz.local);
      
      // Programar la notificación
      await _config.plugin.zonedSchedule(
        notificationId,
        '💰 Recordatorio de Ingreso',
        mensaje,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: ingresoId, // Payload para identificar el ingreso cuando se toque
      );
      
      print('Notificación programada para $fechaRecordatorio (ID: $notificationId)');
      
    } catch (e) {
      print('Error programando notificación: $e');
    }
  }
  
  /// Programa una notificación para recordar un gasto frecuente
  Future<void> programarRecordatorioGasto({
    required String gastoId,
    required double monto,
    required String descripcion,
    required DateTime fechaRecordatorio,
  }) async {
    try {
      // Verificar si las notificaciones están activas
      if (!await _config.notificacionesActivas()) {
        print('Notificaciones desactivadas por el usuario');
        return;
      }
      
      // Verificar que la fecha sea futura
      if (fechaRecordatorio.isBefore(DateTime.now())) {
        print('No se puede programar notificación en el pasado');
        return;
      }
      
      // Inicializar timezone si es necesario
      await _inicializarTimezone();
      
      // Generar ID único para la notificación
      final notificationId = _utils.obtenerIdNotificacion(gastoId);
      
      // Formatear el mensaje para gastos
      final mensaje = _utils.formatearMensajeGasto(
        monto: monto,
        descripcion: descripcion,
      );
      
      // Configurar detalles de la notificación para Android
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'gastos_frecuentes', // ID del canal específico para gastos
        'Recordatorios de Gastos', // Nombre del canal
        channelDescription: 'Notificaciones para recordar gastos frecuentes',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFF44336), // Rojo para gastos
        playSound: true,
        enableVibration: true,
      );
      
      // Configurar detalles de la notificación para iOS
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      // Combinar configuraciones
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // Convertir DateTime a TZDateTime
      final scheduledDate = tz.TZDateTime.from(fechaRecordatorio, tz.local);
      
      // Programar la notificación
      await _config.plugin.zonedSchedule(
        notificationId,
        '💸 Recordatorio de Gasto',
        mensaje,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: gastoId, // Payload para identificar el gasto cuando se toque
      );
      
      print('Notificación de gasto programada para $fechaRecordatorio (ID: $notificationId)');
      
    } catch (e) {
      print('Error programando notificación de gasto: $e');
    }
  }
  
  /// Cancela una notificación específica
  Future<void> cancelarNotificacion(String ingresoId) async {
    try {
      final notificationId = _utils.obtenerIdNotificacion(ingresoId);
      await _config.plugin.cancel(notificationId);
      print('Notificación cancelada para ingreso: $ingresoId');
    } catch (e) {
      print('Error cancelando notificación: $e');
    }
  }
  
  /// Cancela todas las notificaciones programadas
  Future<void> cancelarTodasLasNotificaciones() async {
    try {
      await _config.plugin.cancelAll();
      print('Todas las notificaciones han sido canceladas');
    } catch (e) {
      print('Error cancelando todas las notificaciones: $e');
    }
  }
  
  /// Obtiene la lista de notificaciones programadas (para debug)
  Future<List<PendingNotificationRequest>> obtenerNotificacionesPendientes() async {
    try {
      return await _config.plugin.pendingNotificationRequests();
    } catch (e) {
      print('Error obteniendo notificaciones pendientes: $e');
      return [];
    }
  }
  
  /// Programa una notificación inmediata (para testing)
  Future<void> mostrarNotificacionInmediata({
    required String titulo,
    required String mensaje,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'ingresos_frecuentes',
        'Recordatorios de Ingresos',
        channelDescription: 'Notificaciones para recordar ingresos frecuentes',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF4CAF50),
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _config.plugin.show(
        0, // ID temporal para notificación inmediata
        titulo,
        mensaje,
        notificationDetails,
        payload: payload,
      );
      
    } catch (e) {
      print('Error mostrando notificación inmediata: $e');
    }
  }
}