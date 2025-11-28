// 4. Lógica compleja: Crear, Editar, Eliminar y Migrar
// Este archivo maneja las modificaciones a la base de datos de cuentas.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_cuentas.dart';

mixin AccionesEscrituraCuentas on ReferenciasCuentas {
  
  /// === CREAR NUEVA CUENTA ===
  Future<String?> crearCuenta({
    required String banco,
    required String numeroCuenta,
    required String tipo,
    required double saldo,
    String? alias,
  }) async {
    try {
      if (userId == null) return 'Usuario no autenticado';

      // Validaciones básicas
      if (banco.trim().isEmpty) return 'El nombre del banco es requerido';
      if (numeroCuenta.trim().isEmpty) return 'El número de cuenta es requerido';
      if (saldo < 0) return 'El saldo no puede ser negativo';

      // Verificar duplicados (Consulta directa para asegurar independencia del mixin)
      final duplicados = await cuentasRef()
          .where('numeroCuenta', isEqualTo: numeroCuenta.trim())
          .where('activa', isEqualTo: true)
          .limit(1)
          .get();
      
      if (duplicados.docs.isNotEmpty) {
        return 'Ya existe una cuenta con este número';
      }

      // Crear documento
      await cuentasRef().add({
        'banco': banco.trim(),
        'numeroCuenta': numeroCuenta.trim(),
        'tipo': tipo,
        'saldo': saldo,
        'alias': alias?.trim(),
        'usuarioId': userId,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'fechaModificacion': FieldValue.serverTimestamp(),
        'activa': true,
      });

      return null;
    } catch (e) {
      return 'Error al crear cuenta: $e';
    }
  }

  /// === ACTUALIZAR CUENTA ===
  Future<String?> actualizarCuenta({
    required String cuentaId,
    required String banco,
    required String numeroCuenta,
    required String tipo,
    required double saldo,
    String? alias,
  }) async {
    try {
      if (userId == null) return 'Usuario no autenticado';

      if (banco.trim().isEmpty) return 'El nombre del banco es requerido';
      if (numeroCuenta.trim().isEmpty) return 'El número de cuenta es requerido';
      if (saldo < 0) return 'El saldo no puede ser negativo';

      final cuentaRef = cuentasRef().doc(cuentaId);
      final cuentaDoc = await cuentaRef.get();

      if (!cuentaDoc.exists) {
        return 'Cuenta no encontrada';
      }

      // Verificar duplicados excluyendo la cuenta actual
      final snapshot = await cuentasRef()
          .where('numeroCuenta', isEqualTo: numeroCuenta.trim())
          .where('activa', isEqualTo: true)
          .get();
      
      // Si hay resultados que NO son la cuenta que estamos editando...
      final existeOtra = snapshot.docs.any((doc) => doc.id != cuentaId);

      if (existeOtra) {
        return 'Ya existe otra cuenta con este número';
      }

      // Actualizar
      await cuentaRef.update({
        'banco': banco.trim(),
        'numeroCuenta': numeroCuenta.trim(),
        'tipo': tipo,
        'saldo': saldo,
        'alias': alias?.trim(),
        'fechaModificacion': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Error al actualizar cuenta: $e';
    }
  }

  /// === ELIMINAR CUENTA (Lógica) ===
  Future<String?> eliminarCuenta(String cuentaId) async {
    try {
      if (userId == null) return 'Usuario no autenticado';

      final docRef = cuentasRef().doc(cuentaId);
      final doc = await docRef.get();

      if (!doc.exists) return 'Cuenta no encontrada';

      // Marcar como inactiva (Soft Delete)
      await docRef.update({
        'activa': false,
        'fechaEliminacion': FieldValue.serverTimestamp(),
        'fechaModificacion': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Error al eliminar cuenta: $e';
    }
  }

  /// === ELIMINAR CUENTA PERMANENTE (Física) ===
  Future<String?> eliminarCuentaPermanente(String cuentaId) async {
    try {
      if (userId == null) return 'Usuario no autenticado';

      final docRef = cuentasRef().doc(cuentaId);
      final doc = await docRef.get();

      if (!doc.exists) return 'Cuenta no encontrada';

      // Eliminar documento (Hard Delete)
      await docRef.delete();

      return null;
    } catch (e) {
      return 'Error al eliminar cuenta permanentemente: $e';
    }
  }

  /// === ACTUALIZAR SALDO ===
  Future<String?> actualizarSaldo({
    required String cuentaId,
    required double nuevoSaldo,
  }) async {
    try {
      if (userId == null) return 'Usuario no autenticado';
      if (nuevoSaldo < 0) return 'El saldo no puede ser negativo';

      final docRef = cuentasRef().doc(cuentaId);
      
      // Validar existencia antes de actualizar
      final doc = await docRef.get();
      if (!doc.exists) return 'Cuenta no encontrada';

      await docRef.update({
        'saldo': nuevoSaldo,
        'fechaModificacion': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Error al actualizar saldo: $e';
    }
  }

  /// === MIGRACIÓN ===
  Future<String?> migrarCuentasDesdeColeccionRaiz() async {
    try {
      if (userId == null) return 'Usuario no autenticado';

      // Busca en la colección raíz antigua
      final origen = await firestore
          .collection(ReferenciasCuentas.coleccionCuentas) // Acceso a constante estática
          .where('usuarioId', isEqualTo: userId)
          .get();

      if (origen.docs.isEmpty) return null;

      final batch = firestore.batch();
      for (final doc in origen.docs) {
        final data = doc.data();
        final destinoDoc = cuentasRef().doc(doc.id);
        batch.set(destinoDoc, data, SetOptions(merge: true));
        batch.delete(doc.reference);
      }

      await batch.commit();
      return null;
    } catch (e) {
      return 'Error al migrar cuentas: $e';
    }
  }
}