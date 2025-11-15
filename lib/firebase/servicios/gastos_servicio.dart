import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cuentas_servicio.dart';

/// Servicio para gestionar gastos en Firebase
class GastosServicio {
  /// Actualiza los datos de un gasto existente
  Future<String?> actualizarGasto({
    required String gastoId,
    required double monto,
    required DateTime fecha,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    String? cuentaAsociada,
    bool esRecurrente = false,
    String? frecuencia,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'Usuario no autenticado';
      }

      final gastoRef = _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('gastos')
          .doc(gastoId);

      final gastoData = {
        'monto': monto,
        'fecha': Timestamp.fromDate(fecha),
        'descripcion': descripcion,
        'categoria': categoria,
        'metodoPago': metodoPago,
        'cuentaAsociada': cuentaAsociada,
        'esRecurrente': esRecurrente,
        'frecuencia': frecuencia,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      await gastoRef.update(gastoData);
      return null;
    } catch (e) {
      print('Error al actualizar gasto: $e');
      return 'Error al actualizar el gasto: ${e.toString()}';
    }
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Registra un nuevo gasto y actualiza el saldo de la cuenta si es necesario
  Future<String?> registrarGasto({
    required double monto,
    required DateTime fecha,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    String? cuentaAsociada,
    bool esRecurrente = false,
    String? frecuencia,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'Usuario no autenticado';
      }

      // Validar que si se especifica cuenta asociada, esta exista
      if (cuentaAsociada != null && cuentaAsociada != 'ninguna') {
        final cuentaExiste = await _verificarCuentaExiste(cuentaAsociada);
        if (!cuentaExiste) {
          return 'La cuenta asociada no existe';
        }

        // Verificar que la cuenta tenga saldo suficiente
        final saldoSuficiente = await _verificarSaldoSuficiente(cuentaAsociada, monto);
        if (!saldoSuficiente) {
          return 'Saldo insuficiente en la cuenta';
        }
      }

      // Usar transacción para garantizar consistencia
      await _firestore.runTransaction((transaction) async {
        // 1. Crear el documento del gasto
        final gastoRef = _firestore
            .collection('usuarios')
            .doc(user.uid)
            .collection('gastos')
            .doc();

        final gastoData = {
          'monto': monto,
          'fecha': Timestamp.fromDate(fecha),
          'descripcion': descripcion,
          'categoria': categoria,
          'metodoPago': metodoPago,
          'cuentaAsociada': cuentaAsociada,
          'esRecurrente': esRecurrente,
          'frecuencia': frecuencia,
          'fechaCreacion': FieldValue.serverTimestamp(),
        };

        transaction.set(gastoRef, gastoData);

        // 2. Si hay cuenta asociada, descontar el monto del saldo
        if (cuentaAsociada != null && cuentaAsociada != 'ninguna') {
          final cuentaRef = _firestore
              .collection('usuarios')
              .doc(user.uid)
              .collection('cuentas')
              .doc(cuentaAsociada);

          // Obtener el documento de la cuenta
          final cuentaDoc = await transaction.get(cuentaRef);
          if (cuentaDoc.exists) {
            final cuentaData = cuentaDoc.data()!;
            final saldoActual = (cuentaData['saldo'] as num).toDouble();
            final nuevoSaldo = saldoActual - monto;

            // Actualizar el saldo
            transaction.update(cuentaRef, {
              'saldo': nuevoSaldo,
              'ultimaActualizacion': FieldValue.serverTimestamp(),
            });

            // Registrar el movimiento en el historial de la cuenta
            final movimientoRef = cuentaRef.collection('movimientos').doc();
            transaction.set(movimientoRef, {
              'tipo': 'gasto',
              'monto': -monto,
              'descripcion': 'Gasto: $descripcion',
              'categoria': categoria,
              'fecha': Timestamp.fromDate(fecha),
              'gastoId': gastoRef.id,
              'fechaCreacion': FieldValue.serverTimestamp(),
            });
          }
        }
      });

      return null; // Sin error
    } catch (e) {
      print('Error al registrar gasto: $e');
      return 'Error al registrar el gasto: ${e.toString()}';
    }
  }

  /// Verifica si una cuenta existe
  Future<bool> _verificarCuentaExiste(String cuentaId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('cuentas')
          .doc(cuentaId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error al verificar cuenta: $e');
      return false;
    }
  }

  /// Verifica si una cuenta tiene saldo suficiente
  Future<bool> _verificarSaldoSuficiente(String cuentaId, double monto) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('cuentas')
          .doc(cuentaId)
          .get();

      if (!doc.exists) return false;

      final saldo = (doc.data()!['saldo'] as num).toDouble();
      return saldo >= monto;
    } catch (e) {
      print('Error al verificar saldo: $e');
      return false;
    }
  }

  /// Obtiene todos los gastos del usuario
  Stream<List<Map<String, dynamic>>> obtenerGastos() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('gastos')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Convertir Timestamp a DateTime
        if (data['fecha'] is Timestamp) {
          data['fecha'] = (data['fecha'] as Timestamp).toDate();
        }
        
        return data;
      }).toList();
    });
  }

  /// Elimina un gasto y revierte el cambio en la cuenta si es necesario
  Future<String?> eliminarGasto(String gastoId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'Usuario no autenticado';
      }

      await _firestore.runTransaction((transaction) async {
        // 1. Obtener el gasto
        final gastoRef = _firestore
            .collection('usuarios')
            .doc(user.uid)
            .collection('gastos')
            .doc(gastoId);

        final gastoDoc = await transaction.get(gastoRef);
        if (!gastoDoc.exists) {
          throw Exception('El gasto no existe');
        }

        final gastoData = gastoDoc.data()!;
        final monto = (gastoData['monto'] as num).toDouble();
        final cuentaAsociada = gastoData['cuentaAsociada'] as String?;

        // 2. Si había cuenta asociada, devolver el monto
        if (cuentaAsociada != null && cuentaAsociada != 'ninguna') {
          final cuentaRef = _firestore
              .collection('usuarios')
              .doc(user.uid)
              .collection('cuentas')
              .doc(cuentaAsociada);

          final cuentaDoc = await transaction.get(cuentaRef);
          if (cuentaDoc.exists) {
            final cuentaData = cuentaDoc.data()!;
            final saldoActual = (cuentaData['saldo'] as num).toDouble();
            final nuevoSaldo = saldoActual + monto; // Sumar de vuelta

            transaction.update(cuentaRef, {
              'saldo': nuevoSaldo,
              'ultimaActualizacion': FieldValue.serverTimestamp(),
            });

            // Registrar el movimiento de reversión
            final movimientoRef = cuentaRef.collection('movimientos').doc();
            transaction.set(movimientoRef, {
              'tipo': 'reversa_gasto',
              'monto': monto,
              'descripcion': 'Reversión de gasto eliminado',
              'gastoId': gastoId,
              'fecha': FieldValue.serverTimestamp(),
              'fechaCreacion': FieldValue.serverTimestamp(),
            });
          }
        }

        // 3. Eliminar el gasto
        transaction.delete(gastoRef);
      });

      return null; // Sin error
    } catch (e) {
      print('Error al eliminar gasto: $e');
      return 'Error al eliminar el gasto: ${e.toString()}';
    }
  }
}