// 1. Archivo Principal - El que llaman las pantallas
// Servicio especializado para gestión de gastos.

import 'funcionalidades/referencias_gastos.dart';
import 'funcionalidades/acciones_lectura_gastos.dart';
import 'funcionalidades/acciones_escritura_gastos.dart';
import 'funcionalidades/calculos_estadisticas_gastos.dart';
import 'funcionalidades/frecuencia_servicio_gastos.dart';

/// Servicio especializado para gestión de gastos
/// Maneja operaciones CRUD y transacciones complejas.
class GastosServicio extends ReferenciasGastos
    with
        AccionesLecturaGastos,
        AccionesEscrituraGastos,
        CalculosEstadisticasGastos {
  
  // Servicio de frecuencias para gastos automáticos
  final FrecuenciaServicioGastos _frecuenciaServicio = FrecuenciaServicioGastos();
  
  /// Procesa gastos automáticos según frecuencias configuradas
  /// Llamar al inicio de la app para crear gastos pendientes
  Future<int> procesarGastosAutomaticos() async {
    return await _frecuenciaServicio.procesarGastosAutomaticos();
  }

  /// Crea gasto con frecuencia automática
  Future<String?> crearGastoConFrecuencia({
    required double monto,
    required DateTime fechaInicial,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    required frecuencia,
    String? cuentaAsociada,
  }) async {
    return await _frecuenciaServicio.crearGastoConFrecuencia(
      monto: monto,
      fechaInicial: fechaInicial,
      descripcion: descripcion,
      categoria: categoria,
      metodoPago: metodoPago,
      frecuencia: frecuencia,
      cuentaAsociada: cuentaAsociada,
    );
  }

  /// Actualiza gasto manejando cambios de frecuencia
  Future<String?> actualizarGastoConFrecuencia({
    required String gastoId,
    required double monto,
    required DateTime fecha,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    required frecuenciaActual,
    required nuevaFrecuencia,
    String? cuentaAsociada,
  }) async {
    return await _frecuenciaServicio.actualizarGastoConFrecuencia(
      gastoId: gastoId,
      monto: monto,
      fecha: fecha,
      descripcion: descripcion,
      categoria: categoria,
      metodoPago: metodoPago,
      frecuenciaActual: frecuenciaActual,
      nuevaFrecuencia: nuevaFrecuencia,
      cuentaAsociada: cuentaAsociada,
    );
  }

  // No requiere código adicional.
  // La clase integra todas las funcionalidades:
  // - crearGasto, actualizarGasto (de AccionesEscrituraGastos)
  // - obtenerGastos, obtenerGasto (de AccionesLecturaGastos)
  // - obtenerTotalGastos (de CalculosEstadisticasGastos)
}