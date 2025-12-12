// 4. Crear, Actualizar, Agregar Dinero, Eliminar
// Lógica transaccional para modificar las metas de ahorro.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_ahorros.dart';

mixin AccionesEscrituraAhorros on ReferenciasAhorros {
  
  /// === CREAR NUEVA META DE AHORRO ===
  /// Retorna un Map con 'error' (String?) y 'metaId' (String?) 
  Future<Map<String, String?>> crearMetaAhorro({
    required String nombre,
    required double montoInicial,
    required double montoObjetivo,
    required DateTime fechaObjetivo,
    required String categoria,
  }) async {
    try {
      if (userId == null) return {'error': 'Usuario no autenticado', 'metaId': null};
      if (nombre.trim().isEmpty) return {'error': 'El nombre es requerido', 'metaId': null};
      if (montoObjetivo <= 0) return {'error': 'El monto objetivo debe ser mayor a 0', 'metaId': null};

      String? metaId;
      await firestore.runTransaction((transaction) async {
        final metaRef = ahorrosRef().doc();
        metaId = metaRef.id; // Guardar el ID generado
        final metaData = {
          'nombre': nombre.trim(),
          'montoInicial': montoInicial,
          'montoActual': montoInicial, // El monto actual empieza con el inicial
          'montoObjetivo': montoObjetivo,
          'fechaObjetivo': Timestamp.fromDate(fechaObjetivo),
          'categoria': categoria,
          'fechaCreacion': FieldValue.serverTimestamp(), // Mejor usar serverTimestamp
        };
        transaction.set(metaRef, metaData);
      });
      return {'error': null, 'metaId': metaId};
    } catch (e) {
      return {'error': 'Error al crear la meta: ${e.toString()}', 'metaId': null};
    }
  }

  /// === ACTUALIZAR META DE AHORRO (Edición de datos básicos) ===
  Future<String?> actualizarMetaAhorro({
    required String metaId,
    required String nombre,
    required double montoObjetivo,
    required DateTime fechaObjetivo,
    required String categoria,
  }) async {
    try {
      if (userId == null) return 'Usuario no autenticado';
      if (nombre.trim().isEmpty) return 'El nombre es requerido';
      if (montoObjetivo <= 0) return 'El monto objetivo debe ser mayor a 0';
      
      await firestore.runTransaction((transaction) async {
        final metaRef = ahorrosRef().doc(metaId);
        
        // Verificar existencia dentro de la transacción
        final snapshot = await transaction.get(metaRef);
        if (!snapshot.exists) throw Exception('Meta no encontrada');

        transaction.update(metaRef, {
          'nombre': nombre.trim(),
          'montoObjetivo': montoObjetivo,
          'fechaObjetivo': Timestamp.fromDate(fechaObjetivo),
          'categoria': categoria,
          'fechaModificacion': FieldValue.serverTimestamp(),
        });
      });
      return null;
    } catch (e) {
      return 'Error al actualizar la meta: ${e.toString()}';
    }
  }

  /// === AGREGAR (O RETIRAR) MONTO A META DE AHORRO ===
  /// Usa valores positivos para agregar y negativos para retirar
  Future<String?> agregarMontoMeta({
    required String metaId,
    required double montoAgregar,
  }) async {
    try {
      if (userId == null) return 'Usuario no autenticado';
      // Nota: Permitimos montoAgregar negativo si quisieras implementar "retirar ahorros"
      if (montoAgregar == 0) return 'El monto debe ser diferente de 0';
      
      await firestore.runTransaction((transaction) async {
        final metaRef = ahorrosRef().doc(metaId);
        final metaDoc = await transaction.get(metaRef);
        
        if (!metaDoc.exists) throw Exception('Meta no encontrada');
        
        final montoActual = (metaDoc.data()!['montoActual'] as num).toDouble();
        final nuevoMonto = montoActual + montoAgregar;

        // Validación opcional: evitar saldo negativo en la meta
        if (nuevoMonto < 0) {
           throw Exception('El retiro excede el monto actual de la meta');
        }

        transaction.update(metaRef, {
          'montoActual': nuevoMonto,
          'fechaUltimoAporte': FieldValue.serverTimestamp(),
        });
      });
      return null;
    } catch (e) {
      return 'Error al agregar monto: ${e.toString()}';
    }
  }

  /// === ELIMINAR META DE AHORRO ===
  Future<String?> eliminarMetaAhorro(String metaId) async {
    try {
      if (userId == null) return 'Usuario no autenticado';
      
      await firestore.runTransaction((transaction) async {
        final metaRef = ahorrosRef().doc(metaId);
        transaction.delete(metaRef);
      });
      return null;
    } catch (e) {
      return 'Error al eliminar la meta: ${e.toString()}';
    }
  }
}