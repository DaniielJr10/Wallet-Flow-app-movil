/// CONFIGURACIÓN DE NOTIFICACIONES
/// 
/// Maneja la configuración inicial, permisos y canales de notificación.
/// Se encarga del setup necesario para que las notificaciones funcionen correctamente.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase que maneja toda la configuración de notificaciones
class ConfiguracionNotificaciones {
  
  // Plugin para notificaciones locales
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  
  // Clave para guardar la preferencia del usuario
  static const String _keyNotificacionesActivas = 'notificaciones_activas';
  
  /// Inicializa las notificaciones y configura canales
  Future<bool> inicializar() async {
    try {
      // Configuración para Android
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Configuración para iOS
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      
      // Configuración general
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      // Inicializar el plugin
      bool? initialized = await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      if (initialized == true) {
        // Crear canal de notificaciones para Android
        await _crearCanalAndroid();
        return true;
      }
      
      return false;
      
    } catch (e) {
      print('Error inicializando notificaciones: $e');
      return false;
    }
  }
  
  /// Crea el canal de notificaciones para Android
  Future<void> _crearCanalAndroid() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'ingresos_frecuentes', // ID del canal
      'Recordatorios de Ingresos', // Nombre visible
      description: 'Notificaciones para recordar ingresos frecuentes',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  /// Maneja cuando el usuario toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    print('Notificación tocada: ${response.payload}');
    // Aquí puedes agregar lógica para abrir pantallas específicas
    // Por ejemplo, navegar a la pantalla de ingresos
  }
  
  /// Verifica y solicita permisos de notificación
  Future<bool> verificarPermisos() async {
    try {
      // Verificar permisos en Android
      final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
      
      // Verificar permisos en iOS
      final iosImplementation = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      
      if (iosImplementation != null) {
        final bool? granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      
      return true; // Para otras plataformas, asumir que está ok
      
    } catch (e) {
      print('Error verificando permisos: $e');
      return false;
    }
  }
  
  /// Configura si las notificaciones están activas o no
  Future<void> configurarNotificaciones(bool activas) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNotificacionesActivas, activas);
      
      // Si se desactivan, cancelar todas las notificaciones programadas
      if (!activas) {
        await _plugin.cancelAll();
      }
      
    } catch (e) {
      print('Error configurando notificaciones: $e');
    }
  }
  
  /// Verifica si las notificaciones están activadas por el usuario
  Future<bool> notificacionesActivas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyNotificacionesActivas) ?? true; // Por defecto activas
    } catch (e) {
      print('Error obteniendo estado de notificaciones: $e');
      return true;
    }
  }
  
  /// Getter para acceder al plugin desde otras clases
  FlutterLocalNotificationsPlugin get plugin => _plugin;
}