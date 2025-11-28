// 3. Getters, Streams y Validaciones de lectura
// Maneja consultas de datos y verificaciones necesarias para las transacciones.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_gastos.dart';

mixin AccionesLecturaGastos on ReferenciasGastos {
  
  /// === OBTENER TODOS LOS GASTOS ===
  Stream<QuerySnapshot> obtenerGastos() {
    if (userId == null) {
      return const Stream.empty();
    }
    try {
      return gastosRef()
          .orderBy('fecha', descending: true)
          .snapshots();
    } catch (e) {
      return const Stream.empty();
    }
  }

  /// === OBTENER UN GASTO ESPECÍFICO ===
  Future<DocumentSnapshot?> obtenerGasto(String gastoId) async {
    try {
      if (userId == null) return null;
      if (gastoId.trim().isEmpty) return null;
      
      return await gastosRef().doc(gastoId).get();
    } catch (e) {
      return null;
    }
  }

  /// === OBTENER GASTOS POR CATEGORÍA ===
  Stream<QuerySnapshot> obtenerGastosPorCategoria(String categoria) {
    if (userId == null) return const Stream.empty();
    
    return gastosRef()
        .where('categoria', isEqualTo: categoria)
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  /// === OBTENER GASTOS POR RANGO DE FECHAS ===
  Stream<QuerySnapshot> obtenerGastosPorFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) {
    if (userId == null) return const Stream.empty();
    
    return gastosRef()
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin))
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  // ====== MÉTODOS DE VALIDACIÓN (Helpers para escritura) ======
  // Se han hecho públicos (sin guion bajo) para ser accesibles desde el mixin de escritura

  /// Verifica si una cuenta existe
  Future<bool> verificarCuentaExiste(String cuentaId) async {
    try {
      if (userId == null) {
        print('❌ verificarCuentaExiste: Usuario no autenticado');
        return false;
      }
      
      print('🔍 verificarCuentaExiste: Verificando cuenta $cuentaId para usuario $userId');
      
      final doc = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('cuentas')
          .doc(cuentaId)
          .get();
      
      final existe = doc.exists;
      print('🔍 verificarCuentaExiste: Cuenta $cuentaId existe: $existe');
      
      if (existe) {
        print('🔍 verificarCuentaExiste: Datos de la cuenta: ${doc.data()}');
      }
      
      return existe;
    } catch (e) {
      print('❌ verificarCuentaExiste: Error $e');
      return false;
    }
  }

  /// Verifica si una cuenta tiene saldo suficiente
  Future<bool> verificarSaldoSuficiente(String cuentaId, double monto) async {
    try {
      if (userId == null) {
        print('❌ verificarSaldoSuficiente: Usuario no autenticado');
        return false;
      }
      
      print('🔍 verificarSaldoSuficiente: Verificando saldo para cuenta $cuentaId, monto requerido: $monto');
      
      final doc = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('cuentas')
          .doc(cuentaId)
          .get();
      
      if (!doc.exists) {
        print('❌ verificarSaldoSuficiente: Cuenta no existe');
        return false;
      }
      
      final saldo = (doc.data()!['saldo'] as num).toDouble();
      final suficiente = saldo >= monto;
      
      print('🔍 verificarSaldoSuficiente: Saldo actual: $saldo, Suficiente: $suficiente');
      
      return suficiente;
    } catch (e) {
      print('❌ verificarSaldoSuficiente: Error $e');
      return false;
    }
  }
}