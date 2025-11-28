// 1. Archivo Principal - El que llaman las pantallas
// Servicio para gestionar deudas.

import 'funcionalidades/referencias_deudas.dart';
import 'funcionalidades/acciones_lectura_deudas.dart';
import 'funcionalidades/acciones_escritura_deudas.dart';

/// Servicio para gestionar deudas en Firebase
/// Estructura: usuarios/{uid}/deudas/{deudaId}
class DeudasServicio extends ReferenciasDeudas
    with
        AccionesLecturaDeudas,
        AccionesEscrituraDeudas {
  
  // La clase integra todas las funcionalidades:
  // - crearDeuda, editarDeuda, eliminarDeuda (Escritura)
  // - obtenerDeudas, obtenerDeudasStream (Lectura)
}