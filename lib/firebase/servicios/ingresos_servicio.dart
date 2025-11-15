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

      // Usar transacción para garantizar consistencia de datos
      // IMPORTANTE: Todas las lecturas deben ir ANTES que las escrituras
      await _firestore.runTransaction((transaction) async {
        
        // === FASE DE LECTURAS (primero) ===
        DocumentSnapshot<Map<String, dynamic>>? cuentaDoc;
        
        // Si hay cuenta asociada, leer su información primero
        if (cuentaAsociada != null && cuentaAsociada.isNotEmpty && cuentaAsociada != 'ninguna') {
          final cuentaRef = _firestore
              .collection('usuarios')
              .doc(_userId)
              .collection('cuentas')
              .doc(cuentaAsociada);
          
          cuentaDoc = await transaction.get(cuentaRef);
          
          // Validar que la cuenta existe
          if (!cuentaDoc.exists) {
            throw Exception('La cuenta asociada no existe');
          }
        }
        
        // === FASE DE ESCRITURAS (después de todas las lecturas) ===
        
        // 1. Crear el documento del ingreso
        final ingresoRef = _ingresosRef().doc();
        
        final ingresoData = {
          'monto': monto,
          'fecha': Timestamp.fromDate(fecha),
          'descripcion': descripcion.trim(),
          'categoria': categoria,
          'metodoPago': metodoPago,
          'cuentaAsociada': cuentaAsociada != 'ninguna' ? cuentaAsociada : null,
          'fechaCreacion': FieldValue.serverTimestamp(),
          'activo': true,
        };

        transaction.set(ingresoRef, ingresoData);

        // 2. Si hay cuenta asociada válida, actualizar su saldo
        if (cuentaDoc != null && cuentaDoc.exists) {
          final cuentaData = cuentaDoc.data()!;
          final saldoActual = (cuentaData['saldo'] as num?)?.toDouble() ?? 0.0;
          final nuevoSaldo = saldoActual + monto;

          // Actualizar el saldo de la cuenta
          transaction.update(cuentaDoc.reference, {
            'saldo': nuevoSaldo,
            'ultimaActualizacion': FieldValue.serverTimestamp(),
          });

          // Registrar el movimiento en el historial de la cuenta
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

      return null; // Éxito
    } catch (e) {
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

    try {
      // Consulta simple sin índices compuestos - Apta para producción
      return _ingresosRef().snapshots().map((snapshot) {
        final ingresos = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;

          // Convertir Timestamp a DateTime
          if (data['fecha'] is Timestamp) {
            data['fecha'] = (data['fecha'] as Timestamp).toDate();
          }

          return data;
        })
        .where((ingreso) {
          // Filtrar ingresos activos en el cliente
          return ingreso['activo'] == true;
        })
        .toList();
        
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
  /// Útil para operaciones de edición o visualización de detalles
  Future<Map<String, dynamic>?> obtenerIngresoPorId(String ingresoId) async {
    try {
      if (_userId == null) return null;

      final doc = await _ingresosRef().doc(ingresoId).get();
      
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

  /// === ACTUALIZAR INGRESO ===
  /// 
  /// Actualiza un ingreso existente y maneja cambios en cuentas asociadas
  /// 
  /// [ingresoId] - ID del ingreso a actualizar
  /// [monto] - Nuevo monto del ingreso
  /// [fecha] - Nueva fecha del ingreso
  /// [descripcion] - Nueva descripción
  /// [categoria] - Nueva categoría
  /// [metodoPago] - Nuevo método de pago
  /// [cuentaAsociada] - Nueva cuenta asociada (puede ser diferente a la anterior)
  /// 
  /// Retorna null si es exitoso, o un mensaje de error si falla
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

      // Usar transacción para garantizar consistencia
      // IMPORTANTE: Todas las lecturas primero, luego las escrituras
      await _firestore.runTransaction((transaction) async {
        
        // === FASE DE LECTURAS (todas las lecturas primero) ===
        
        // 1. Obtener el ingreso actual
        final ingresoRef = _ingresosRef().doc(ingresoId);
        final ingresoDoc = await transaction.get(ingresoRef);

        if (!ingresoDoc.exists) {
          throw Exception('El ingreso no existe');
        }

        final datosActuales = ingresoDoc.data()!;
        final montoAnterior = (datosActuales['monto'] as num).toDouble();
        final cuentaAnterior = datosActuales['cuentaAsociada'] as String?;

        // 2. Leer cuenta anterior si existe
        DocumentSnapshot<Map<String, dynamic>>? cuentaAntDoc;
        if (cuentaAnterior != null && cuentaAnterior.isNotEmpty && cuentaAnterior != 'ninguna') {
          final cuentaAntRef = _firestore
              .collection('usuarios')
              .doc(_userId)
              .collection('cuentas')
              .doc(cuentaAnterior);
          cuentaAntDoc = await transaction.get(cuentaAntRef);
        }

        // 3. Leer nueva cuenta si existe y es diferente a la anterior
        DocumentSnapshot<Map<String, dynamic>>? cuentaNuevaDoc;
        if (cuentaAsociada != null && cuentaAsociada.isNotEmpty && cuentaAsociada != 'ninguna') {
          final cuentaNuevaRef = _firestore
              .collection('usuarios')
              .doc(_userId)
              .collection('cuentas')
              .doc(cuentaAsociada);
          
          // Solo leer si es diferente a la cuenta anterior
          if (cuentaAsociada != cuentaAnterior) {
            cuentaNuevaDoc = await transaction.get(cuentaNuevaRef);
          } else {
            cuentaNuevaDoc = cuentaAntDoc; // Usar la misma referencia
          }
          
          // Validar que la nueva cuenta existe
          if (cuentaNuevaDoc != null && !cuentaNuevaDoc.exists) {
            throw Exception('La cuenta asociada no existe');
          }
        }
        
        // === FASE DE ESCRITURAS (después de todas las lecturas) ===

        // 4. Actualizar los datos del ingreso
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

        // 5. Manejar cambios en cuentas asociadas
        // Si la cuenta cambió, restar de la anterior y sumar a la nueva
        if (cuentaAnterior != cuentaAsociada) {
          // Restar de cuenta anterior
          if (cuentaAntDoc != null && cuentaAntDoc.exists) {
            final saldoAnterior = (cuentaAntDoc.data()!['saldo'] as num?)?.toDouble() ?? 0.0;
            transaction.update(cuentaAntDoc.reference, {
              'saldo': saldoAnterior - montoAnterior,
              'ultimaActualizacion': FieldValue.serverTimestamp(),
            });
          }

          // Sumar a cuenta nueva
          if (cuentaNuevaDoc != null && cuentaNuevaDoc.exists) {
            final saldoNuevo = (cuentaNuevaDoc.data()!['saldo'] as num?)?.toDouble() ?? 0.0;
            transaction.update(cuentaNuevaDoc.reference, {
              'saldo': saldoNuevo + monto,
              'ultimaActualizacion': FieldValue.serverTimestamp(),
            });

            // Registrar movimiento en la nueva cuenta
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
          // Misma cuenta, solo actualizar la diferencia de monto
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

      return null; // Éxito
    } catch (e) {
      return 'Error al actualizar el ingreso: ${e.toString()}';
    }
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

      // Usar transacción con lecturas antes de escrituras
      await _firestore.runTransaction((transaction) async {
        
        // === FASE DE LECTURAS ===
        
        // 1. Obtener el ingreso a eliminar
        final ingresoRef = _ingresosRef().doc(ingresoId);
        final ingresoDoc = await transaction.get(ingresoRef);

        if (!ingresoDoc.exists) {
          throw Exception('El ingreso no existe');
        }

        final ingresoData = ingresoDoc.data()!;
        final monto = (ingresoData['monto'] as num).toDouble();
        final cuentaAsociada = ingresoData['cuentaAsociada'] as String?;

        // 2. Leer cuenta asociada si existe
        DocumentSnapshot<Map<String, dynamic>>? cuentaDoc;
        if (cuentaAsociada != null && cuentaAsociada.isNotEmpty) {
          final cuentaRef = _firestore
              .collection('usuarios')
              .doc(_userId)
              .collection('cuentas')
              .doc(cuentaAsociada);
          cuentaDoc = await transaction.get(cuentaRef);
        }

        // === FASE DE ESCRITURAS ===

        // 3. Marcar el ingreso como inactivo (soft delete)
        transaction.update(ingresoRef, {
          'activo': false,
          'fechaEliminacion': FieldValue.serverTimestamp(),
        });

        // 4. Si había cuenta asociada, restar el monto del saldo
        if (cuentaDoc != null && cuentaDoc.exists) {
          final cuentaData = cuentaDoc.data()!;
          final saldoActual = (cuentaData['saldo'] as num?)?.toDouble() ?? 0.0;
          final nuevoSaldo = saldoActual - monto;

          // Actualizar el saldo
          transaction.update(cuentaDoc.reference, {
            'saldo': nuevoSaldo,
            'ultimaActualizacion': FieldValue.serverTimestamp(),
          });

          // Registrar el movimiento de reversión
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
      });

      return null; // Éxito
    } catch (e) {
      return 'Error al eliminar el ingreso: ${e.toString()}';
    }
  }

  /// === OBTENER INGRESOS COMO STREAM DE QUERYSNAPSHOT ===
  /// 
  /// Similar al patrón usado en gastos - retorna QuerySnapshot para compatibilidad
  Stream<QuerySnapshot> obtenerIngresosStream() {
    if (_userId == null) {
      return const Stream.empty();
    }

    return _ingresosRef()
        .where('activo', isEqualTo: true)
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  /// === OBTENER TOTAL DE INGRESOS ===
  /// 
  /// Calcula el total de ingresos en un período específico
  Future<double> obtenerTotalIngresos({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? categoria,
  }) async {
    try {
      if (_userId == null) return 0.0;

      var query = _ingresosRef().where('activo', isEqualTo: true);

      // Filtrar por fechas si se especifican
      if (fechaInicio != null) {
        query = query.where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio));
      }
      if (fechaFin != null) {
        query = query.where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin));
      }
      
      // Filtrar por categoría si se especifica
      if (categoria != null && categoria.isNotEmpty) {
        query = query.where('categoria', isEqualTo: categoria);
      }

      final snapshot = await query.get();
      double total = 0.0;

      for (var doc in snapshot.docs) {
        final monto = (doc.data()['monto'] as num).toDouble();
        total += monto;
      }

      return total;
    } catch (e) {
      return 0.0;
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
      return {'error': e.toString()};
    }
  }



}
