// 1. Archivo Principal - El que llaman las pantallas
// Agrupa todas las funcionalidades de Cuentas (Lectura, Escritura, Estadísticas).

import 'funcionalidades/referencias_cuentas.dart';
import 'funcionalidades/acciones_lectura_cuentas.dart';
import 'funcionalidades/acciones_escritura_cuentas.dart';
import 'funcionalidades/calculos_estadisticas_cuentas.dart';

/// Servicio especializado para gestión de cuentas bancarias
/// 
/// Hereda y combina:
/// - ReferenciasCuentas (Base)
/// - AccionesLecturaCuentas (Getters y búsqueda)
/// - AccionesEscrituraCuentas (CRUD y Migración)
/// - CalculosEstadisticasCuentas (Reportes)
class CuentasServicio extends ReferenciasCuentas
    with
        AccionesLecturaCuentas,
        AccionesEscrituraCuentas,
        CalculosEstadisticasCuentas {
  
  // No requiere código adicional.
  // La clase ya tiene acceso a todos los métodos de los mixins:
  // crearCuenta, obtenerCuentas, calcularSaldoTotal, etc.
}