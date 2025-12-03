// 1. Archivo Principal - El que llaman las pantallas
// Este servicio agrupa todas las funcionalidades distribuidas en los mixins.

import 'funcionalidades/referencias_base_ingreso.dart';
import 'funcionalidades/acciones_lectura_ingreso.dart';
import 'funcionalidades/acciones_escritura_ingreso.dart';
import 'funcionalidades/calculos_estadisticas_ingreso.dart';
import 'funcionalidades/frecuencia_servicio.dart';

/// Servicio para gestionar ingresos en Firebase
/// 
/// Combina las funcionalidades de lectura, escritura y estadísticas
/// manteniendo el código organizado en módulos.
class IngresosServicio extends ReferenciasBase 
    with AccionesLectura, AccionesEscritura, CalculosEstadisticas {
  
  final FrecuenciaServicio _frecuenciaServicio = FrecuenciaServicio();
  
  /// Inicializa y procesa ingresos automáticos pendientes
  IngresosServicio() {
    _procesarIngresosAutomaticos();
  }
  
  /// Procesa ingresos automáticos al inicializar
  Future<void> _procesarIngresosAutomaticos() async {
    try {
      await _frecuenciaServicio.procesarIngresosAutomaticos();
    } catch (e) {
      print('Error procesando ingresos automáticos: $e');
    }
  }
  
  /// Procesa manualmente los ingresos automáticos
  Future<int> procesarIngresosAutomaticos() async {
    return await _frecuenciaServicio.procesarIngresosAutomaticos();
  }
  
  // No se requiere código adicional aquí.
  // La clase hereda automáticamente:
  // - firestore, auth, userId (de ReferenciasBase)
  // - obtenerIngresos, obtenerIngresosStream (de AccionesLectura)
  // - registrarIngreso, actualizarIngreso (de AccionesEscritura)
  // - obtenerTotalIngresos (de CalculosEstadisticas)
}