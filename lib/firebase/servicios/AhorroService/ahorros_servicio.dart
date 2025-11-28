// 1. Archivo Principal - El que llaman las pantallas
// Servicio para gestionar metas de ahorro.

import 'funcionalidades/referencias_ahorros.dart';
import 'funcionalidades/acciones_lectura_ahorros.dart';
import 'funcionalidades/acciones_escritura_ahorros.dart';

/// Servicio para gestionar metas de ahorro en Firebase
/// Estructura: usuarios/{uid}/ahorros/{metaId}
class AhorrosServicio extends ReferenciasAhorros
    with
        AccionesLecturaAhorros,
        AccionesEscrituraAhorros {
  
  // La clase integra todas las funcionalidades:
  // - crearMetaAhorro, actualizarMetaAhorro, agregarMontoMeta, eliminarMetaAhorro (Escritura)
  // - obtenerMetasAhorro, obtenerMetaPorId (Lectura)
}