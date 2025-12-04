/// FUNCIONALIDAD PARA ELIMINAR NOTAS
/// Maneja toda la lógica de eliminación de notas desde Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotasEliminar {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotasEliminar(this._firestore, this._auth);

  /// Eliminar una nota específica
  Future<bool> eliminarNota(String notaId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      if (notaId.isEmpty) {
        throw Exception('ID de nota inválido');
      }

      await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .doc(notaId)
          .delete();

      return true;

    } catch (e) {
      print('Error al eliminar nota: $e');
      return false;
    }
  }

  /// Eliminar múltiples notas usando operación batch
  Future<int> eliminarMultiplesNotas(List<String> notaIds) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      if (notaIds.isEmpty) return 0;

      // Firestore permite máximo 500 operaciones por batch
      const batchSize = 500;
      int eliminadas = 0;

      for (int i = 0; i < notaIds.length; i += batchSize) {
        final batch = _firestore.batch();
        final loteIds = notaIds.skip(i).take(batchSize).toList();

        for (final notaId in loteIds) {
          if (notaId.isNotEmpty) {
            final docRef = _firestore
                .collection('usuarios')
                .doc(user.uid)
                .collection('notas')
                .doc(notaId);
            
            batch.delete(docRef);
            eliminadas++;
          }
        }

        if (loteIds.isNotEmpty) {
          await batch.commit();
        }
      }

      return eliminadas;

    } catch (e) {
      print('Error al eliminar múltiples notas: $e');
      return 0;
    }
  }

  /// Eliminar todas las notas del usuario
  Future<bool> eliminarTodasLasNotas() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Obtener todas las notas primero
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .get();

      if (snapshot.docs.isEmpty) {
        return true; // No hay notas que eliminar
      }

      // Eliminar en lotes
      const batchSize = 500;
      final docs = snapshot.docs;

      for (int i = 0; i < docs.length; i += batchSize) {
        final batch = _firestore.batch();
        final lote = docs.skip(i).take(batchSize);

        for (final doc in lote) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }

      return true;

    } catch (e) {
      print('Error al eliminar todas las notas: $e');
      return false;
    }
  }

  /// Eliminar notas por categoría
  Future<int> eliminarNotasPorCategoria(String categoria) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      if (categoria.isEmpty) return 0;

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .where('categoria', isEqualTo: categoria)
          .get();

      if (snapshot.docs.isEmpty) {
        return 0;
      }

      const batchSize = 500;
      final docs = snapshot.docs;
      int eliminadas = 0;

      for (int i = 0; i < docs.length; i += batchSize) {
        final batch = _firestore.batch();
        final lote = docs.skip(i).take(batchSize);

        for (final doc in lote) {
          batch.delete(doc.reference);
          eliminadas++;
        }

        await batch.commit();
      }

      return eliminadas;

    } catch (e) {
      print('Error al eliminar notas por categoría: $e');
      return 0;
    }
  }

  /// Eliminar notas antiguas (más de X días)
  Future<int> eliminarNotasAntiguas(int diasAntiguedad) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      if (diasAntiguedad < 1) return 0;

      final fechaLimite = DateTime.now().subtract(Duration(days: diasAntiguedad));

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .where('fechaCreacion', isLessThan: fechaLimite.toIso8601String())
          .get();

      if (snapshot.docs.isEmpty) {
        return 0;
      }

      const batchSize = 500;
      final docs = snapshot.docs;
      int eliminadas = 0;

      for (int i = 0; i < docs.length; i += batchSize) {
        final batch = _firestore.batch();
        final lote = docs.skip(i).take(batchSize);

        for (final doc in lote) {
          batch.delete(doc.reference);
          eliminadas++;
        }

        await batch.commit();
      }

      return eliminadas;

    } catch (e) {
      print('Error al eliminar notas antiguas: $e');
      return 0;
    }
  }

  /// Eliminar notas que no son importantes
  Future<int> eliminarNotasNoImportantes() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .where('esImportante', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        return 0;
      }

      const batchSize = 500;
      final docs = snapshot.docs;
      int eliminadas = 0;

      for (int i = 0; i < docs.length; i += batchSize) {
        final batch = _firestore.batch();
        final lote = docs.skip(i).take(batchSize);

        for (final doc in lote) {
          batch.delete(doc.reference);
          eliminadas++;
        }

        await batch.commit();
      }

      return eliminadas;

    } catch (e) {
      print('Error al eliminar notas no importantes: $e');
      return 0;
    }
  }

  /// Eliminar notas vacías o con solo espacios en blanco
  Future<int> eliminarNotasVacias() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .get();

      if (snapshot.docs.isEmpty) {
        return 0;
      }

      final batch = _firestore.batch();
      int eliminadas = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final texto = data['texto'] as String? ?? '';
        
        if (texto.trim().isEmpty) {
          batch.delete(doc.reference);
          eliminadas++;
        }
      }

      if (eliminadas > 0) {
        await batch.commit();
      }

      return eliminadas;

    } catch (e) {
      print('Error al eliminar notas vacías: $e');
      return 0;
    }
  }

  /// Verificar si una nota existe antes de eliminarla
  Future<bool> notaExiste(String notaId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .doc(notaId)
          .get();

      return doc.exists;

    } catch (e) {
      print('Error al verificar existencia de nota: $e');
      return false;
    }
  }

  /// Obtener count de notas que serían eliminadas (para confirmación)
  Future<int> contarNotasParaEliminar({
    String? categoria,
    int? diasAntiguedad,
    bool? soloNoImportantes,
    bool? soloVacias,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      Query query = _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas');

      if (categoria != null && categoria.isNotEmpty) {
        query = query.where('categoria', isEqualTo: categoria);
      }

      if (diasAntiguedad != null && diasAntiguedad > 0) {
        final fechaLimite = DateTime.now().subtract(Duration(days: diasAntiguedad));
        query = query.where('fechaCreacion', isLessThan: fechaLimite.toIso8601String());
      }

      if (soloNoImportantes == true) {
        query = query.where('esImportante', isEqualTo: false);
      }

      final snapshot = await query.get();

      if (soloVacias == true) {
        int vacias = 0;
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final texto = data['texto'] as String? ?? '';
          if (texto.trim().isEmpty) vacias++;
        }
        return vacias;
      }

      return snapshot.docs.length;

    } catch (e) {
      print('Error al contar notas para eliminar: $e');
      return 0;
    }
  }
}
