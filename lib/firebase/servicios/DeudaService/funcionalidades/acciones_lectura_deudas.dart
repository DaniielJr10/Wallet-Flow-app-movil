// 3. Obtener listas de deudas
// Maneja la lectura de datos.

import 'referencias_deudas.dart';

mixin AccionesLecturaDeudas on ReferenciasDeudas {
  
  /// === OBTENER DEUDAS (FUTURE - Una sola vez) ===
  /// Método original solicitado
  Future<List<Map<String, dynamic>>> obtenerDeudas() async {
    if (userId == null) return [];
    
    try {
      final snapshot = await deudasRef().get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener deudas: $e');
      return [];
    }
  }

  /// === OBTENER DEUDAS (STREAM - Tiempo real) ===
  /// Recomendado para mantener la UI actualizada automáticamente
  Stream<List<Map<String, dynamic>>> obtenerDeudasStream() {
    if (userId == null) return const Stream.empty();
    
    return deudasRef().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}