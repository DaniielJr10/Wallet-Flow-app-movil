// 1. Archivo Principal - El que llaman las pantallas
// Servicio especializado para gestión de gastos.

import 'funcionalidades/referencias_gastos.dart';
import 'funcionalidades/acciones_lectura_gastos.dart';
import 'funcionalidades/acciones_escritura_gastos.dart';
import 'funcionalidades/calculos_estadisticas_gastos.dart';

/// Servicio especializado para gestión de gastos
/// Maneja operaciones CRUD y transacciones complejas.
class GastosServicio extends ReferenciasGastos
    with
        AccionesLecturaGastos,
        AccionesEscrituraGastos,
        CalculosEstadisticasGastos {
  
  // No requiere código adicional.
  // La clase integra todas las funcionalidades:
  // - crearGasto, actualizarGasto (de AccionesEscrituraGastos)
  // - obtenerGastos, obtenerGasto (de AccionesLecturaGastos)
  // - obtenerTotalGastos (de CalculosEstadisticasGastos)
}