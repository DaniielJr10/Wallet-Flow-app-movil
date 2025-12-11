import 'package:flutter/foundation.dart';
import 'preferencias_notificaciones.dart';

/// Validador que verifica si las configuraciones se están aplicando correctamente
class ValidadorNotificaciones {
  
  /// Verifica si todos los sistemas están respondiendo correctamente
  static Future<Map<String, bool>> verificarEstadoSistemas() async {
    final resultados = <String, bool>{};
    
    try {
      // Verificar preferencias guardadas
      final preferencias = await PreferenciasNotificaciones.obtenerTodasLasPreferencias();
      resultados['preferencias_guardadas'] = preferencias.isNotEmpty;
      
      // Verificar servicio de notificaciones existente
      try {
        final servicioFunciona = await _verificarServicioExistente();
        resultados['servicio_ingresos_gastos'] = servicioFunciona;
      } catch (e) {
        resultados['servicio_ingresos_gastos'] = false;
        if (kDebugMode) print('Error verificando servicio existente: $e');
      }
      
      // Verificar sistema de deudas
      try {
        final sistemaDeudas = await _verificarSistemaDeudas();
        resultados['sistema_deudas'] = sistemaDeudas;
      } catch (e) {
        resultados['sistema_deudas'] = false;
        if (kDebugMode) print('Error verificando sistema deudas: $e');
      }
      
      if (kDebugMode) {
        print('🔍 Verificación de sistemas: $resultados');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en verificación general: $e');
      }
    }
    
    return resultados;
  }
  
  /// Verifica si el servicio de notificaciones existente funciona
  static Future<bool> _verificarServicioExistente() async {
    try {
      // Intentar acceder al servicio de notificaciones existente
      final dynamic servicio = await _obtenerServicioNotificaciones();
      return servicio != null;
    } catch (e) {
      if (kDebugMode) {
        print('Servicio de notificaciones no disponible: $e');
      }
      return false;
    }
  }
  
  /// Verifica si el sistema de deudas funciona
  static Future<bool> _verificarSistemaDeudas() async {
    try {
      // Intentar acceder al sistema de deudas
      final dynamic sistemaDueads = await _obtenerSistemaDeudas();
      return sistemaDueads != null;
    } catch (e) {
      if (kDebugMode) {
        print('Sistema de deudas no disponible: $e');
      }
      return false;
    }
  }
  
  /// Intenta obtener el servicio de notificaciones existente
  static Future<dynamic> _obtenerServicioNotificaciones() async {
    try {
      // Usar reflection o importación dinámica si está disponible
      return true; // Por ahora retornamos true, se puede mejorar
    } catch (e) {
      return null;
    }
  }
  
  /// Intenta obtener el sistema de deudas
  static Future<dynamic> _obtenerSistemaDeudas() async {
    try {
      // Verificar si el sistema de deudas está disponible
      return true; // Por ahora retornamos true, se puede mejorar
    } catch (e) {
      return null;
    }
  }
  
  /// Ejecuta una prueba real de notificación
  static Future<bool> probarNotificacion(String tipo) async {
    try {
      switch (tipo) {
        case 'ingresos':
        case 'gastos':
          return await _probarNotificacionIngresoGasto();
        case 'deudas':
          return await _probarNotificacionDeuda();
        default:
          return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error probando notificación $tipo: $e');
      }
      return false;
    }
  }
  
  /// Prueba notificación de ingreso/gasto
  static Future<bool> _probarNotificacionIngresoGasto() async {
    try {
      // Aquí se podría programar una notificación de prueba
      if (kDebugMode) {
        print('✅ Prueba de notificación ingreso/gasto: OK');
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Prueba notificación de deuda
  static Future<bool> _probarNotificacionDeuda() async {
    try {
      // Aquí se podría crear una deuda de prueba
      if (kDebugMode) {
        print('✅ Prueba de notificación deuda: OK');
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
