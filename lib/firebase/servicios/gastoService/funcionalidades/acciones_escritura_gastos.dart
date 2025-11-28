// 4. Lógica compleja: Crear, Editar y Eliminar
// Este archivo maneja las transacciones que afectan gastos y saldos de cuentas.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_gastos.dart';
import 'acciones_lectura_gastos.dart'; // Import necesario para usar validaciones

// Nota: "on ReferenciasGastos, AccionesLecturaGastos" permite usar métodos de ambos
mixin AccionesEscrituraGastos on ReferenciasGastos, AccionesLecturaGastos {
  
  /// === CREAR NUEVO GASTO ===
  Future<String?> crearGasto({
    required String descripcion,
    required double monto,
    required DateTime fecha,
    required String categoria,
    required String metodoPago,
    String? cuentaAsociada,
    bool esRecurrente = false,
    String? frecuencia,
    String? notas,
  }) async {
    try {
      print('🔍 GastosServicio - Iniciando creación de gasto');
      
      if (userId == null) {
        print('❌ Usuario no autenticado');
        return 'Usuario no autenticado';
      }
      
      print('✅ Usuario autenticado: $userId');
      
      // Validaciones básicas
      if (descripcion.trim().isEmpty) return 'La descripción es requerida';
      if (monto <= 0) return 'El monto debe ser mayor a 0';
      if (categoria.trim().isEmpty) return 'La categoría es requerida';
      if (metodoPago.trim().isEmpty) return 'El método de pago es requerido';
      
      print('✅ Validaciones básicas completadas');
      
      // Verificar cuenta asociada
      if (cuentaAsociada != null && cuentaAsociada != 'ninguna' && cuentaAsociada.isNotEmpty) {
        print('🔍 Verificando cuenta asociada: $cuentaAsociada');
        
        // Llamada a método del mixin de lectura
        final cuentaExiste = await verificarCuentaExiste(cuentaAsociada);
        if (!cuentaExiste) {
          print('❌ La cuenta asociada no existe');
          return 'La cuenta asociada no existe';
        }
        
        print('✅ Cuenta existe, verificando saldo');
        
        // Llamada a método del mixin de lectura
        final saldoSuficiente = await verificarSaldoSuficiente(cuentaAsociada, monto);
        if (!saldoSuficiente) {
          print('❌ Saldo insuficiente en la cuenta');
          return 'Saldo insuficiente en la cuenta';
        }
        
        print('✅ Saldo suficiente');
      } else {
        print('ℹ️ No se especificó cuenta asociada o es "ninguna"');
      }
      
      print('🔍 Iniciando transacción para crear gasto');
      
      await firestore.runTransaction((transaction) async {
        print('🔍 Dentro de la transacción');
        
        // LECTURAS
        DocumentSnapshot? cuentaDoc;
        final cuentaRef = cuentaAsociada != null && cuentaAsociada != 'ninguna' && cuentaAsociada.isNotEmpty
            ? firestore.collection('usuarios').doc(userId).collection('cuentas').doc(cuentaAsociada)
            : null;
        
        if (cuentaRef != null) {
          print('🔍 Leyendo datos de cuenta antes de escribir');
          cuentaDoc = await transaction.get(cuentaRef);
        }
        
        // ESCRITURAS
        final gastoRef = gastosRef().doc();
        
        final gastoData = {
          'descripcion': descripcion.trim(),
          'monto': monto,
          'fecha': Timestamp.fromDate(fecha),
          'categoria': categoria.trim(),
          'metodoPago': metodoPago.trim(),
          'cuentaAsociada': cuentaAsociada,
          'esRecurrente': esRecurrente,
          'frecuencia': frecuencia?.trim(),
          'notas': notas?.trim(),
          'usuarioId': userId,
          'fechaCreacion': FieldValue.serverTimestamp(),
          'fechaModificacion': FieldValue.serverTimestamp(),
          'activo': true,
        };
        
        print('🔍 Datos del gasto a guardar: $gastoData');
        
        transaction.set(gastoRef, gastoData);
        print('✅ Gasto creado en Firestore');
        
        // Actualizar saldo si aplica
        if (cuentaRef != null && cuentaDoc != null && cuentaDoc.exists) {
          print('🔍 Actualizando saldo de cuenta: $cuentaAsociada');
          
          final cuentaData = cuentaDoc.data()! as Map<String, dynamic>;
          final saldoActual = (cuentaData['saldo'] as num).toDouble();
          final nuevoSaldo = saldoActual - monto;
          
          print('🔍 Saldo actual: $saldoActual, Nuevo saldo: $nuevoSaldo');
          
          transaction.update(cuentaRef, {
            'saldo': nuevoSaldo,
            'fechaModificacion': FieldValue.serverTimestamp(),
          });
          
          print('✅ Saldo actualizado');
          
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
          
          print('✅ Movimiento registrado');
        } else if (cuentaRef != null) {
          print('❌ La cuenta no existe al intentar actualizar saldo');
        }
      });
      
      print('✅ Transacción completada exitosamente');
      return null;
      
    } catch (e) {
      print('❌ Error en crearGasto: $e');
      return 'Error al crear gasto: $e';
    }
  }

  /// === ACTUALIZAR GASTO ===
  Future<String?> actualizarGasto({
    required String gastoId,
    required String descripcion,
    required double monto,
    required DateTime fecha,
    required String categoria,
    required String metodoPago,
    String? cuentaAsociada,
    bool esRecurrente = false,
    String? frecuencia,
    String? notas,
  }) async {
    try {
      if (userId == null) return 'Usuario no autenticado';
      
      if (gastoId.trim().isEmpty) return 'ID del gasto requerido';
      if (descripcion.trim().isEmpty) return 'La descripción es requerida';
      if (monto <= 0) return 'El monto debe ser mayor a 0';
      if (categoria.trim().isEmpty) return 'La categoría es requerida';
      if (metodoPago.trim().isEmpty) return 'El método de pago es requerido';
      
      // Verificar existencia previa (lectura fuera de transacción para fail-fast)
      final gastoDoc = await gastosRef().doc(gastoId).get();
      if (!gastoDoc.exists) return 'El gasto no existe';
      
      final gastoRef = gastosRef().doc(gastoId);
      print('🔍 Iniciando transacción para actualizar gasto: $gastoId');

      await firestore.runTransaction((transaction) async {
        print('🔍 Dentro de la transacción (actualizarGasto) - leyendo gasto');
        final gastoSnap = await transaction.get(gastoRef);
        if (!gastoSnap.exists) throw Exception('El gasto no existe');

        final oldData = gastoSnap.data() as Map<String, dynamic>;
        final oldMonto = (oldData['monto'] as num?)?.toDouble() ?? 0.0;
        final oldCuenta = (oldData['cuentaAsociada'] as String?);

        print('🔍 Gasto previo: monto=$oldMonto, cuenta=$oldCuenta');

        // Normalizar valores
        String? normalizedOldCuenta = (oldCuenta == null || oldCuenta == 'ninguna' || oldCuenta.isEmpty) ? null : oldCuenta;
        String? normalizedNewCuenta = (cuentaAsociada == null || cuentaAsociada == 'ninguna' || cuentaAsociada.isEmpty) ? null : cuentaAsociada;

        // LECTURAS DE CUENTAS
        DocumentSnapshot? cuentaOldSnap;
        DocumentSnapshot? cuentaNewSnap;

        if (normalizedOldCuenta != null) {
          final oldCuentaRef = firestore.collection('usuarios').doc(userId).collection('cuentas').doc(normalizedOldCuenta);
          cuentaOldSnap = await transaction.get(oldCuentaRef);
        }

        if (normalizedNewCuenta != null && normalizedNewCuenta != normalizedOldCuenta) {
          final newCuentaRef = firestore.collection('usuarios').doc(userId).collection('cuentas').doc(normalizedNewCuenta);
          cuentaNewSnap = await transaction.get(newCuentaRef);
        } else if (normalizedNewCuenta != null && normalizedNewCuenta == normalizedOldCuenta) {
          cuentaNewSnap = cuentaOldSnap;
        }

        // ESCRITURAS
        print('🔍 Actualizando documento del gasto $gastoId');
        transaction.update(gastoRef, {
          'descripcion': descripcion.trim(),
          'monto': monto,
          'fecha': Timestamp.fromDate(fecha),
          'categoria': categoria.trim(),
          'metodoPago': metodoPago.trim(),
          'cuentaAsociada': cuentaAsociada,
          'esRecurrente': esRecurrente,
          'frecuencia': frecuencia?.trim(),
          'notas': notas?.trim(),
          'fechaModificacion': FieldValue.serverTimestamp(),
        });

        // LÓGICA DE SALDOS
        // 1. Misma cuenta: ajustar diferencia
        if (normalizedOldCuenta != null && normalizedOldCuenta == normalizedNewCuenta) {
          final cuentaRef = firestore.collection('usuarios').doc(userId).collection('cuentas').doc(normalizedOldCuenta);
          if (cuentaOldSnap != null && cuentaOldSnap.exists) {
            final dataOld = cuentaOldSnap.data() as Map<String, dynamic>;
            final saldoActual = (dataOld['saldo'] as num).toDouble();
            final delta = monto - oldMonto;
            final nuevoSaldo = saldoActual - delta;
            
            transaction.update(cuentaRef, {
              'saldo': nuevoSaldo,
              'fechaModificacion': FieldValue.serverTimestamp(),
            });

            if (delta != 0) {
              final movRef = cuentaRef.collection('movimientos').doc();
              transaction.set(movRef, {
                'tipo': 'ajuste_gasto',
                'monto': -delta,
                'descripcion': 'Ajuste de gasto: $gastoId',
                'gastoId': gastoId,
                'fecha': FieldValue.serverTimestamp(),
                'fechaCreacion': FieldValue.serverTimestamp(),
              });
            }
          }
        } else {
          // 2. Cuentas distintas: Revertir anterior y Cobrar nueva
          
          // Revertir anterior (Devolver dinero)
          if (normalizedOldCuenta != null) {
            final oldCuentaRef = firestore.collection('usuarios').doc(userId).collection('cuentas').doc(normalizedOldCuenta);
            if (cuentaOldSnap != null && cuentaOldSnap.exists) {
              final dataOld2 = cuentaOldSnap.data() as Map<String, dynamic>;
              final saldoOld = (dataOld2['saldo'] as num).toDouble();
              final nuevoSaldoOld = saldoOld + oldMonto;
              
              transaction.update(oldCuentaRef, {
                'saldo': nuevoSaldoOld,
                'fechaModificacion': FieldValue.serverTimestamp(),
              });

              final movOldRef = oldCuentaRef.collection('movimientos').doc();
              transaction.set(movOldRef, {
                'tipo': 'reversa_gasto_actualizacion',
                'monto': oldMonto,
                'descripcion': 'Reversión por edición de gasto: $gastoId',
                'gastoId': gastoId,
                'fecha': FieldValue.serverTimestamp(),
                'fechaCreacion': FieldValue.serverTimestamp(),
              });
            }
          }

          // Cobrar nueva (Restar dinero)
          if (normalizedNewCuenta != null) {
            final newCuentaRef = firestore.collection('usuarios').doc(userId).collection('cuentas').doc(normalizedNewCuenta);
            if (cuentaNewSnap != null && cuentaNewSnap.exists) {
              final dataNew = cuentaNewSnap.data() as Map<String, dynamic>;
              final saldoNew = (dataNew['saldo'] as num).toDouble();
              final nuevoSaldoNew = saldoNew - monto;
              
              transaction.update(newCuentaRef, {
                'saldo': nuevoSaldoNew,
                'fechaModificacion': FieldValue.serverTimestamp(),
              });

              final movNewRef = newCuentaRef.collection('movimientos').doc();
              transaction.set(movNewRef, {
                'tipo': 'gasto',
                'monto': -monto,
                'descripcion': 'Gasto editado: $descripcion',
                'categoria': categoria,
                'fecha': Timestamp.fromDate(fecha),
                'gastoId': gastoId,
                'fechaCreacion': FieldValue.serverTimestamp(),
              });
            }
          }
        }
      });

      return null;
      
    } catch (e, st) {
      print('❌ Error al actualizar gasto: $e');
      print('--- StackTrace ---');
      print(st);
      final mensaje = e is FirebaseException ? (e.message ?? e.toString()) : e.toString();
      return 'Error al actualizar gasto: $mensaje';
    }
  }

  /// === ELIMINAR GASTO ===
  Future<String?> eliminarGasto(String gastoId) async {
    try {
      print('🗑️ Iniciando eliminación de gasto: $gastoId');
      
      if (userId == null) {
        print('❌ Usuario no autenticado');
        return 'Usuario no autenticado';
      }
      if (gastoId.trim().isEmpty) return 'ID del gasto requerido';
      
      // Lectura previa para fail-fast
      final gastoDoc = await gastosRef().doc(gastoId).get();
      if (!gastoDoc.exists) {
        print('❌ El gasto no existe en la base de datos');
        return 'El gasto no existe';
      }
      
      final gastoData = gastoDoc.data()!;
      final monto = (gastoData['monto'] as num).toDouble();
      final cuentaAsociada = gastoData['cuentaAsociada'] as String?;
      
      print('🔍 Gasto encontrado: monto: $monto, cuenta: $cuentaAsociada');
      
      await firestore.runTransaction((transaction) async {
        // LECTURAS
        DocumentSnapshot? cuentaDoc;
        final cuentaRef = cuentaAsociada != null && cuentaAsociada != 'ninguna' && cuentaAsociada.isNotEmpty
            ? firestore.collection('usuarios').doc(userId).collection('cuentas').doc(cuentaAsociada)
            : null;
        
        if (cuentaRef != null) {
          print('🔍 Leyendo cuenta asociada para devolver el dinero');
          cuentaDoc = await transaction.get(cuentaRef);
        }
        
        // ESCRITURAS
        print('🔍 Eliminando gasto completamente de la base de datos');
        transaction.delete(gastosRef().doc(gastoId));
        print('✅ Gasto eliminado de la base de datos');
        
        if (cuentaRef != null && cuentaDoc != null && cuentaDoc.exists) {
          print('🔍 Devolviendo dinero a la cuenta');
          final cuentaData = cuentaDoc.data()! as Map<String, dynamic>;
          final saldoActual = (cuentaData['saldo'] as num).toDouble();
          final nuevoSaldo = saldoActual + monto;
          
          print('🔍 Saldo actual: $saldoActual, Nuevo saldo: $nuevoSaldo');
          
          transaction.update(cuentaRef, {
            'saldo': nuevoSaldo,
            'fechaModificacion': FieldValue.serverTimestamp(),
          });
          
          print('✅ Saldo actualizado');
          
          final movimientoRef = cuentaRef.collection('movimientos').doc();
          transaction.set(movimientoRef, {
            'tipo': 'reversa_gasto',
            'monto': monto,
            'descripcion': 'Reversión de gasto eliminado',
            'gastoId': gastoId,
            'fecha': FieldValue.serverTimestamp(),
            'fechaCreacion': FieldValue.serverTimestamp(),
          });
          
          print('✅ Movimiento de reversión registrado');
        }
      });
      
      print('✅ Gasto eliminado correctamente');
      return null;
      
    } catch (e) {
      print('❌ Error al eliminar gasto: $e');
      return 'Error al eliminar gasto: $e';
    }
  }
}