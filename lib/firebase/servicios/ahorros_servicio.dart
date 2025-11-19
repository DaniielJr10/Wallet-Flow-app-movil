import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para gestionar metas de ahorro en Firebase
/// Estructura: usuarios/{uid}/ahorros/{metaId}
class AhorrosServicio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _coleccionAhorros = 'ahorros';

  String? get _userId => _auth.currentUser?.uid;

  /// Referencia a la subcolección de ahorros del usuario
  CollectionReference<Map<String, dynamic>> _ahorrosRef() {
    if (_userId == null) {
      return _firestore.collection('usuarios/__no_user__/$_coleccionAhorros');
    }
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection(_coleccionAhorros);
  }

  /// === CREAR NUEVA META DE AHORRO ===
  Future<String?> crearMetaAhorro({
    required String nombre,
    required double montoInicial,
    required double montoObjetivo,
    required DateTime fechaObjetivo,
    required String categoria,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      if (nombre.trim().isEmpty) return 'El nombre es requerido';
      if (montoObjetivo <= 0) return 'El monto objetivo debe ser mayor a 0';

      await _firestore.runTransaction((transaction) async {
        final metaRef = _ahorrosRef().doc();
        final metaData = {
          'nombre': nombre,
          'montoInicial': montoInicial,
          'montoActual': montoInicial,
          'montoObjetivo': montoObjetivo,
          'fechaObjetivo': Timestamp.fromDate(fechaObjetivo),
          'categoria': categoria,
          'fechaCreacion': Timestamp.now(),
        };
        transaction.set(metaRef, metaData);
      });
      return null;
    } catch (e) {
      return 'Error al crear la meta: ${e.toString()}';
    }
  }

  /// === OBTENER METAS DE AHORRO ===
  Stream<List<Map<String, dynamic>>> obtenerMetasAhorro() {
    if (_userId == null) return Stream.value([]);
    try {
      return _ahorrosRef().snapshots().map((snapshot) {
        final metas = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          if (data['fechaObjetivo'] is Timestamp) {
            data['fechaObjetivo'] = (data['fechaObjetivo'] as Timestamp).toDate();
          }
          if (data['fechaCreacion'] is Timestamp) {
            data['fechaCreacion'] = (data['fechaCreacion'] as Timestamp).toDate();
          }
          return data;
        }).toList();
        metas.sort((a, b) {
          final fechaA = a['fechaCreacion'] as DateTime?;
          final fechaB = b['fechaCreacion'] as DateTime?;
          if (fechaA == null && fechaB == null) return 0;
          if (fechaA == null) return 1;
          if (fechaB == null) return -1;
          return fechaB.compareTo(fechaA);
        });
        return metas;
      });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// === ACTUALIZAR META DE AHORRO ===
  Future<String?> actualizarMetaAhorro({
    required String metaId,
    required String nombre,
    required double montoObjetivo,
    required DateTime fechaObjetivo,
    required String categoria,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      if (nombre.trim().isEmpty) return 'El nombre es requerido';
      if (montoObjetivo <= 0) return 'El monto objetivo debe ser mayor a 0';
      await _firestore.runTransaction((transaction) async {
        final metaRef = _ahorrosRef().doc(metaId);
        transaction.update(metaRef, {
          'nombre': nombre,
          'montoObjetivo': montoObjetivo,
          'fechaObjetivo': Timestamp.fromDate(fechaObjetivo),
          'categoria': categoria,
        });
      });
      return null;
    } catch (e) {
      return 'Error al actualizar la meta: ${e.toString()}';
    }
  }

  /// === AGREGAR MONTO A META DE AHORRO ===
  Future<String?> agregarMontoMeta({
    required String metaId,
    required double montoAgregar,
  }) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      if (montoAgregar <= 0) return 'El monto debe ser mayor a 0';
      await _firestore.runTransaction((transaction) async {
        final metaRef = _ahorrosRef().doc(metaId);
        final metaDoc = await transaction.get(metaRef);
        if (!metaDoc.exists) throw Exception('Meta no encontrada');
        final montoActual = (metaDoc.data()!['montoActual'] as num).toDouble();
        transaction.update(metaRef, {
          'montoActual': montoActual + montoAgregar,
        });
      });
      return null;
    } catch (e) {
      return 'Error al agregar monto: ${e.toString()}';
    }
  }

  /// === ELIMINAR META DE AHORRO ===
  Future<String?> eliminarMetaAhorro(String metaId) async {
    try {
      if (_userId == null) return 'Usuario no autenticado';
      await _firestore.runTransaction((transaction) async {
        final metaRef = _ahorrosRef().doc(metaId);
        transaction.delete(metaRef);
      });
      return null;
    } catch (e) {
      return 'Error al eliminar la meta: ${e.toString()}';
    }
  }
}
