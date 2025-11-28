// 1. Archivo Principal - El que llaman las pantallas
// Este servicio agrupa todas las funcionalidades distribuidas en los mixins.

import 'funcionalidades/referencias_base_ingreso.dart';
import 'funcionalidades/acciones_lectura_ingreso.dart';
import 'funcionalidades/acciones_escritura_ingreso.dart';
import 'funcionalidades/calculos_estadisticas_ingreso.dart';

/// Servicio para gestionar ingresos en Firebase
/// 
/// Combina las funcionalidades de lectura, escritura y estadística
/// manteniendo el código organizado en módulos.
class IngresosServicio extends ReferenciasBase 
    with AccionesLectura, AccionesEscritura, CalculosEstadisticas {
  
  // No se requiere código adicional aquí.
  // La clase hereda automáticamente:
  // - firestore, auth, userId (de ReferenciasBase)
  // - obtenerIngresos, obtenerIngresosStream (de AccionesLectura)
  // - registrarIngreso, actualizarIngreso (de AccionesEscritura)
  // - obtenerTotalIngresos (de CalculosEstadisticas)
}