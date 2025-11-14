import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para gestionar ingresos en Firebase
/// 
/// Este servicio maneja todas las operaciones CRUD de ingresos:
/// - Crear nuevos ingresos
/// - Obtener lista de ingresos del usuario
/// - Actualizar saldos de cuentas asociadas
/// - Eliminar ingresos y revertir cambios en cuentas
/// 
/// Estructura de datos en Firestore:
/// usuarios/{uid}/ingresos/{ingresoId}
class IngresosServicio {
  // === INSTANCIAS DE FIREBASE ===
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // === CONSTANTES ===
  static const String _coleccionIngresos = 'ingresos';

  /// Obtiene el ID del usuario autenticado actual
  String? get _userId => _auth.currentUser?.uid;

  /// Referencia a la subcolección de ingresos del usuario
  /// Estructura: usuarios/{uid}/ingresos
  CollectionReference<Map<String, dynamic>> _ingresosRef() {
    if (_userId == null) {
      return _firestore.collection('usuarios/__no_user__/$_coleccionIngresos');
    }
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection(_coleccionIngresos);
  }

  /// === CREAR NUEVO INGRESO ===
  /// 
  /// Registra un nuevo ingreso y actualiza el saldo de la cuenta asociada si existe
  /// 
  /// [monto] - Cantidad del ingreso (debe ser mayor a 0)
  /// [fecha] - Fecha del ingreso
  /// [descripcion] - Descripción del ingreso
  /// [categoria] - Categoría del ingreso (trabajo, negocio, regalo, etc.)
  /// [metodoPago] - Método de pago (efectivo, transferencia)
  /// [cuentaAsociada] - ID de la cuenta donde se depositará el dinero (opcional)
  /// 
  /// Retorna null si es exitoso, o un mensaje de error si falla
  Future<String?> registrarIngreso({
    required double monto,
    required DateTime fecha,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    String? cuentaAsociada,
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
      }

      // Usar transacción para garantizar consistencia de datos
      await _firestore.runTransaction((transaction) async {
        // 1. Crear el documento del ingreso
        final ingresoRef = _ingresosRef().doc();

        final ingresoData = {
          'monto': monto,
          'fecha': Timestamp.fromDate(fecha),
          'descripcion': descripcion.trim(),
          'categoria': categoria,
          'metodoPago': metodoPago,
          'cuentaAsociada': cuentaAsociada,
          'fechaCreacion': FieldValue.serverTimestamp(),
          'activo': true, // Para permitir filtros futuros
        };

        transaction.set(ingresoRef, ingresoData);

        // 2. Si hay cuenta asociada, sumar el monto al saldo
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
            final nuevoSaldo = saldoActual + monto;

            // Actualizar el saldo de la cuenta
            transaction.update(cuentaRef, {
              'saldo': nuevoSaldo,
              'ultimaActualizacion': FieldValue.serverTimestamp(),
            });

            // Registrar el movimiento en el historial de la cuenta
            final movimientoRef = cuentaRef.collection('movimientos').doc();
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
        }
      });

      return null; // Éxito
    } catch (e) {
      print('Error al registrar ingreso: $e');
      return 'Error al registrar el ingreso: ${e.toString()}';
    }
  }

  /// === OBTENER INGRESOS DEL USUARIO ===
  /// 
  /// Retorna un Stream con todos los ingresos del usuario ordenados por fecha
  /// Los datos incluyen el ID del documento para operaciones futuras
  Stream<List<Map<String, dynamic>>> obtenerIngresos() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _ingresosRef()
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

  /// === ELIMINAR INGRESO ===
  /// 
  /// Elimina un ingreso y revierte los cambios en la cuenta asociada
  /// 
  /// [ingresoId] - ID del ingreso a eliminar
  /// 
  /// Retorna null si es exitoso, o un mensaje de error si falla
  Future<String?> eliminarIngreso(String ingresoId) async {
    try {
      if (_userId == null) {
        return 'Usuario no autenticado';
      }

      await _firestore.runTransaction((transaction) async {
        // 1. Obtener el ingreso a eliminar
        final ingresoRef = _ingresosRef().doc(ingresoId);
        final ingresoDoc = await transaction.get(ingresoRef);

        if (!ingresoDoc.exists) {
          throw Exception('El ingreso no existe');
        }

        final ingresoData = ingresoDoc.data()!;
        final monto = (ingresoData['monto'] as num).toDouble();
        final cuentaAsociada = ingresoData['cuentaAsociada'] as String?;

        // 2. Si había cuenta asociada, restar el monto del saldo
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
            final nuevoSaldo = saldoActual - monto;

            // Actualizar el saldo
            transaction.update(cuentaRef, {
              'saldo': nuevoSaldo,
              'ultimaActualizacion': FieldValue.serverTimestamp(),
            });

            // Registrar el movimiento de reversión
            final movimientoRef = cuentaRef.collection('movimientos').doc();
            transaction.set(movimientoRef, {
              'tipo': 'reversa_ingreso',
              'monto': -monto,
              'descripcion': 'Reversión de ingreso eliminado',
              'ingresoId': ingresoId,
              'fecha': FieldValue.serverTimestamp(),
              'fechaCreacion': FieldValue.serverTimestamp(),
            });
          }
        }

        // 3. Marcar el ingreso como inactivo (soft delete)
        transaction.update(ingresoRef, {
          'activo': false,
          'fechaEliminacion': FieldValue.serverTimestamp(),
        });
      });

      return null; // Éxito
    } catch (e) {
      print('Error al eliminar ingreso: $e');
      return 'Error al eliminar el ingreso: ${e.toString()}';
    }
  }

  /// === OBTENER ESTADÍSTICAS DE INGRESOS ===
  /// 
  /// Calcula estadísticas básicas de ingresos por período
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

      final query = _ingresosRef()
          .where('activo', isEqualTo: true)
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin));

      final snapshot = await query.get();

      double totalIngresos = 0;
      Map<String, double> ingresosPorCategoria = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final monto = (data['monto'] as num).toDouble();
        final categoria = data['categoria'] as String;

        totalIngresos += monto;
        ingresosPorCategoria[categoria] = 
            (ingresosPorCategoria[categoria] ?? 0) + monto;
      }

      return {
        'totalIngresos': totalIngresos,
        'cantidadIngresos': snapshot.docs.length,
        'ingresosPorCategoria': ingresosPorCategoria,
        'promedioIngreso': snapshot.docs.isNotEmpty ? totalIngresos / snapshot.docs.length : 0,
      };

    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {'error': e.toString()};
    }
  }

  /// === MÉTODOS AUXILIARES ===

  /// Verifica si una cuenta existe en la base de datos
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
}
