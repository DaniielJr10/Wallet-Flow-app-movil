import 'package:flutter/foundation.dart';
import 'gestor_notificaciones_deudas.dart';

/// Clase para inicializar y configurar todo el sistema de notificaciones de deudas
/// NOTA: Este inicializador es OPCIONAL. El sistema se inicializa automáticamente 
/// cuando se usa por primera vez.
class InicializadorNotificacionesDeudas {
  /// Inicializa todo el sistema de notificaciones de forma manual (OPCIONAL)
  /// El sistema ya se inicializa automáticamente cuando es necesario
  static Future<void> inicializar() async {
    try {
      // El sistema se auto-inicializa, solo forzamos la inicialización
      await GestorNotificacionesDeudas().inicializar();

      if (kDebugMode) {
        print('✅ Sistema de notificaciones de deudas inicializado manualmente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al inicializar sistema de notificaciones: $e');
      }
      rethrow;
    }
  }

  /// Verifica si el sistema está inicializado
  static bool get estaInicializado => true; // Siempre true porque es automático

  /// Configura las notificaciones para una lista de deudas
  static Future<void> configurarNotificacionesParaDeudas(List<Map<String, dynamic>> deudas) async {
    // No necesita inicialización manual, se hace automáticamente
    final gestor = GestorNotificacionesDeudas();
    final deudasNotificacion = <DeudaNotificacion>[];

    for (final deudaMap in deudas) {
      try {
        final deuda = DeudaNotificacion(
          id: deudaMap['id'] ?? 0,
          nombre: deudaMap['nombre'] ?? 'Deuda sin nombre',
          monto: (deudaMap['monto'] ?? 0.0).toDouble(),
          fechaVencimiento: deudaMap['fechaVencimiento'] ?? DateTime.now(),
          activa: deudaMap['activa'] ?? true,
        );
        deudasNotificacion.add(deuda);
      } catch (e) {
        if (kDebugMode) {
          print('Error al procesar deuda: $e');
        }
      }
    }

    await gestor.actualizarDeudasMasivamente(deudasNotificacion);

    if (kDebugMode) {
      print('✅ Configuradas notificaciones para ${deudasNotificacion.length} deudas automáticamente');
    }
  }

  /// Función de utilidad para crear una deuda de prueba
  static Future<void> crearDeudaDePrueba() async {
    // No necesita inicialización manual, se hace automáticamente
    final deudaPrueba = DeudaNotificacion(
      id: 999,
      nombre: 'Deuda de Prueba',
      monto: 500.0,
      fechaVencimiento: DateTime.now().add(const Duration(days: 2)),
      activa: true,
    );

    await GestorNotificacionesDeudas().agregarDeuda(deudaPrueba);

    if (kDebugMode) {
      print('✅ Deuda de prueba creada automáticamente - vence en 2 días');
    }
  }

  /// Limpia todo el sistema de notificaciones
  static Future<void> limpiarSistema() async {
    await GestorNotificacionesDeudas().limpiarTodo();
    
    if (kDebugMode) {
      print('🧹 Sistema de notificaciones limpiado');
    }
  }
}
