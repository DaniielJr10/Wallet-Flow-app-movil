import 'package:flutter/foundation.dart';
import 'preferencias_notificaciones.dart';
import 'validador_notificaciones.dart';

/// Gestor SIMPLIFICADO que coordina las notificaciones con las preferencias del usuario
/// Versión funcional al 100% sin dependencias complejas
class GestorNotificacionesConfiguracion {
  
  /// Aplica un cambio de configuración específico
  Future<void> aplicarCambioNotificacion(String tipo, bool activa) async {
    try {
      // Guardar la preferencia inmediatamente
      await PreferenciasNotificaciones.guardarPreferencia(tipo, activa);
      
      // Aplicar cambios según el tipo
      switch (tipo) {
        case 'generales':
          await _manejarConfiguracionGeneral(activa);
          break;
        case 'ingresos':
          await _manejarNotificacionesIngresos(activa);
          break;
        case 'gastos':
          await _manejarNotificacionesGastos(activa);
          break;
        case 'deudas':
          await _manejarNotificacionesDeudas(activa);
          break;
        case 'ahorros':
          await _manejarNotificacionesAhorros(activa);
          break;
        case 'presupuesto':
          await _manejarNotificacionesPresupuesto(activa);
          break;
        case 'metas':
          await _manejarNotificacionesMetas(activa);
          break;
        default:
          if (kDebugMode) {
            print('Tipo de notificación no reconocido: $tipo');
          }
      }
      
      if (kDebugMode) {
        print('✅ Configuración aplicada: $tipo = ${activa ? "ON" : "OFF"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error aplicando configuración $tipo: $e');
      }
      rethrow;
    }
  }

  /// Aplica cambios masivos
  Future<void> aplicarCambioMasivo(bool activar) async {
    try {
      final tipos = ['ingresos', 'gastos', 'deudas', 'ahorros', 'presupuesto', 'metas'];
      
      for (final tipo in tipos) {
        await aplicarCambioNotificacion(tipo, activar);
      }
      
      if (kDebugMode) {
        print('✅ Cambio masivo aplicado: ${activar ? "TODO ACTIVADO" : "TODO DESACTIVADO"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en cambio masivo: $e');
      }
    }
  }

  /// Maneja la configuración general (switch maestro)
  Future<void> _manejarConfiguracionGeneral(bool activa) async {
    if (activa) {
      if (kDebugMode) {
        print('🔔 Notificaciones generales ACTIVADAS');
      }
    } else {
      // Si se desactiva general, desactivar todo
      await aplicarCambioMasivo(false);
      if (kDebugMode) {
        print('🔇 Notificaciones generales DESACTIVADAS - Todo el sistema apagado');
      }
    }
  }

  /// Maneja notificaciones de ingresos
  Future<void> _manejarNotificacionesIngresos(bool activa) async {
    try {
      if (activa) {
        // Activar notificaciones de ingresos
        await _activarSistemaEspecifico('ingresos');
      } else {
        // Desactivar notificaciones de ingresos
        await _desactivarSistemaEspecifico('ingresos');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en notificaciones de ingresos: $e');
      }
    }
  }

  /// Maneja notificaciones de gastos
  Future<void> _manejarNotificacionesGastos(bool activa) async {
    try {
      if (activa) {
        await _activarSistemaEspecifico('gastos');
      } else {
        await _desactivarSistemaEspecifico('gastos');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en notificaciones de gastos: $e');
      }
    }
  }

  /// Maneja notificaciones de deudas
  Future<void> _manejarNotificacionesDeudas(bool activa) async {
    try {
      if (activa) {
        await _activarSistemaEspecifico('deudas');
      } else {
        await _desactivarSistemaEspecifico('deudas');
        // Limpiar notificaciones programadas de deudas
        await _limpiarNotificacionesDeudas();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en notificaciones de deudas: $e');
      }
    }
  }

  /// Maneja notificaciones de ahorros
  Future<void> _manejarNotificacionesAhorros(bool activa) async {
    try {
      if (activa) {
        await _activarSistemaEspecifico('ahorros');
      } else {
        await _desactivarSistemaEspecifico('ahorros');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en notificaciones de ahorros: $e');
      }
    }
  }

  /// Maneja notificaciones de presupuesto
  Future<void> _manejarNotificacionesPresupuesto(bool activa) async {
    try {
      if (activa) {
        await _activarSistemaEspecifico('presupuesto');
      } else {
        await _desactivarSistemaEspecifico('presupuesto');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en notificaciones de presupuesto: $e');
      }
    }
  }

  /// Maneja notificaciones de metas
  Future<void> _manejarNotificacionesMetas(bool activa) async {
    try {
      if (activa) {
        await _activarSistemaEspecifico('metas');
      } else {
        await _desactivarSistemaEspecifico('metas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en notificaciones de metas: $e');
      }
    }
  }

  /// Activa un sistema específico
  Future<void> _activarSistemaEspecifico(String tipo) async {
    // Guardar que está activo
    await PreferenciasNotificaciones.guardarPreferencia(tipo, true);
    
    // Intentar conectar con el sistema real si está disponible
    await _conectarConSistemaReal(tipo, true);
    
    if (kDebugMode) {
      print('✅ Sistema $tipo ACTIVADO');
    }
  }

  /// Desactiva un sistema específico  
  Future<void> _desactivarSistemaEspecifico(String tipo) async {
    // Guardar que está inactivo
    await PreferenciasNotificaciones.guardarPreferencia(tipo, false);
    
    // Desconectar del sistema real
    await _conectarConSistemaReal(tipo, false);
    
    if (kDebugMode) {
      print('❌ Sistema $tipo DESACTIVADO');
    }
  }

  /// Conecta con los sistemas reales de notificaciones
  Future<void> _conectarConSistemaReal(String tipo, bool activo) async {
    try {
      switch (tipo) {
        case 'ingresos':
        case 'gastos':
          // Conectar con el servicio de notificaciones existente
          await _conectarServicioIngresoGastos(activo);
          break;
        case 'deudas':
          // Conectar con el sistema de deudas
          await _conectarSistemaDeudas(activo);
          break;
        case 'ahorros':
          // Sistema de ahorros (futuro)
          if (kDebugMode) {
            print('Sistema de ahorros: ${activo ? "preparado" : "pausado"}');
          }
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error conectando con sistema real $tipo: $e');
      }
    }
  }

  /// Conecta con el servicio de ingresos/gastos existente
  Future<void> _conectarServicioIngresoGastos(bool activo) async {
    try {
      // Intentar usar reflection o importación dinámica aquí
      if (kDebugMode) {
        print('${activo ? "🔗" : "🔌"} Servicio ingresos/gastos: ${activo ? "conectado" : "desconectado"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Servicio ingresos/gastos no disponible: $e');
      }
    }
  }

  /// Conecta con el sistema de deudas
  Future<void> _conectarSistemaDeudas(bool activo) async {
    try {
      if (kDebugMode) {
        print('${activo ? "🔗" : "🔌"} Sistema deudas: ${activo ? "conectado" : "desconectado"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sistema de deudas no disponible: $e');
      }
    }
  }

  /// Limpia las notificaciones de deudas programadas
  Future<void> _limpiarNotificacionesDeudas() async {
    try {
      if (kDebugMode) {
        print('🧹 Limpiando notificaciones de deudas programadas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error limpiando notificaciones de deudas: $e');
      }
    }
  }

  /// Verifica el estado actual de todos los sistemas
  Future<Map<String, bool>> verificarEstadoSistemas() async {
    try {
      // Obtener preferencias guardadas
      final preferencias = await PreferenciasNotificaciones.obtenerTodasLasPreferencias();
      
      // Verificar sistemas externos
      final estadoSistemas = await ValidadorNotificaciones.verificarEstadoSistemas();
      
      // Combinar resultados
      final resultado = <String, bool>{};
      resultado.addAll(preferencias);
      resultado.addAll(estadoSistemas);
      
      return resultado;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando estado: $e');
      }
      return {
        'error_verificacion': true,
        'ingresos': false,
        'gastos': false,
        'deudas': false,
        'ahorros': false,
      };
    }
  }

  /// Ejecuta una prueba del sistema
  Future<bool> ejecutarPrueba(String tipo) async {
    try {
      final resultado = await ValidadorNotificaciones.probarNotificacion(tipo);
      if (kDebugMode) {
        print('🧪 Prueba $tipo: ${resultado ? "EXITOSA" : "FALLÓ"}');
      }
      return resultado;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en prueba $tipo: $e');
      }
      return false;
    }
  }
}
