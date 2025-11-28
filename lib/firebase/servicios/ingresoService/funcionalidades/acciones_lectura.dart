// 3. Obtener listas y documentos individuales
// Este archivo maneja todas las consultas de lectura (GET/Stream) de ingresos.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_base.dart';

mixin AccionesLectura on ReferenciasBase {
  /// === OBTENER INGRESOS DEL USUARIO ===
  /// 
  /// Retorna un Stream con todos los ingresos del usuario ordenados por fecha
  Stream<List<Map<String, dynamic>>> obtenerIngresos() {
    if (userId == null) {
      return Stream.value([]);
    }

    try {
      // Consulta simple sin índices compuestos
      return ingresosRef().snapshots().map((snapshot) {
        final ingresos = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;

          // Convertir Timestamp a DateTime
          if (data['fecha'] is Timestamp) {
            data['fecha'] = (data['fecha'] as Timestamp).toDate();
          }

          return data;
        }).toList();

        // Ordenar por fecha descendente en el cliente
        ingresos.sort((a, b) {
          final fechaA = a['fecha'] as DateTime;
          final fechaB = b['fecha'] as DateTime;
          return fechaB.compareTo(fechaA);
        });

        return ingresos;
      });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// === OBTENER INGRESO POR ID ===
  /// 
  /// Obtiene un ingreso específico por su ID
  Future<Map<String, dynamic>?> obtenerIngresoPorId(String ingresoId) async {
    try {
      if (userId == null) return null;

      final doc = await ingresosRef().doc(ingresoId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;

      // Convertir Timestamp a DateTime
      if (data['fecha'] is Timestamp) {
        data['fecha'] = (data['fecha'] as Timestamp).toDate();
      }

      return data;
    } catch (e) {
      return null;
    }
  }

  /// === OBTENER INGRESOS COMO STREAM DE QUERYSNAPSHOT ===
  /// 
  /// Similar al patrón usado en gastos - retorna QuerySnapshot para compatibilidad
  Stream<QuerySnapshot> obtenerIngresosStream() {
    if (userId == null) {
      return const Stream.empty();
    }

    return ingresosRef()
        .orderBy('fecha', descending: true)
        .snapshots();
  }
}