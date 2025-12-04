/// SERVICIO SIMPLE DE FRECUENCIAS
/// Sistema sencillo: crea ingreso + programa automáticamente los siguientes
/// Usa subcollecciones usuarios/{uid}/ingresos como el resto del sistema
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../pantallas/ingresos/funcionalidades/frecuencia.dart';

class FrecuenciaServicio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Referencia a la subcollección de ingresos del usuario
  /// Estructura: usuarios/{uid}/ingresos
  CollectionReference<Map<String, dynamic>> _ingresosRef() {
    if (_userId == null) {
      return _firestore.collection('usuarios/__no_user__/ingresos');
    }
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection('ingresos');
  }

  /// Crea un ingreso que se repetirá automáticamente según la frecuencia
  Future<String?> crearIngresoConFrecuencia({
    required double monto,
    required DateTime fechaInicial,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    required TipoFrecuencia frecuencia,
    String? cuentaAsociada,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      if (monto <= 0) return 'El monto debe ser mayor a 0';
      if (descripcion.trim().isEmpty) return 'La descripción es requerida';

      await _firestore.runTransaction((transaction) async {
        // === FASE DE LECTURAS ===
        DocumentSnapshot<Map<String, dynamic>>? cuentaDoc;

        if (cuentaAsociada != null && cuentaAsociada.isNotEmpty && cuentaAsociada != 'ninguna') {
          final cuentaRef = _firestore
              .collection('usuarios')
              .doc(_userId)
              .collection('cuentas')
              .doc(cuentaAsociada);

          cuentaDoc = await transaction.get(cuentaRef);
          if (!cuentaDoc.exists) throw Exception('La cuenta asociada no existe');
        }

        // === FASE DE ESCRITURAS ===
        final ingresoRef = _ingresosRef().doc();

        final ingresoData = {
          'monto': monto,
          'fecha': Timestamp.fromDate(fechaInicial),
          'descripcion': descripcion.trim(),
          'categoria': categoria,
          'metodoPago': metodoPago,
          'cuentaAsociada': cuentaAsociada != 'ninguna' ? cuentaAsociada : null,
          'fechaCreacion': FieldValue.serverTimestamp(),
          // Campos de repetición
          'tieneRepeticion': true,
          'frecuencia': FrecuenciaUtils.aString(frecuencia),
          'proximaCreacion': FrecuenciaUtils.calcularProximaFecha(fechaInicial, frecuencia),
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
            'fecha': Timestamp.fromDate(fechaInicial),
            'ingresoId': ingresoRef.id,
            'fechaCreacion': FieldValue.serverTimestamp(),
          });
        }
      });

      return null;
    } catch (e) {
      return 'Error al crear ingreso: $e';
    }
  }

  /// Verifica y crea los ingresos que ya deben existir
  Future<int> procesarIngresosAutomaticos() async {
    try {
      if (_userId == null) return 0;

      final ahora = DateTime.now();
      int ingresosCreados = 0;

      // Buscar ingresos que tienen repetición programada
      final query = await _ingresosRef()
          .where('tieneRepeticion', isEqualTo: true)
          .get();

      for (final doc in query.docs) {
        final data = doc.data();
        final proximaCreacion = (data['proximaCreacion'] as Timestamp).toDate();

        // Si ya es tiempo de crear el siguiente
        if (_yaEsTiempo(ahora, proximaCreacion)) {
          await _crearSiguienteIngreso(doc.id, data);
          ingresosCreados++;
        }
      }

      return ingresosCreados;
    } catch (e) {
      print('Error procesando ingresos automáticos: $e');
      return 0;
    }
  }

  /// Crea el siguiente ingreso y actualiza la fecha
  Future<void> _crearSiguienteIngreso(String docId, Map<String, dynamic> data) async {
    final frecuencia = FrecuenciaUtils.desdeString(data['frecuencia'])!;
    final fechaActual = (data['proximaCreacion'] as Timestamp).toDate();
    final monto = (data['monto'] as num).toDouble();
    final cuentaAsociada = data['cuentaAsociada'] as String?;

    await _firestore.runTransaction((transaction) async {
      // === FASE DE LECTURAS ===
      DocumentSnapshot<Map<String, dynamic>>? cuentaDoc;

      if (cuentaAsociada != null && cuentaAsociada.isNotEmpty && cuentaAsociada != 'ninguna') {
        final cuentaRef = _firestore
            .collection('usuarios')
            .doc(_userId)
            .collection('cuentas')
            .doc(cuentaAsociada);

        cuentaDoc = await transaction.get(cuentaRef);
      }

      // === FASE DE ESCRITURAS ===
      // Crear nuevo ingreso (copia del original)
      final ingresoRef = _ingresosRef().doc();
      final nuevoIngreso = {
        'monto': monto,
        'fecha': Timestamp.fromDate(fechaActual),
        'descripcion': data['descripcion'],
        'categoria': data['categoria'],
        'metodoPago': data['metodoPago'],
        'cuentaAsociada': cuentaAsociada,
        'fechaCreacion': FieldValue.serverTimestamp(),
        // Sin campos de repetición - es un ingreso normal
      };

      transaction.set(ingresoRef, nuevoIngreso);

      // Actualizar saldo de la cuenta si existe
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
          'tipo': 'ingreso_automatico',
          'monto': monto,
          'descripcion': 'Ingreso automático: ${data['descripcion']}',
          'categoria': data['categoria'],
          'fecha': Timestamp.fromDate(fechaActual),
          'ingresoId': ingresoRef.id,
          'fechaCreacion': FieldValue.serverTimestamp(),
        });
      }

      // Actualizar la próxima fecha en el original
      final siguienteFecha = FrecuenciaUtils.calcularProximaFecha(fechaActual, frecuencia);
      final ingresoOriginalRef = _ingresosRef().doc(docId);
      transaction.update(ingresoOriginalRef, {
        'proximaCreacion': siguienteFecha,
      });
    });
  }

  bool _yaEsTiempo(DateTime ahora, DateTime proximaFecha) {
    return ahora.year > proximaFecha.year ||
        (ahora.year == proximaFecha.year && ahora.month > proximaFecha.month) ||
        (ahora.year == proximaFecha.year && 
         ahora.month == proximaFecha.month && 
         ahora.day >= proximaFecha.day);
  }

  /// Crea un solo ingreso normal (sin frecuencia)
  Future<String?> crearIngresoNormal({
    required double monto,
    required DateTime fecha,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    String? cuentaAsociada,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      if (monto <= 0) return 'El monto debe ser mayor a 0';
      if (descripcion.trim().isEmpty) return 'La descripción es requerida';

      await _firestore.runTransaction((transaction) async {
        // === FASE DE LECTURAS ===
        DocumentSnapshot<Map<String, dynamic>>? cuentaDoc;

        if (cuentaAsociada != null && cuentaAsociada.isNotEmpty && cuentaAsociada != 'ninguna') {
          final cuentaRef = _firestore
              .collection('usuarios')
              .doc(_userId)
              .collection('cuentas')
              .doc(cuentaAsociada);

          cuentaDoc = await transaction.get(cuentaRef);
          if (!cuentaDoc.exists) throw Exception('La cuenta asociada no existe');
        }

        // === FASE DE ESCRITURAS ===
        final ingresoRef = _ingresosRef().doc();

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
      return 'Error al crear ingreso: $e';
    }
  }

  /// Actualiza un ingreso y maneja los cambios de frecuencia
  Future<String?> actualizarIngresoConFrecuencia({
    required String ingresoId,
    required double monto,
    required DateTime fecha,
    required String descripcion,
    required String categoria,
    required String metodoPago,
    required TipoFrecuencia frecuenciaActual,
    required TipoFrecuencia nuevaFrecuencia,
    String? cuentaAsociada,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      if (monto <= 0) return 'El monto debe ser mayor a 0';
      if (descripcion.trim().isEmpty) return 'La descripción es requerida';

      await _firestore.runTransaction((transaction) async {
        // === FASE DE LECTURAS ===
        final ingresoRef = _ingresosRef().doc(ingresoId);
        final ingresoDoc = await transaction.get(ingresoRef);

        if (!ingresoDoc.exists) throw Exception('El ingreso no existe');

        final datosActuales = ingresoDoc.data()!;
        final montoAnterior = (datosActuales['monto'] as num).toDouble();
        final cuentaAnterior = datosActuales['cuentaAsociada'] as String?;

        DocumentSnapshot<Map<String, dynamic>>? cuentaAntDoc;
        if (cuentaAnterior != null && cuentaAnterior.isNotEmpty && cuentaAnterior != 'ninguna') {
          final cuentaAntRef = _firestore
              .collection('usuarios')
              .doc(_userId)
              .collection('cuentas')
              .doc(cuentaAnterior);
          cuentaAntDoc = await transaction.get(cuentaAntRef);
        }

        DocumentSnapshot<Map<String, dynamic>>? cuentaNuevaDoc;
        if (cuentaAsociada != null && cuentaAsociada.isNotEmpty && cuentaAsociada != 'ninguna') {
          final cuentaNuevaRef = _firestore
              .collection('usuarios')
              .doc(_userId)
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
        final nuevosdatos = <String, dynamic>{
          'monto': monto,
          'fecha': Timestamp.fromDate(fecha),
          'descripcion': descripcion.trim(),
          'categoria': categoria,
          'metodoPago': metodoPago,
          'cuentaAsociada': cuentaAsociada != 'ninguna' ? cuentaAsociada : null,
          'fechaModificacion': FieldValue.serverTimestamp(),
        };

        // Manejar cambios de frecuencia
        if (frecuenciaActual != nuevaFrecuencia) {
          if (nuevaFrecuencia == TipoFrecuencia.ninguna) {
            // Quitar frecuencia - eliminar campos de repetición
            nuevosdatos['tieneRepeticion'] = FieldValue.delete();
            nuevosdatos['frecuencia'] = FieldValue.delete();
            nuevosdatos['proximaCreacion'] = FieldValue.delete();
          } else {
            // Agregar o cambiar frecuencia
            nuevosdatos['tieneRepeticion'] = true;
            nuevosdatos['frecuencia'] = FrecuenciaUtils.aString(nuevaFrecuencia);
            nuevosdatos['proximaCreacion'] = FrecuenciaUtils.calcularProximaFecha(fecha, nuevaFrecuencia);
          }
        } else if (nuevaFrecuencia != TipoFrecuencia.ninguna) {
          // Mantener frecuencia pero actualizar próxima fecha si cambió la fecha base
          nuevosdatos['proximaCreacion'] = FrecuenciaUtils.calcularProximaFecha(fecha, nuevaFrecuencia);
        }

        transaction.update(ingresoRef, nuevosdatos);

        // === ACTUALIZACIÓN DE SALDOS DE CUENTAS ===
        // Normalizar valores para comparación correcta
        final cuentaAntNormalizada = (cuentaAnterior == null || cuentaAnterior.isEmpty || cuentaAnterior == 'ninguna') ? null : cuentaAnterior;
        final cuentaNuevaNormalizada = (cuentaAsociada == null || cuentaAsociada.isEmpty || cuentaAsociada == 'ninguna') ? null : cuentaAsociada;
        
        if (cuentaAntNormalizada != cuentaNuevaNormalizada) {
          // Cambio de cuenta: revertir en la anterior y agregar en la nueva
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
        } else if (cuentaNuevaNormalizada != null) {
          // Misma cuenta: solo actualizar la diferencia
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
      return 'Error al actualizar ingreso: $e';
    }
  }
}