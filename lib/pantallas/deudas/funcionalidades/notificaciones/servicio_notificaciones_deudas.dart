import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class ServicioNotificacionesDeudas {
  static final ServicioNotificacionesDeudas _instancia = ServicioNotificacionesDeudas._internal();
  factory ServicioNotificacionesDeudas() => _instancia;
  ServicioNotificacionesDeudas._internal();

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _inicializado = false;
  static bool _inicializando = false;

  /// Inicializa el servicio de notificaciones automáticamente
  static Future<void> _asegurarInicializacion() async {
    if (_inicializado || _inicializando) return;
    
    _inicializando = true;
    
    try {
      await inicializar();
    } finally {
      _inicializando = false;
    }
  }

  /// Inicializa el servicio de notificaciones
  static Future<void> inicializar() async {
    if (_inicializado) return;

    // Inicializar timezone
    tz.initializeTimeZones();

    // Configuración para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configuración general
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Inicializar plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Solicitar permisos en Android 13+
    await _solicitarPermisos();

    _inicializado = true;
    
    if (kDebugMode) {
      print('✅ Servicio de notificaciones de deudas inicializado automáticamente');
    }
  }

  /// Solicita permisos para notificaciones
  static Future<void> _solicitarPermisos() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  /// Maneja la respuesta cuando se toca una notificación
  static void _onNotificationResponse(NotificationResponse response) {
    if (kDebugMode) {
      print('Notificación tocada: ${response.payload}');
    }
    // Aquí puedes agregar lógica para navegar a la pantalla específica de la deuda
  }

  /// Programa una notificación para el vencimiento de una deuda
  Future<void> programarNotificacionVencimiento({
    required int id,
    required String nombreDeuda,
    required double monto,
    required DateTime fechaVencimiento,
    int diasAnticipacion = 3,
  }) async {
    await _asegurarInicializacion();

    // Calcular la fecha para mostrar la notificación
    final fechaNotificacion = fechaVencimiento.subtract(Duration(days: diasAnticipacion));
    
    // Solo programar si la fecha de notificación es en el futuro
    if (fechaNotificacion.isBefore(DateTime.now())) {
      if (kDebugMode) {
        print('No se puede programar notificación para fecha pasada: $fechaNotificacion');
      }
      return;
    }

    final tz.TZDateTime tzFechaNotificacion = tz.TZDateTime.from(
      fechaNotificacion,
      tz.local,
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'deudas_vencimiento',
      'Vencimiento de Deudas',
      channelDescription: 'Notificaciones cuando las deudas están por vencer',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF5722),
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final String titulo = '⚠️ Deuda próxima a vencer';
    final String cuerpo = '$nombreDeuda vence en $diasAnticipacion días\nMonto: \$${monto.toStringAsFixed(2)}';

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      tzFechaNotificacion,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'deuda_$id',
    );

    if (kDebugMode) {
      print('Notificación programada para deuda $nombreDeuda el $fechaNotificacion');
    }
  }

  /// Programa múltiples notificaciones para una deuda
  Future<void> programarNotificacionesMultiples({
    required int idBase,
    required String nombreDeuda,
    required double monto,
    required DateTime fechaVencimiento,
    List<int> diasAnticipacion = const [7, 3, 1],
  }) async {
    for (int i = 0; i < diasAnticipacion.length; i++) {
      await programarNotificacionVencimiento(
        id: idBase + i,
        nombreDeuda: nombreDeuda,
        monto: monto,
        fechaVencimiento: fechaVencimiento,
        diasAnticipacion: diasAnticipacion[i],
      );
    }
  }

  /// Cancela una notificación específica
  Future<void> cancelarNotificacion(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    if (kDebugMode) {
      print('Notificación $id cancelada');
    }
  }

  /// Cancela todas las notificaciones de una deuda
  Future<void> cancelarNotificacionesDeuda(int idDeuda) async {
    // Cancelar las notificaciones múltiples (asumiendo que usamos idBase + offset)
    for (int i = 0; i < 3; i++) {
      await cancelarNotificacion(idDeuda + i);
    }
  }

  /// Cancela todas las notificaciones
  Future<void> cancelarTodasLasNotificaciones() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    if (kDebugMode) {
      print('Todas las notificaciones canceladas');
    }
  }

  /// Obtiene las notificaciones pendientes
  Future<List<PendingNotificationRequest>> obtenerNotificacionesPendientes() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Muestra una notificación inmediata
  Future<void> mostrarNotificacionInmediata({
    required int id,
    required String titulo,
    required String cuerpo,
    String? payload,
  }) async {
    await _asegurarInicializacion();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'deudas_inmediatas',
      'Alertas de Deudas',
      channelDescription: 'Notificaciones inmediatas sobre deudas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF5722),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      titulo,
      cuerpo,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
