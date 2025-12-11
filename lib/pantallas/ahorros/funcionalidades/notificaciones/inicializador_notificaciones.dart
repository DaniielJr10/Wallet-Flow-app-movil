import 'package:flutter/foundation.dart';
import 'gestor_notificaciones_ahorros.dart';
import 'servicio_notificaciones_ahorros.dart';

/// Inicializador automático para el sistema de notificaciones de ahorros
/// Se ejecuta automáticamente al importar el sistema
class InicializadorNotificacionesAhorros {
  static bool _inicializado = false;
  static InicializadorNotificacionesAhorros? _instance;
  
  /// Singleton para evitar múltiples inicializaciones
  static InicializadorNotificacionesAhorros get instance {
    _instance ??= InicializadorNotificacionesAhorros._();
    return _instance!;
  }
  
  InicializadorNotificacionesAhorros._() {
    _inicializarAutomaticamente();
  }
  
  /// Inicialización automática del sistema
  Future<void> _inicializarAutomaticamente() async {
    if (_inicializado) return;
    
    try {
      if (kDebugMode) {
        print('🚀 Inicializando sistema de notificaciones de ahorros...');
      }
      
      // 1. Inicializar servicio de notificaciones
      final servicioInicializado = await ServicioNotificacionesAhorros.instance.inicializar();
      
      // 2. Inicializar gestor
      final gestorInicializado = await GestorNotificacionesAhorros.instance.inicializar();
      
      // 3. Verificar resultado
      if (servicioInicializado && gestorInicializado) {
        _inicializado = true;
        if (kDebugMode) {
          print('✅ Sistema de notificaciones de ahorros INICIALIZADO correctamente');
          print('   🎯 Gestor: LISTO');
          print('   📱 Servicio: LISTO');
          print('   🔔 Notificaciones: DISPONIBLES');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ Sistema inicializado con limitaciones:');
          print('   🎯 Gestor: ${gestorInicializado ? "OK" : "ERROR"}');
          print('   📱 Servicio: ${servicioInicializado ? "OK" : "ERROR"}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en inicialización automática de ahorros: $e');
      }
    }
  }
  
  /// Inicialización manual (por si se necesita forzar)
  Future<bool> inicializarManualmente() async {
    try {
      _inicializado = false;
      await _inicializarAutomaticamente();
      return _inicializado;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en inicialización manual: $e');
      }
      return false;
    }
  }
  
  /// Verifica si el sistema está inicializado
  bool get estaInicializado => _inicializado;
  
  /// Obtiene el estado del sistema
  Future<Map<String, dynamic>> obtenerEstadoSistema() async {
    try {
      final estadisticas = await GestorNotificacionesAhorros.instance.obtenerEstadisticas();
      
      return {
        'sistema_inicializado': _inicializado,
        'inicializador_activo': true,
        'timestamp_inicializacion': DateTime.now().toIso8601String(),
        'estadisticas_gestor': estadisticas,
      };
    } catch (e) {
      return {
        'sistema_inicializado': false,
        'error': true,
        'mensaje': 'Error obteniendo estado: $e',
      };
    }
  }
  
  /// Reintenta la inicialización si falló
  Future<bool> reintentarInicializacion() async {
    if (_inicializado) {
      if (kDebugMode) {
        print('ℹ️ Sistema de ahorros ya está inicializado');
      }
      return true;
    }
    
    try {
      if (kDebugMode) {
        print('🔄 Reintentando inicialización del sistema de ahorros...');
      }
      
      return await inicializarManualmente();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en reintento de inicialización: $e');
      }
      return false;
    }
  }
}

/// Variable global para auto-inicialización
final _autoInicializador = InicializadorNotificacionesAhorros.instance;
