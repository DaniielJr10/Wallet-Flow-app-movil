import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio especializado para gestión de gastos
/// Maneja todas las operaciones CRUD específicas de gastos
/// Estructura: usuarios/{uid}/gastos
class GastosServicio {
  // Instancias de Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Nombre de la colección en Firestore
  static const String _coleccionGastos = 'gastos';
  
  /// ID del usuario actual
  String? get _userId => _auth.currentUser?.uid;
  
  /// Referencia a la subcolección de gastos del usuario autenticado
  /// Estructura: usuarios/{uid}/gastos
  CollectionReference<Map<String, dynamic>> _gastosRef() {
    if (_userId == null) {
      // Se usa una referencia a una colección ficticia cuando no hay usuario
      return _firestore.collection('usuarios/__no_user__/$_coleccionGastos');
    }
    return _firestore
      .collection('usuarios')
      .doc(_userId)
      .collection(_coleccionGastos);
  }
  
  /// CREAR nuevo gasto
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
      
      if (_userId == null) {
        print('❌ Usuario no autenticado');
        return 'Usuario no autenticado';
      }
      
      print('✅ Usuario autenticado: $_userId');
      
      // Validaciones básicas
      if (descripcion.trim().isEmpty) return 'La descripción es requerida';
      if (monto <= 0) return 'El monto debe ser mayor a 0';
      if (categoria.trim().isEmpty) return 'La categoría es requerida';
      if (metodoPago.trim().isEmpty) return 'El método de pago es requerido';
      
      print('✅ Validaciones básicas completadas');
      
      // Verificar si la cuenta asociada existe (si se especificó una)
      if (cuentaAsociada != null && cuentaAsociada != 'ninguna' && cuentaAsociada.isNotEmpty) {
        print('🔍 Verificando cuenta asociada: $cuentaAsociada');
        
        final cuentaExiste = await _verificarCuentaExiste(cuentaAsociada);
        if (!cuentaExiste) {
          print('❌ La cuenta asociada no existe');
          return 'La cuenta asociada no existe';
        }
        
        print('✅ Cuenta existe, verificando saldo');
        
        // Verificar saldo suficiente
        final saldoSuficiente = await _verificarSaldoSuficiente(cuentaAsociada, monto);
        if (!saldoSuficiente) {
          print('❌ Saldo insuficiente en la cuenta');
          return 'Saldo insuficiente en la cuenta';
        }
        
        print('✅ Saldo suficiente');
      } else {
        print('ℹ️ No se especificó cuenta asociada o es "ninguna"');
      }
      
      print('🔍 Iniciando transacción para crear gasto');
      
      // Usar transacción para garantizar consistencia
      await _firestore.runTransaction((transaction) async {
        print('🔍 Dentro de la transacción');
        
        // IMPORTANTE: Hacer todas las LECTURAS primero
        DocumentSnapshot? cuentaDoc;
        final cuentaRef = cuentaAsociada != null && cuentaAsociada != 'ninguna' && cuentaAsociada.isNotEmpty
            ? _firestore.collection('usuarios').doc(_userId).collection('cuentas').doc(cuentaAsociada)
            : null;
        
        if (cuentaRef != null) {
          print('🔍 Leyendo datos de cuenta antes de escribir');
          cuentaDoc = await transaction.get(cuentaRef);
        }
        
        // Ahora hacer todas las ESCRITURAS
        
        // 1. Crear documento del gasto en la subcolección del usuario
        final gastoRef = _gastosRef().doc();
        
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
          'usuarioId': _userId, // Para auditoría
          'fechaCreacion': FieldValue.serverTimestamp(),
          'fechaModificacion': FieldValue.serverTimestamp(),
          'activo': true,
        };
        
        print('🔍 Datos del gasto a guardar: $gastoData');
        
        transaction.set(gastoRef, gastoData);
        print('✅ Gasto creado en Firestore');
        
        // 2. Si hay cuenta asociada, actualizar saldo
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
          
          // Registrar movimiento en historial de la cuenta
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
      return null; // Éxito - sin error
      
    } catch (e) {
      print('❌ Error en crearGasto: $e');
      return 'Error al crear gasto: $e';
    }
  }
  
  /// OBTENER todos los gastos del usuario
  Stream<QuerySnapshot> obtenerGastos() {
    if (_userId == null) {
      return const Stream.empty();
    }
    
    try {
      // Obtener todos los gastos ordenados por fecha de creación
      return _gastosRef()
          .orderBy('fechaCreacion', descending: true)
          .snapshots();
    } catch (e) {
      return const Stream.empty();
    }
  }
  
  /// ACTUALIZAR gasto existente
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
      if (_userId == null) return 'Usuario no autenticado';
      
      // Validaciones básicas
      if (gastoId.trim().isEmpty) return 'ID del gasto requerido';
      if (descripcion.trim().isEmpty) return 'La descripción es requerida';
      if (monto <= 0) return 'El monto debe ser mayor a 0';
      if (categoria.trim().isEmpty) return 'La categoría es requerida';
      if (metodoPago.trim().isEmpty) return 'El método de pago es requerido';
      
      // Verificar que el gasto existe
      final gastoDoc = await _gastosRef().doc(gastoId).get();
      if (!gastoDoc.exists) {
        return 'El gasto no existe';
      }
      
      // TODO: Implementar lógica compleja de actualización con cambios en cuentas
      // Por ahora, actualización simple sin cambios de cuenta
      await _gastosRef().doc(gastoId).update({
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
      
      return null; // Éxito - sin error
      
    } catch (e) {
      return 'Error al actualizar gasto: $e';
    }
  }
  
  /// ELIMINAR gasto (eliminación completa de la base de datos)
  Future<String?> eliminarGasto(String gastoId) async {
    try {
      print('🗑️ Iniciando eliminación de gasto: $gastoId');
      
      if (_userId == null) {
        print('❌ Usuario no autenticado');
        return 'Usuario no autenticado';
      }
      if (gastoId.trim().isEmpty) {
        print('❌ ID del gasto vacío');
        return 'ID del gasto requerido';
      }
      
      // Verificar que el gasto existe
      final gastoDoc = await _gastosRef().doc(gastoId).get();
      if (!gastoDoc.exists) {
        print('❌ El gasto no existe en la base de datos');
        return 'El gasto no existe';
      }
      
      final gastoData = gastoDoc.data()!;
      final monto = (gastoData['monto'] as num).toDouble();
      final cuentaAsociada = gastoData['cuentaAsociada'] as String?;
      
      print('🔍 Gasto encontrado: monto: $monto, cuenta: $cuentaAsociada');
      
      // Usar transacción para garantizar consistencia
      await _firestore.runTransaction((transaction) async {
        // IMPORTANTE: Hacer todas las LECTURAS primero
        DocumentSnapshot? cuentaDoc;
        final cuentaRef = cuentaAsociada != null && cuentaAsociada != 'ninguna' && cuentaAsociada.isNotEmpty
            ? _firestore.collection('usuarios').doc(_userId).collection('cuentas').doc(cuentaAsociada)
            : null;
        
        if (cuentaRef != null) {
          print('🔍 Leyendo cuenta asociada para devolver el dinero');
          cuentaDoc = await transaction.get(cuentaRef);
        }
        
        // Ahora hacer todas las ESCRITURAS
        print('🔍 Eliminando gasto completamente de la base de datos');
        
        // 1. Eliminar el documento del gasto completamente
        transaction.delete(_gastosRef().doc(gastoId));
        
        print('✅ Gasto eliminado de la base de datos');
        
        // 2. Si había cuenta asociada, devolver el monto
        if (cuentaRef != null && cuentaDoc != null && cuentaDoc.exists) {
          print('🔍 Devolviendo dinero a la cuenta');
          final cuentaData = cuentaDoc.data()! as Map<String, dynamic>;
          final saldoActual = (cuentaData['saldo'] as num).toDouble();
          final nuevoSaldo = saldoActual + monto; // Devolver el dinero
          
          print('🔍 Saldo actual: $saldoActual, Nuevo saldo: $nuevoSaldo');
          
          transaction.update(cuentaRef, {
            'saldo': nuevoSaldo,
            'fechaModificacion': FieldValue.serverTimestamp(),
          });
          
          print('✅ Saldo actualizado');
          
          // Registrar movimiento de reversión
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
      return null; // Éxito - sin error
      
    } catch (e) {
      print('❌ Error al eliminar gasto: $e');
      return 'Error al eliminar gasto: $e';
    }
  }
  
  /// OBTENER un gasto específico por ID
  Future<DocumentSnapshot?> obtenerGasto(String gastoId) async {
    try {
      if (_userId == null) return null;
      if (gastoId.trim().isEmpty) return null;
      
      return await _gastosRef().doc(gastoId).get();
      
    } catch (e) {
      return null;
    }
  }
  
  /// OBTENER gastos por categoría
  Stream<QuerySnapshot> obtenerGastosPorCategoria(String categoria) {
    if (_userId == null) {
      return const Stream.empty();
    }
    
    // Simplificamos para evitar índice compuesto
    // Filtraremos 'activo' en el cliente
    return _gastosRef()
        .where('categoria', isEqualTo: categoria)
        .orderBy('fechaCreacion', descending: true)
        .snapshots();
  }
  
  /// OBTENER gastos por rango de fechas
  Stream<QuerySnapshot> obtenerGastosPorFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) {
    if (_userId == null) {
      return const Stream.empty();
    }
    
    // Simplificamos para evitar índice compuesto
    // Filtraremos 'activo' en el cliente
    return _gastosRef()
        .where('fechaCreacion', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio))
        .where('fechaCreacion', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin))
        .orderBy('fechaCreacion', descending: true)
        .snapshots();
  }
  
  /// OBTENER total de gastos por período
  Future<double> obtenerTotalGastos({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? categoria,
  }) async {
    try {
      if (_userId == null) return 0.0;
      
      Query<Map<String, dynamic>> query = _gastosRef()
          .where('activo', isEqualTo: true);
      
      if (fechaInicio != null) {
        query = query.where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio));
      }
      
      if (fechaFin != null) {
        query = query.where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin));
      }
      
      if (categoria != null && categoria.isNotEmpty) {
        query = query.where('categoria', isEqualTo: categoria);
      }
      
      final snapshot = await query.get();
      double total = 0.0;
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final monto = (data['monto'] as num?)?.toDouble() ?? 0.0;
        total += monto;
      }
      
      return total;
      
    } catch (e) {
      return 0.0;
    }
  }
  
  // ====== MÉTODOS PRIVADOS DE VALIDACIÓN ======
  
  /// Verifica si una cuenta existe
  Future<bool> _verificarCuentaExiste(String cuentaId) async {
    try {
      if (_userId == null) {
        print('❌ _verificarCuentaExiste: Usuario no autenticado');
        return false;
      }
      
      print('🔍 _verificarCuentaExiste: Verificando cuenta $cuentaId para usuario $_userId');
      
      final doc = await _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('cuentas')
          .doc(cuentaId)
          .get();
      
      final existe = doc.exists;
      print('🔍 _verificarCuentaExiste: Cuenta $cuentaId existe: $existe');
      
      if (existe) {
        final data = doc.data();
        print('🔍 _verificarCuentaExiste: Datos de la cuenta: $data');
      }
      
      return existe;
    } catch (e) {
      print('❌ _verificarCuentaExiste: Error $e');
      return false;
    }
  }
  
  /// Verifica si una cuenta tiene saldo suficiente
  Future<bool> _verificarSaldoSuficiente(String cuentaId, double monto) async {
    try {
      if (_userId == null) {
        print('❌ _verificarSaldoSuficiente: Usuario no autenticado');
        return false;
      }
      
      print('🔍 _verificarSaldoSuficiente: Verificando saldo para cuenta $cuentaId, monto requerido: $monto');
      
      final doc = await _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('cuentas')
          .doc(cuentaId)
          .get();
      
      if (!doc.exists) {
        print('❌ _verificarSaldoSuficiente: Cuenta no existe');
        return false;
      }
      
      final saldo = (doc.data()!['saldo'] as num).toDouble();
      final suficiente = saldo >= monto;
      
      print('🔍 _verificarSaldoSuficiente: Saldo actual: $saldo, Suficiente: $suficiente');
      
      return suficiente;
      
    } catch (e) {
      print('❌ _verificarSaldoSuficiente: Error $e');
      return false;
    }
  }
}