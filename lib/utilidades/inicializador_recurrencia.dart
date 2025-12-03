/// INICIALIZADOR DE RECURRENCIA
/// Se ejecuta al iniciar la aplicación para procesar ingresos recurrentes pendientes.
/// Mantiene la funcionalidad automática funcionando correctamente.
import '../firebase/servicios/ingresoService/funcionalidades/recurrencia_servicio.dart';

class InicializadorRecurrencia {
  static final RecurrenciaServicio _recurrenciaServicio = RecurrenciaServicio();

  /// Procesa todos los ingresos recurrentes pendientes
  /// Se debe llamar al iniciar la aplicación
  static Future<void> procesarIngresosAlIniciar() async {
    try {
      final ingresosGenerados = await _recurrenciaServicio.generarIngresosPendientes();
      
      if (ingresosGenerados > 0) {
        print('✅ Se generaron $ingresosGenerados ingresos recurrentes pendientes');
      } else {
        print('ℹ️  No hay ingresos recurrentes pendientes');
      }
    } catch (e) {
      print('❌ Error al procesar ingresos recurrentes al iniciar: $e');
    }
  }

  /// Procesa ingresos recurrentes de forma manual
  /// Se puede llamar desde botones o acciones del usuario
  static Future<int> procesarManualmente() async {
    try {
      return await _recurrenciaServicio.generarIngresosPendientes();
    } catch (e) {
      print('❌ Error al procesar ingresos recurrentes manualmente: $e');
      return 0;
    }
  }
}