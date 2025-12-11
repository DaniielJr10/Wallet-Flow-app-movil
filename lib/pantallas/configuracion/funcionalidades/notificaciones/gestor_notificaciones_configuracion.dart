import 'package:flutter/foundation.dart';
import 'preferencias_notificaciones.dart';
import '../../../../firebase/servicios/NotificacionesService/notificaciones_servicio.dart';
import '../../../deudas/funcionalidades/notificaciones/notificaciones_deudas.dart';

/// Gestor que coordina todos los sistemas de notificaciones con las preferencias del usuario
class GestorNotificacionesConfiguracion {
  
  /// Aplica un cambio de configuración a los sistemas correspondientes
  Future<void> aplicarCambioNotificacion(String tipo, bool activa) async {
    try {
      switch (tipo) {
        case 'generales':
          // Si se desactivan las generales, desactivar todo el sistema
          if (!activa) {
            await _desactivarTodosLosSistemas();
          } else {
            await _activarSistemasSegundoPreferencias();
          }
          break;
          
        case 'ingresos':
          await _configurarNotificacionesIngresos(activa);
          break;
          
        case 'gastos':
          await _configurarNotificacionesGastos(activa);
          break;
          
        case 'deudas':
          await _configurarNotificacionesDeudas(activa);
          break;
          
        case 'ahorros':
          await _configurarNotificacionesAhorros(activa);
          break;
          
        case 'presupuesto':
          await _configurarNotificacionesPresupuesto(activa);
          break;
          
        case 'metas':
          await _configurarNotificacionesMetas(activa);
          break;
      }
      
      if (kDebugMode) {
        print('✅ Configuración de notificaciones $tipo: ${activa ? "activada" : "desactivada"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error aplicando configuración de $tipo: $e');
      }
      rethrow;
    }
  }

  /// Aplica cambios masivos a todos los sistemas
  Future<void> aplicarCambioMasivo(bool activar) async {
    try {
      if (activar) {
        await _activarTodosLosSistemas();
      } else {
        await _desactivarTodosLosSistemas();
      }
      
      if (kDebugMode) {
        print('✅ Cambio masivo de notificaciones: ${activar ? "activadas" : "desactivadas"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en cambio masivo: $e');
      }
      rethrow;
    }
  }

  /// Configura notificaciones de ingresos
  Future<void> _configurarNotificacionesIngresos(bool activa) async {
    try {
      // Aplicar al servicio existente de notificaciones
      await NotificacionesServicio.instance.configurarNotificaciones(activa);
      
      if (kDebugMode) {
        print('Notificaciones de ingresos: ${activa ? "activadas" : "desactivadas"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configurando notificaciones de ingresos: $e');
      }
    }
  }

  /// Configura notificaciones de gastos
  Future<void> _configurarNotificacionesGastos(bool activa) async {
    try {
      // El mismo servicio maneja gastos e ingresos
      await NotificacionesServicio.instance.configurarNotificaciones(activa);
      
      if (kDebugMode) {
        print('Notificaciones de gastos: ${activa ? "activadas" : "desactivadas"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configurando notificaciones de gastos: $e');
      }
    }
  }

  /// Configura notificaciones de deudas
  Future<void> _configurarNotificacionesDeudas(bool activa) async {
    try {
      if (!activa) {
        // Si se desactivan, limpiar todas las notificaciones de deudas programadas
        await NotificacionesDeudas.limpiarSistema();
      }
      // Nota: Cuando se reactiven, las deudas necesitarán ser reprogramadas
      
      if (kDebugMode) {
        print('Notificaciones de deudas: ${activa ? "activadas" : "desactivadas"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configurando notificaciones de deudas: $e');
      }
    }
  }

  /// Configura notificaciones de ahorros
  Future<void> _configurarNotificacionesAhorros(bool activa) async {
    try {
      // Por ahora solo logging, se puede extender cuando se implemente el sistema de ahorros
      if (kDebugMode) {
        print('Notificaciones de ahorros: ${activa ? "activadas" : "desactivadas"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configurando notificaciones de ahorros: $e');
      }
    }
  }

  /// Configura notificaciones de presupuesto
  Future<void> _configurarNotificacionesPresupuesto(bool activa) async {
    try {
      // Por ahora solo logging, se puede extender cuando se implemente el sistema de presupuestos
      if (kDebugMode) {
        print('Notificaciones de presupuesto: ${activa ? "activadas" : "desactivadas"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configurando notificaciones de presupuesto: $e');
      }
    }
  }

  /// Configura notificaciones de metas
  Future<void> _configurarNotificacionesMetas(bool activa) async {
    try {
      // Por ahora solo logging, se puede extender cuando se implemente el sistema de metas
      if (kDebugMode) {
        print('Notificaciones de metas: ${activa ? "activadas" : "desactivadas"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configurando notificaciones de metas: $e');
      }
    }
  }

  /// Desactiva todos los sistemas de notificaciones
  Future<void> _desactivarTodosLosSistemas() async {
    try {
      // Desactivar servicio principal
      await NotificacionesServicio.instance.configurarNotificaciones(false);
      
      // Limpiar notificaciones de deudas
      await NotificacionesDeudas.limpiarSistema();
      
      if (kDebugMode) {
        print('🔇 Todos los sistemas de notificaciones desactivados');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error desactivando todos los sistemas: $e');
      }
    }
  }

  /// Activa todos los sistemas de notificaciones
  Future<void> _activarTodosLosSistemas() async {
    try {
      // Activar servicio principal
      await NotificacionesServicio.instance.configurarNotificaciones(true);
      
      if (kDebugMode) {
        print('🔔 Todos los sistemas de notificaciones activados');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error activando todos los sistemas: $e');
      }
    }
  }

  /// Activa sistemas según las preferencias individuales guardadas
  Future<void> _activarSistemasSegundoPreferencias() async {
    try {
      final preferencias = await PreferenciasNotificaciones.obtenerTodasLasPreferencias();
      
      // Aplicar cada preferencia individual
      for (final entrada in preferencias.entries) {
        if (entrada.key != 'generales' && entrada.value) {
          await aplicarCambioNotificacion(entrada.key, entrada.value);
        }
      }
      
      if (kDebugMode) {
        print('✅ Sistemas activados según preferencias individuales');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error activando sistemas según preferencias: $e');
      }
    }
  }

  /// Verifica el estado actual de las notificaciones
  Future<Map<String, bool>> verificarEstadoSistemas() async {
    try {
      final estadoGeneral = await NotificacionesServicio.instance.notificacionesActivas();
      final estadisticasDeudas = await NotificacionesDeudas.gestor.obtenerEstadisticas();
      
      return {
        'servicio_principal': estadoGeneral,
        'sistema_deudas_activo': estadisticasDeudas['notificacionesProgramadas'] > 0,
        'timestamp_valido': true,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando estado de sistemas: $e');
      }
      return {
        'error_ocurrido': true,
        'servicio_principal': false,
        'sistema_deudas_activo': false,
      };
    }
  }
}
