/// FUNCIONALIDAD PARA LEER NOTAS
/// Maneja toda la lógica de consulta y lectura de notas desde Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelo_nota.dart';

class NotasLeer {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotasLeer(this._firestore, this._auth);

  /// Obtener todas las notas del usuario ordenadas por fecha de actualización
  Future<List<NotaModelo>> obtenerTodasLasNotas() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .orderBy('fechaActualizacion', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotaModelo.fromFirestore(doc.data(), doc.id))
          .toList();

    } catch (e) {
      print('Error al obtener todas las notas: $e');
      return [];
    }
  }

  /// Stream para obtener notas en tiempo real
  Stream<List<NotaModelo>> obtenerNotasStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('notas')
        .orderBy('fechaActualizacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotaModelo.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Buscar notas por texto (búsqueda simple)
  Future<List<NotaModelo>> buscarNotas(String query) async {
    try {
      if (query.trim().isEmpty) {
        return obtenerTodasLasNotas();
      }

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .orderBy('fechaActualizacion', descending: true)
          .get();

      final queryLowerCase = query.toLowerCase();

      return snapshot.docs
          .map((doc) => NotaModelo.fromFirestore(doc.data(), doc.id))
          .where((nota) =>
              nota.texto.toLowerCase().contains(queryLowerCase) ||
              nota.etiquetas.any((etiqueta) => etiqueta.toLowerCase().contains(queryLowerCase)) ||
              (nota.categoria?.toLowerCase().contains(queryLowerCase) ?? false))
          .toList();

    } catch (e) {
      print('Error al buscar notas: $e');
      return [];
    }
  }

  /// Obtener una nota específica por ID
  Future<NotaModelo?> obtenerNotaPorId(String notaId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final doc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .doc(notaId)
          .get();

      if (doc.exists && doc.data() != null) {
        return NotaModelo.fromFirestore(doc.data()!, doc.id);
      }

      return null;

    } catch (e) {
      print('Error al obtener nota por ID: $e');
      return null;
    }
  }

  /// Obtener notas por categoría
  Future<List<NotaModelo>> obtenerNotasPorCategoria(String categoria) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .where('categoria', isEqualTo: categoria)
          .orderBy('fechaActualizacion', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotaModelo.fromFirestore(doc.data(), doc.id))
          .toList();

    } catch (e) {
      print('Error al obtener notas por categoría: $e');
      return [];
    }
  }

  /// Obtener notas importantes
  Future<List<NotaModelo>> obtenerNotasImportantes() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .where('esImportante', isEqualTo: true)
          .orderBy('fechaActualizacion', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotaModelo.fromFirestore(doc.data(), doc.id))
          .toList();

    } catch (e) {
      print('Error al obtener notas importantes: $e');
      return [];
    }
  }

  /// Obtener notas por rango de fechas
  Future<List<NotaModelo>> obtenerNotasPorFechas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      Query query = _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas');

      if (fechaInicio != null) {
        query = query.where('fechaCreacion', isGreaterThanOrEqualTo: fechaInicio.toIso8601String());
      }

      if (fechaFin != null) {
        query = query.where('fechaCreacion', isLessThanOrEqualTo: fechaFin.toIso8601String());
      }

      final snapshot = await query
          .orderBy('fechaCreacion', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotaModelo.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

    } catch (e) {
      print('Error al obtener notas por fechas: $e');
      return [];
    }
  }

  /// Obtener estadísticas de notas
  Future<Map<String, int>> obtenerEstadisticas() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'total': 0, 'importantes': 0, 'categorias': 0};
      }

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .get();

      final notas = snapshot.docs
          .map((doc) => NotaModelo.fromFirestore(doc.data(), doc.id))
          .toList();

      final categoriasUnicas = <String>{};
      int importantes = 0;

      for (final nota in notas) {
        if (nota.esImportante) importantes++;
        if (nota.categoria != null && nota.categoria!.isNotEmpty) {
          categoriasUnicas.add(nota.categoria!);
        }
      }

      return {
        'total': notas.length,
        'importantes': importantes,
        'categorias': categoriasUnicas.length,
      };

    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {'total': 0, 'importantes': 0, 'categorias': 0};
    }
  }

  /// Obtener todas las categorías únicas
  Future<List<String>> obtenerCategorias() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .get();

      final categorias = <String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final categoria = data['categoria'] as String?;
        if (categoria != null && categoria.isNotEmpty) {
          categorias.add(categoria);
        }
      }

      return categorias.toList()..sort();

    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }
}
