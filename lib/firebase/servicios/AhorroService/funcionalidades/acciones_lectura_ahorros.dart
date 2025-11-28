// 3. Obtener listas y documentos individuales
// Maneja la lectura de metas de ahorro.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_ahorros.dart';

mixin AccionesLecturaAhorros on ReferenciasAhorros {
  
  /// === OBTENER METAS DE AHORRO ===
  Stream<List<Map<String, dynamic>>> obtenerMetasAhorro() {
    if (userId == null) return Stream.value([]);
    
    try {
      return ahorrosRef().snapshots().map((snapshot) {
        final metas = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          
          // Convertir Timestamps a DateTime
          if (data['fechaObjetivo'] is Timestamp) {
            data['fechaObjetivo'] = (data['fechaObjetivo'] as Timestamp).toDate();
          }
          if (data['fechaCreacion'] is Timestamp) {
            data['fechaCreacion'] = (data['fechaCreacion'] as Timestamp).toDate();
          }
          
          return data;
        }).toList();
        
        // Ordenar por fecha de creación descendente (las más nuevas primero)
        metas.sort((a, b) {
          final fechaA = a['fechaCreacion'] as DateTime?;
          final fechaB = b['fechaCreacion'] as DateTime?;
          if (fechaA == null && fechaB == null) return 0;
          if (fechaA == null) return 1;
          if (fechaB == null) return -1;
          return fechaB.compareTo(fechaA);
        });
        
        return metas;
      });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// === OBTENER UNA META ESPECÍFICA ===
  Future<Map<String, dynamic>?> obtenerMetaPorId(String metaId) async {
    try {
      if (userId == null) return null;
      
      final doc = await ahorrosRef().doc(metaId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      
      if (data['fechaObjetivo'] is Timestamp) {
        data['fechaObjetivo'] = (data['fechaObjetivo'] as Timestamp).toDate();
      }
      
      return data;
    } catch (e) {
      return null;
    }
  }
}