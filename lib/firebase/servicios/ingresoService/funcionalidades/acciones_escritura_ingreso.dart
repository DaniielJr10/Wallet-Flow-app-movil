// 4. Lógica compleja: Crear, Editar, Eliminar con transacciones
// Este archivo maneja las operaciones que modifican la base de datos y saldos.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_base_ingreso.dart';

mixin AccionesEscritura on ReferenciasBase {
  /// === CREAR NUEVO INGRESO ===
  Future<String?> registrarIngreso({
    required double monto,
    required DateTime fecha,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    String? cuentaAsociada,
  }) async {
    try {
      if (userId == null) return 'Usuario no autenticado';
      if (monto <= 0) return 'El monto debe ser mayor a 0';
      if (descripcion.trim().isEmpty) return 'La descripción es requerida';

      await firestore.runTransaction((transaction) async {
        // === FASE DE LECTURAS ===
        DocumentSnapshot<Map<String, dynamic>>? cuentaDoc;

        if (cuentaAsociada != null && cuentaAsociada.isNotEmpty && cuentaAsociada != 'ninguna') {
          final cuentaRef = firestore
              .collection('usuarios')
              .doc(userId)
              .collection('cuentas')
              .doc(cuentaAsociada);

          cuentaDoc = await transaction.get(cuentaRef);
          if (!cuentaDoc.exists) throw Exception('La cuenta asociada no existe');
        }

        // === FASE DE ESCRITURAS ===
        final ingresoRef = ingresosRef().doc();

        final ingresoData = {
          'monto': monto,
          'fecha': Timestamp.fromDate(fecha),
          'descripcion': descripcion.trim(),
          'categoria': categoria,
          'metodoPago': metodoPago,
          'cuentaAsociada': cuentaAsociada != 'ninguna' ? cuentaAsociada : null,
          'fechaCreacion': FieldValue.serverTimestamp(),
        };

        transaction.set(ingresoRef, ingresoData);

        if (cuentaDoc != null && cuentaDoc.exists) {
          final cuentaData = cuentaDoc.data()!;
          final saldoActual = (cuentaData['saldo'] as num?)?.toDouble() ?? 0.0;
          final nuevoSaldo = saldoActual + monto;

          transaction.update(cuentaDoc.reference, {
            'saldo': nuevoSaldo,
            'ultimaActualizacion': FieldValue.serverTimestamp(),
          });

          final movimientoRef = cuentaDoc.reference.collection('movimientos').doc();
          transaction.set(movimientoRef, {
            'tipo': 'ingreso',
            'monto': monto,
            'descripcion': 'Ingreso: $descripcion',
            'categoria': categoria,
            'fecha': Timestamp.fromDate(fecha),
            'ingresoId': ingresoRef.id,
            'fechaCreacion': FieldValue.serverTimestamp(),
          });
        }
      });

      return null;
    } catch (e) {
      return 'Error al registrar el ingreso: ${e.toString()}';
    }
  }

  /// === ACTUALIZAR INGRESO ===
  Future<String?> actualizarIngreso({
    required String ingresoId,
    required double monto,
    required DateTime fecha,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    String? cuentaAsociada,
  }) async {
    try {
      if (userId == null) return 'Usuario no autenticado';
      if (monto <= 0) return 'El monto debe ser mayor a 0';
      if (descripcion.trim().isEmpty) return 'La descripción es requerida';

      await firestore.runTransaction((transaction) async {
        // === FASE DE LECTURAS ===
        final ingresoRef = ingresosRef().doc(ingresoId);
        final ingresoDoc = await transaction.get(ingresoRef);

        if (!ingresoDoc.exists) throw Exception('El ingreso no existe');

        final datosActuales = ingresoDoc.data()!;
        final montoAnterior = (datosActuales['monto'] as num).toDouble();
        final cuentaAnterior = datosActuales['cuentaAsociada'] as String?;

        DocumentSnapshot<Map<String, dynamic>>? cuentaAntDoc;
        if (cuentaAnterior != null && cuentaAnterior.isNotEmpty && cuentaAnterior != 'ninguna') {
          final cuentaAntRef = firestore
              .collection('usuarios')
              .doc(userId)
              .collection('cuentas')
              .doc(cuentaAnterior);
          cuentaAntDoc = await transaction.get(cuentaAntRef);
        }

        DocumentSnapshot<Map<String, dynamic>>? cuentaNuevaDoc;
        if (cuentaAsociada != null && cuentaAsociada.isNotEmpty && cuentaAsociada != 'ninguna') {
          final cuentaNuevaRef = firestore
              .collection('usuarios')
              .doc(userId)
              .collection('cuentas')
              .doc(cuentaAsociada);
          
          if (cuentaAsociada != cuentaAnterior) {
            cuentaNuevaDoc = await transaction.get(cuentaNuevaRef);
          } else {
            cuentaNuevaDoc = cuentaAntDoc;
          }
          
          if (cuentaNuevaDoc != null && !cuentaNuevaDoc.exists) {
            throw Exception('La cuenta asociada no existe');
          }
        }

        // === FASE DE ESCRITURAS ===
        final nuevosdatos = {
          'monto': monto,
          'fecha': Timestamp.fromDate(fecha),
          'descripcion': descripcion.trim(),
          'categoria': categoria,
          'metodoPago': metodoPago,
          'cuentaAsociada': cuentaAsociada != 'ninguna' ? cuentaAsociada : null,
          'fechaModificacion': FieldValue.serverTimestamp(),
        };

        transaction.update(ingresoRef, nuevosdatos);

        if (cuentaAnterior != cuentaAsociada) {
          if (cuentaAntDoc != null && cuentaAntDoc.exists) {
            final saldoAnterior = (cuentaAntDoc.data()!['saldo'] as num?)?.toDouble() ?? 0.0;
            transaction.update(cuentaAntDoc.reference, {
              'saldo': saldoAnterior - montoAnterior,
              'ultimaActualizacion': FieldValue.serverTimestamp(),
            });
          }

          if (cuentaNuevaDoc != null && cuentaNuevaDoc.exists) {
            final saldoNuevo = (cuentaNuevaDoc.data()!['saldo'] as num?)?.toDouble() ?? 0.0;
            transaction.update(cuentaNuevaDoc.reference, {
              'saldo': saldoNuevo + monto,
              'ultimaActualizacion': FieldValue.serverTimestamp(),
            });

            final movimientoRef = cuentaNuevaDoc.reference.collection('movimientos').doc();
            transaction.set(movimientoRef, {
              'tipo': 'ingreso_actualizado',
              'monto': monto,
              'descripcion': 'Ingreso actualizado: $descripcion',
              'categoria': categoria,
              'fecha': Timestamp.fromDate(fecha),
              'ingresoId': ingresoId,
              'fechaCreacion': FieldValue.serverTimestamp(),
            });
          }
        } else if (cuentaAsociada != null && cuentaAsociada != 'ninguna') {
          if (cuentaAntDoc != null && cuentaAntDoc.exists) {
            final saldoActual = (cuentaAntDoc.data()!['saldo'] as num?)?.toDouble() ?? 0.0;
            final diferencia = monto - montoAnterior;
            
            transaction.update(cuentaAntDoc.reference, {
              'saldo': saldoActual + diferencia,
              'ultimaActualizacion': FieldValue.serverTimestamp(),
            });
          }
        }
      });

      return null;
    } catch (e) {
      return 'Error al actualizar el ingreso: ${e.toString()}';
    }
  }

  /// === ELIMINAR INGRESO ===
  Future<String?> eliminarIngreso(String ingresoId) async {
    try {
      if (userId == null) return 'Usuario no autenticado';

      await firestore.runTransaction((transaction) async {
        // === FASE DE LECTURAS ===
        final ingresoRef = ingresosRef().doc(ingresoId);
        final ingresoDoc = await transaction.get(ingresoRef);

        if (!ingresoDoc.exists) throw Exception('El ingreso no existe');

        final ingresoData = ingresoDoc.data()!;
        final monto = (ingresoData['monto'] as num).toDouble();
        final cuentaAsociada = ingresoData['cuentaAsociada'] as String?;

        DocumentSnapshot<Map<String, dynamic>>? cuentaDoc;
        if (cuentaAsociada != null && cuentaAsociada.isNotEmpty && cuentaAsociada != 'ninguna') {
          final cuentaRef = firestore
              .collection('usuarios')
              .doc(userId)
              .collection('cuentas')
              .doc(cuentaAsociada);
          cuentaDoc = await transaction.get(cuentaRef);
        }

        // === FASE DE ESCRITURAS ===
        if (cuentaDoc != null && cuentaDoc.exists) {
          final cuentaData = cuentaDoc.data()!;
          final saldoActual = (cuentaData['saldo'] as num?)?.toDouble() ?? 0.0;
          final nuevoSaldo = saldoActual - monto;

          transaction.update(cuentaDoc.reference, {
            'saldo': nuevoSaldo,
            'ultimaActualizacion': FieldValue.serverTimestamp(),
          });

          final movimientoRef = cuentaDoc.reference.collection('movimientos').doc();
          transaction.set(movimientoRef, {
            'tipo': 'reversa_ingreso',
            'monto': -monto,
            'descripcion': 'Reversión de ingreso eliminado',
            'ingresoId': ingresoId,
            'fecha': FieldValue.serverTimestamp(),
            'fechaCreacion': FieldValue.serverTimestamp(),
          });
        }

        transaction.delete(ingresoRef);
      });

      return null;
    } catch (e) {
      return 'Error al eliminar el ingreso: ${e.toString()}';
    }
  }
}