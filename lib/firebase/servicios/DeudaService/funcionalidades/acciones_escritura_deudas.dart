// 4. Crear, Editar y Eliminar
// Lógica para modificar las deudas.

import 'referencias_deudas.dart';

mixin AccionesEscrituraDeudas on ReferenciasDeudas {
  
  /// === CREAR UNA NUEVA DEUDA ===
  Future<String?> crearDeuda(Map<String, dynamic> deuda) async {
    try {
      if (userId == null) return 'Usuario no autenticado';
      
      // Aseguramos que tenga fecha de creación
      if (!deuda.containsKey('fechaCreacion')) {
        deuda['fechaCreacion'] = DateTime.now();
      }
      
      await deudasRef().add(deuda);
      return null; // Éxito
    } catch (e) {
      return 'Error al crear deuda: $e';
    }
  }

  /// === EDITAR UNA DEUDA EXISTENTE ===
  Future<String?> editarDeuda(String deudaId, Map<String, dynamic> datosActualizados) async {
    try {
      if (userId == null) return 'Usuario no autenticado';
      
      await deudasRef().doc(deudaId).update(datosActualizados);
      return null; // Éxito
    } catch (e) {
      return 'Error al editar deuda: $e';
    }
  }

  /// === ELIMINAR UNA DEUDA ===
  Future<String?> eliminarDeuda(String deudaId) async {
    try {
      if (userId == null) return 'Usuario no autenticado';
      
      await deudasRef().doc(deudaId).delete();
      return null; // Éxito
    } catch (e) {
      return 'Error al eliminar deuda: $e';
    }
  }
}