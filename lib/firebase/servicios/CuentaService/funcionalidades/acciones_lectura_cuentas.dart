// 3. Obtener listas, documentos individuales y búsquedas
// Este archivo maneja todas las consultas de lectura y verificaciones.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_cuentas.dart';

mixin AccionesLecturaCuentas on ReferenciasCuentas {
  
  /// === OBTENER TODAS LAS CUENTAS ===
  Stream<QuerySnapshot> obtenerCuentas() {
    if (userId == null) {
      return const Stream.empty();
    }
    // Retorna stream de cuentas (temporalmente sin filtro para debug)
    return cuentasRef().snapshots();
  }

  /// === OBTENER CUENTA POR ID ===
  Future<DocumentSnapshot?> obtenerCuentaPorId(String cuentaId) async {
    try {
      if (userId == null) return null;

      final doc = await cuentasRef().doc(cuentaId).get();

      // Verificar que la cuenta pertenezca al usuario y exista
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['usuarioId'] == userId) {
          return doc;
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener cuenta: $e');
      return null;
    }
  }

  /// === BUSCAR CUENTAS POR TEXTO ===
  /// Filtra localmente por banco, número o alias
  Future<List<QueryDocumentSnapshot>> buscarCuentas(String textoBusqueda) async {
    try {
      if (userId == null || textoBusqueda.trim().isEmpty) return [];

      final texto = textoBusqueda.trim().toLowerCase();

      // Obtener todas las cuentas activas
      final snapshot = await cuentasRef()
          .where('activa', isEqualTo: true)
          .get();

      // Filtrar en memoria (Firestore no tiene "contains" nativo)
      final cuentasFiltradas = snapshot.docs.where((doc) {
        final data = doc.data();
        final banco = (data['banco'] ?? '').toString().toLowerCase();
        final numero = (data['numeroCuenta'] ?? '').toString().toLowerCase();
        final alias = (data['alias'] ?? '').toString().toLowerCase();

        return banco.contains(texto) ||
            numero.contains(texto) ||
            alias.contains(texto);
      }).toList();

      return cuentasFiltradas;
    } catch (e) {
      print('Error al buscar cuentas: $e');
      return [];
    }
  }

  /// === VERIFICACIONES DE EXISTENCIA (Helpers para escritura) ===
  
  /// Verifica si ya existe una cuenta con el número especificado
  Future<bool> verificarCuentaExistente(String numeroCuenta) async {
    try {
      if (userId == null) return false;

      final snapshot = await cuentasRef()
          .where('numeroCuenta', isEqualTo: numeroCuenta)
          .where('activa', isEqualTo: true)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar cuenta existente: $e');
      return false;
    }
  }

  /// Verifica duplicados excluyendo una cuenta específica (para ediciones)
  Future<bool> verificarCuentaExistenteExcepto(String numeroCuenta, String cuentaIdExcluir) async {
    try {
      if (userId == null) return false;

      final snapshot = await cuentasRef()
          .where('numeroCuenta', isEqualTo: numeroCuenta)
          .where('activa', isEqualTo: true)
          .get();

      // Filtrar el documento actual de los resultados
      final cuentasExistentes = snapshot.docs.where((doc) => doc.id != cuentaIdExcluir);

      return cuentasExistentes.isNotEmpty;
    } catch (e) {
      print('Error al verificar cuenta existente: $e');
      return false;
    }
  }
}