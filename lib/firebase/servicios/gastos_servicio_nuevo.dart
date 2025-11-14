import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para gestionar gastos en Firebase
/// 
/// Este servicio maneja todas las operaciones CRUD de gastos:
/// - Crear nuevos gastos
/// - Obtener lista de gastos del usuario
/// - Validar saldos y actualizar cuentas asociadas
/// - Eliminar gastos y revertir cambios en cuentas
/// - Generar estadísticas de gastos
/// 
/// Estructura de datos en Firestore:
/// usuarios/{uid}/gastos/{gastoId}
class GastosServicio {
  // === INSTANCIAS DE FIREBASE ===
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // === CONSTANTES ===
  static const String _coleccionGastos = 'gastos';

  /// Obtiene el ID del usuario autenticado actual
  String? get _userId => _auth.currentUser?.uid;

  /// Referencia a la subcolección de gastos del usuario
  /// Estructura: usuarios/{uid}/gastos
  CollectionReference<Map<String, dynamic>> _gastosRef() {
    if (_userId == null) {
      return _firestore.collection('usuarios/__no_user__/$_coleccionGastos');
    }
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection(_coleccionGastos);
  }

  /// === REGISTRAR NUEVO GASTO ===
  /// 
  /// Registra un nuevo gasto y actualiza el saldo de la cuenta asociada si existe
  /// 
  /// [monto] - Cantidad del gasto (debe ser mayor a 0)
  /// [fecha] - Fecha del gasto
  /// [descripcion] - Descripción del gasto
  /// [categoria] - Categoría del gasto (alimentación, transporte, etc.)
  /// [metodoPago] - Método de pago (efectivo, transferencia)
  /// [cuentaAsociada] - ID de la cuenta de la cual se debitará el dinero (opcional)
  /// [esRecurrente] - Indica si es un gasto recurrente
  /// [frecuencia] - Frecuencia del gasto recurrente (mensual, semanal, etc.)
  /// 
  /// Retorna null si es exitoso, o un mensaje de error si falla
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
      // Validar autenticación
      if (_userId == null) {
        return 'Usuario no autenticado';
      }

      // Validaciones básicas
      if (monto <= 0) {
        return 'El monto debe ser mayor a 0';
      }

      if (descripcion.trim().isEmpty) {
        return 'La descripción es requerida';
      }

      // Validar cuenta asociada si se especifica
      if (cuentaAsociada != null && cuentaAsociada.isNotEmpty) {
        final cuentaExiste = await _verificarCuentaExiste(cuentaAsociada);
        if (!cuentaExiste) {
          return 'La cuenta asociada no existe';
        }

        // Verificar saldo suficiente
        final saldoSuficiente = await _verificarSaldoSuficiente(cuentaAsociada, monto);
        if (!saldoSuficiente) {
          return 'Saldo insuficiente en la cuenta seleccionada';
        }
      }

      // Usar transacción para garantizar consistencia de datos
      await _firestore.runTransaction((transaction) async {
        // 1. Crear el documento del gasto
        final gastoRef = _gastosRef().doc();

        final gastoData = {
          'monto': monto,
          'fecha': Timestamp.fromDate(fecha),
          'descripcion': descripcion.trim(),
          'categoria': categoria,
          'metodoPago': metodoPago,
          'cuentaAsociada': cuentaAsociada,
          'esRecurrente': esRecurrente,
          'frecuencia': frecuencia,
          'fechaCreacion': FieldValue.serverTimestamp(),
          'activo': true, // Para permitir soft deletes
        };

        transaction.set(gastoRef, gastoData);

        // 2. Si hay cuenta asociada, descontar el monto del saldo
        if (cuentaAsociada != null && cuentaAsociada.isNotEmpty) {
          final cuentaRef = _firestore
              .collection('usuarios')
              .doc(_userId)
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

      return null; // Éxito
    } catch (e) {
      print('Error al registrar gasto: $e');
      return 'Error al registrar el gasto: ${e.toString()}';
    }
  }

  /// === OBTENER GASTOS DEL USUARIO ===
  /// 
  /// Retorna un Stream con todos los gastos del usuario ordenados por fecha
  /// Los datos incluyen el ID del documento para operaciones futuras
  Stream<List<Map<String, dynamic>>> obtenerGastos() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _gastosRef()
        .where('activo', isEqualTo: true)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Convertir Timestamp a DateTime para facilitar el uso
        if (data['fecha'] is Timestamp) {
          data['fecha'] = (data['fecha'] as Timestamp).toDate();
        }
        
        return data;
      }).toList();
    });
  }

  /// === ELIMINAR GASTO ===
  /// 
  /// Elimina un gasto y revierte el cambio en la cuenta asociada si existe
  /// 
  /// [gastoId] - ID del gasto a eliminar
  /// 
  /// Retorna null si es exitoso, o un mensaje de error si falla
  Future<String?> eliminarGasto(String gastoId) async {
    try {
      if (_userId == null) {
        return 'Usuario no autenticado';
      }

      await _firestore.runTransaction((transaction) async {
        // 1. Obtener el gasto a eliminar
        final gastoRef = _gastosRef().doc(gastoId);
        final gastoDoc = await transaction.get(gastoRef);

        if (!gastoDoc.exists) {
          throw Exception('El gasto no existe');
        }

        final gastoData = gastoDoc.data()!;
        final monto = (gastoData['monto'] as num).toDouble();
        final cuentaAsociada = gastoData['cuentaAsociada'] as String?;

        // 2. Si había cuenta asociada, devolver el monto al saldo
        if (cuentaAsociada != null && cuentaAsociada.isNotEmpty) {
          final cuentaRef = _firestore
              .collection('usuarios')
              .doc(_userId)
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

        // 3. Marcar el gasto como inactivo (soft delete)
        transaction.update(gastoRef, {
          'activo': false,
          'fechaEliminacion': FieldValue.serverTimestamp(),
        });
      });

      return null; // Éxito
    } catch (e) {
      print('Error al eliminar gasto: $e');
      return 'Error al eliminar el gasto: ${e.toString()}';
    }
  }

  /// === OBTENER ESTADÍSTICAS DE GASTOS ===
  /// 
  /// Calcula estadísticas básicas de gastos por período
  Future<Map<String, dynamic>> obtenerEstadisticas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      if (_userId == null) {
        return {'error': 'Usuario no autenticado'};
      }

      // Definir fechas por defecto (último mes)
      fechaFin ??= DateTime.now();
      fechaInicio ??= DateTime(fechaFin.year, fechaFin.month - 1, fechaFin.day);

      final query = _gastosRef()
          .where('activo', isEqualTo: true)
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin));

      final snapshot = await query.get();

      double totalGastos = 0;
      Map<String, double> gastosPorCategoria = {};
      Map<String, double> gastosPorMetodo = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final monto = (data['monto'] as num).toDouble();
        final categoria = data['categoria'] as String;
        final metodoPago = data['metodoPago'] as String;

        totalGastos += monto;
        
        gastosPorCategoria[categoria] = 
            (gastosPorCategoria[categoria] ?? 0) + monto;
            
        gastosPorMetodo[metodoPago] = 
            (gastosPorMetodo[metodoPago] ?? 0) + monto;
      }

      return {
        'totalGastos': totalGastos,
        'cantidadGastos': snapshot.docs.length,
        'gastosPorCategoria': gastosPorCategoria,
        'gastosPorMetodo': gastosPorMetodo,
        'promedioGasto': snapshot.docs.isNotEmpty ? totalGastos / snapshot.docs.length : 0,
      };

    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {'error': e.toString()};
    }
  }

  /// === MÉTODOS AUXILIARES PRIVADOS ===

  /// Verifica si una cuenta existe y está activa
  Future<bool> _verificarCuentaExiste(String cuentaId) async {
    try {
      if (_userId == null) return false;

      final doc = await _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('cuentas')
          .doc(cuentaId)
          .get();

      return doc.exists && (doc.data()?['activa'] ?? false);
    } catch (e) {
      print('Error al verificar cuenta: $e');
      return false;
    }
  }

  /// Verifica si una cuenta tiene saldo suficiente para un gasto
  Future<bool> _verificarSaldoSuficiente(String cuentaId, double monto) async {
    try {
      if (_userId == null) return false;

      final doc = await _firestore
          .collection('usuarios')
          .doc(_userId)
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
}
