import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio especializado para gestión de cuentas bancarias
/// Maneja todas las operaciones CRUD específicas de cuentas
class CuentasServicio {
  // Instancias de Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Nombre de la colección en Firestore
  static const String _coleccionCuentas = 'cuentas';
  
  /// ID del usuario actual
  String? get _userId => _auth.currentUser?.uid;
  
  /// Referencia a la subcolección de cuentas del usuario autenticado
  /// Estructura: usuarios/{uid}/cuentas
  CollectionReference<Map<String, dynamic>> _cuentasRef() {
    if (_userId == null) {
      // Se usa una referencia a una colección ficticia cuando no hay usuario
      // para evitar nulls; sin embargo, los métodos validarán el userId.
      return _firestore.collection('usuarios/__no_user__/$_coleccionCuentas');
    }
    return _firestore
      .collection('usuarios')
      .doc(_userId)
      .collection(_coleccionCuentas);
  }
  
  /// CREAR nueva cuenta bancaria
  Future<String?> crearCuenta({
    required String banco,
    required String numeroCuenta,
    required String tipo,
    required double saldo,
    String? alias,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      
      // Validaciones básicas
      if (banco.trim().isEmpty) return 'El nombre del banco es requerido';
      if (numeroCuenta.trim().isEmpty) return 'El número de cuenta es requerido';
      if (saldo < 0) return 'El saldo no puede ser negativo';
      
      // Verificar si ya existe una cuenta con el mismo número
      final existeCuenta = await _verificarCuentaExistente(numeroCuenta.trim());
      if (existeCuenta) {
        return 'Ya existe una cuenta con este número';
      }
      
      // Crear documento en la subcolección del usuario
      await _cuentasRef().add({
        'banco': banco.trim(),
        'numeroCuenta': numeroCuenta.trim(),
        'tipo': tipo,
        'saldo': saldo,
        'alias': alias?.trim(),
        'usuarioId': _userId, // opcional, útil para auditoría
        'fechaCreacion': FieldValue.serverTimestamp(),
        'fechaModificacion': FieldValue.serverTimestamp(),
        'activa': true,
      });
      
      return null; // Éxito - sin error
      
    } catch (e) {
      return 'Error al crear cuenta: $e';
    }
  }
  
  /// OBTENER todas las cuentas del usuario
  Stream<QuerySnapshot> obtenerCuentas() {
    if (_userId == null) {
      return const Stream.empty();
    }
    
    // Temporalmente sin filtro para debug
    return _cuentasRef().snapshots();
  }
  
  /// OBTENER cuenta específica por ID
  Future<DocumentSnapshot?> obtenerCuentaPorId(String cuentaId) async {
    try {
      if (_userId == null) return null;
      
      final doc = await _cuentasRef().doc(cuentaId).get();
      
      // Verificar que la cuenta pertenezca al usuario
      if (doc.exists) {
        final data = doc.data();
        if (data?['usuarioId'] == _userId) {
          return doc;
        }
      }
      
      return null;
    } catch (e) {
      print('Error al obtener cuenta: $e');
      return null;
    }
  }
  
  /// ACTUALIZAR cuenta existente
  Future<String?> actualizarCuenta({
    required String cuentaId,
    required String banco,
    required String numeroCuenta,
    required String tipo,
    required double saldo,
    String? alias,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      
      // Validaciones básicas
      if (banco.trim().isEmpty) return 'El nombre del banco es requerido';
      if (numeroCuenta.trim().isEmpty) return 'El número de cuenta es requerido';
      if (saldo < 0) return 'El saldo no puede ser negativo';
      
      // Verificar que la cuenta pertenezca al usuario
      final cuentaExistente = await obtenerCuentaPorId(cuentaId);
      if (cuentaExistente == null || !cuentaExistente.exists) {
        return 'Cuenta no encontrada';
      }
      
      // Verificar si el número de cuenta ya existe en otra cuenta
      final existeOtraCuenta = await _verificarCuentaExistenteExcepto(
        numeroCuenta.trim(), 
        cuentaId
      );
      if (existeOtraCuenta) {
        return 'Ya existe otra cuenta con este número';
      }
      
      // Actualizar documento en subcolección
      await _cuentasRef().doc(cuentaId).update({
        'banco': banco.trim(),
        'numeroCuenta': numeroCuenta.trim(),
        'tipo': tipo,
        'saldo': saldo,
        'alias': alias?.trim(),
        'fechaModificacion': FieldValue.serverTimestamp(),
      });
      
      return null; // Éxito - sin error
      
    } catch (e) {
      return 'Error al actualizar cuenta: $e';
    }
  }
  
  /// ELIMINAR cuenta (eliminación lógica)
  Future<String?> eliminarCuenta(String cuentaId) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      
      // Verificar que la cuenta pertenezca al usuario
      final cuentaExistente = await obtenerCuentaPorId(cuentaId);
      if (cuentaExistente == null || !cuentaExistente.exists) {
        return 'Cuenta no encontrada';
      }
      
      // Eliminación lógica (marcar como inactiva)
      await _cuentasRef().doc(cuentaId).update({
        'activa': false,
        'fechaEliminacion': FieldValue.serverTimestamp(),
        'fechaModificacion': FieldValue.serverTimestamp(),
      });
      
      return null; // Éxito - sin error
      
    } catch (e) {
      return 'Error al eliminar cuenta: $e';
    }
  }
  
  /// ELIMINAR cuenta permanentemente (eliminación física)
  Future<String?> eliminarCuentaPermanente(String cuentaId) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      
      // Verificar que la cuenta pertenezca al usuario
      final cuentaExistente = await obtenerCuentaPorId(cuentaId);
      if (cuentaExistente == null || !cuentaExistente.exists) {
        return 'Cuenta no encontrada';
      }
      
      // Eliminación física del documento en subcolección
      await _cuentasRef().doc(cuentaId).delete();
      
      return null; // Éxito - sin error
      
    } catch (e) {
      return 'Error al eliminar cuenta permanentemente: $e';
    }
  }
  
  /// ACTUALIZAR saldo de una cuenta específica
  Future<String?> actualizarSaldo({
    required String cuentaId,
    required double nuevoSaldo,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      
      if (nuevoSaldo < 0) return 'El saldo no puede ser negativo';
      
      // Verificar que la cuenta pertenezca al usuario
      final cuentaExistente = await obtenerCuentaPorId(cuentaId);
      if (cuentaExistente == null || !cuentaExistente.exists) {
        return 'Cuenta no encontrada';
      }
      
      // Actualizar solo el saldo en subcolección
      await _cuentasRef().doc(cuentaId).update({
        'saldo': nuevoSaldo,
        'fechaModificacion': FieldValue.serverTimestamp(),
      });
      
      return null; // Éxito - sin error
      
    } catch (e) {
      return 'Error al actualizar saldo: $e';
    }
  }
  
  /// CALCULAR saldo total de todas las cuentas del usuario
  Future<double> calcularSaldoTotal() async {
    try {
      if (_userId == null) return 0.0;
      
      final snapshot = await _cuentasRef()
          .where('activa', isEqualTo: true)
          .get();
      
      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final saldo = (data['saldo'] ?? 0.0) as num;
        total += saldo.toDouble();
      }
      
      return total;
      
    } catch (e) {
      print('Error al calcular saldo total: $e');
      return 0.0;
    }
  }
  
  /// OBTENER número de cuentas del usuario
  Future<int> obtenerNumeroCuentas() async {
    try {
      if (_userId == null) return 0;
      
      final snapshot = await _cuentasRef()
          .where('activa', isEqualTo: true)
          .get();
      
      return snapshot.docs.length;
      
    } catch (e) {
      print('Error al obtener número de cuentas: $e');
      return 0;
    }
  }
  
  /// BUSCAR cuentas por texto (banco o número de cuenta)
  Future<List<QueryDocumentSnapshot>> buscarCuentas(String textoBusqueda) async {
    try {
      if (_userId == null || textoBusqueda.trim().isEmpty) return [];
      
      final texto = textoBusqueda.trim().toLowerCase();
      
      // Obtener todas las cuentas del usuario
      final snapshot = await _cuentasRef()
          .where('activa', isEqualTo: true)
          .get();
      
      // Filtrar por texto en el cliente (Firestore no soporta búsqueda de texto completa)
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
  
  /// VERIFICAR si ya existe una cuenta con el número especificado
  Future<bool> _verificarCuentaExistente(String numeroCuenta) async {
    try {
      if (_userId == null) return false;
      
      final snapshot = await _cuentasRef()
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
  
  /// VERIFICAR si existe otra cuenta con el número especificado (excluyendo la cuenta actual)
  Future<bool> _verificarCuentaExistenteExcepto(String numeroCuenta, String cuentaIdExcluir) async {
    try {
      if (_userId == null) return false;
      
      final snapshot = await _cuentasRef()
          .where('numeroCuenta', isEqualTo: numeroCuenta)
          .where('activa', isEqualTo: true)
          .get();
      
      // Filtrar el documento actual
      final cuentasExistentes = snapshot.docs.where((doc) => doc.id != cuentaIdExcluir);
      
      return cuentasExistentes.isNotEmpty;
      
    } catch (e) {
      print('Error al verificar cuenta existente: $e');
      return false;
    }
  }
  
  /// OBTENER estadísticas de cuentas del usuario
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      if (_userId == null) {
        return {
          'totalCuentas': 0,
          'saldoTotal': 0.0,
          'cuentaPorTipo': <String, int>{},
          'saldoPorTipo': <String, double>{},
        };
      }
      
      final snapshot = await _cuentasRef()
          .where('activa', isEqualTo: true)
          .get();
      
      double saldoTotal = 0.0;
      Map<String, int> cuentasPorTipo = {};
      Map<String, double> saldoPorTipo = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final saldo = (data['saldo'] ?? 0.0) as num;
        final tipo = data['tipo'] ?? 'otro';
        
        saldoTotal += saldo.toDouble();
        
        // Contar cuentas por tipo
        cuentasPorTipo[tipo] = (cuentasPorTipo[tipo] ?? 0) + 1;
        
        // Sumar saldo por tipo
        saldoPorTipo[tipo] = (saldoPorTipo[tipo] ?? 0.0) + saldo.toDouble();
      }
      
      return {
        'totalCuentas': snapshot.docs.length,
        'saldoTotal': saldoTotal,
        'cuentaPorTipo': cuentasPorTipo,
        'saldoPorTipo': saldoPorTipo,
      };
      
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {
        'totalCuentas': 0,
        'saldoTotal': 0.0,
        'cuentaPorTipo': <String, int>{},
        'saldoPorTipo': <String, double>{},
      };
    }
  }

  /// MIGRACIÓN: Copia las cuentas del usuario desde la colección raíz
  /// 'cuentas' hacia 'usuarios/{uid}/cuentas' y elimina las antiguas.
  /// Úsalo una sola vez si ya tenías datos en la colección raíz.
  Future<String?> migrarCuentasDesdeColeccionRaiz() async {
    try {
      if (_userId == null) return 'Usuario no autenticado';

      final origen = await _firestore
          .collection(_coleccionCuentas)
          .where('usuarioId', isEqualTo: _userId)
          .get();

      if (origen.docs.isEmpty) {
        return null; // Nada que migrar
      }

      final batch = _firestore.batch();
      for (final doc in origen.docs) {
        final data = doc.data();
        final destinoDoc = _cuentasRef().doc(doc.id);
        batch.set(destinoDoc, data, SetOptions(merge: true));
        batch.delete(doc.reference);
      }

      await batch.commit();
      return null;
    } catch (e) {
      return 'Error al migrar cuentas: $e';
    }
  }
}
