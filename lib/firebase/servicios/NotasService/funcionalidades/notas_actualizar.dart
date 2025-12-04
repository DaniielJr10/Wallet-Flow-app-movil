/// FUNCIONALIDAD PARA ACTUALIZAR NOTAS
/// Maneja toda la lógica de modificación de notas existentes en Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelo_nota.dart';

class NotasActualizar {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotasActualizar(this._firestore, this._auth);

  /// Actualizar una nota completa
  Future<bool> actualizarNota(NotaModelo nota) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      if (nota.id == null || nota.id!.isEmpty) {
        throw Exception('ID de nota inválido');
      }

      // Validar que el texto no esté vacío
      if (nota.texto.trim().isEmpty) {
        throw Exception('El texto de la nota no puede estar vacío');
      }

      // Actualizar la fecha de modificación
      final notaActualizada = nota.copyWith(
        fechaActualizacion: DateTime.now(),
      );

      await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .doc(nota.id!)
          .update(notaActualizada.toFirestore());

      return true;

    } catch (e) {
      print('Error al actualizar nota: $e');
      return false;
    }
  }

  /// Actualizar solo el texto de la nota
  Future<bool> actualizarTexto(String notaId, String nuevoTexto) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      if (nuevoTexto.trim().isEmpty) {
        throw Exception('El texto no puede estar vacío');
      }

      await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .doc(notaId)
          .update({
        'texto': nuevoTexto.trim(),
        'fechaActualizacion': DateTime.now().toIso8601String(),
      });

      return true;

    } catch (e) {
      print('Error al actualizar texto: $e');
      return false;
    }
  }

  /// Marcar/desmarcar nota como importante
  Future<bool> toggleImportante(String notaId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final docRef = _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .doc(notaId);

      // Usar transacción para evitar condiciones de carrera
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) {
          throw Exception('Nota no encontrada');
        }

        final data = snapshot.data()!;
        final esImportante = data['esImportante'] ?? false;

        transaction.update(docRef, {
          'esImportante': !esImportante,
          'fechaActualizacion': DateTime.now().toIso8601String(),
        });
      });

      return true;

    } catch (e) {
      print('Error al cambiar estado importante: $e');
      return false;
    }
  }

  /// Cambiar color de la nota
  Future<bool> cambiarColor(String notaId, String nuevoColor) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Validar formato de color
      if (!_esColorValido(nuevoColor)) {
        throw Exception('Formato de color inválido');
      }

      await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .doc(notaId)
          .update({
        'color': nuevoColor,
        'fechaActualizacion': DateTime.now().toIso8601String(),
      });

      return true;

    } catch (e) {
      print('Error al cambiar color: $e');
      return false;
    }
  }

  /// Actualizar etiquetas de la nota
  Future<bool> actualizarEtiquetas(String notaId, List<String> nuevasEtiquetas) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Limpiar y validar etiquetas
      final etiquetasLimpias = nuevasEtiquetas
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && _esEtiquetaValida(e))
          .toSet()
          .toList();

      await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .doc(notaId)
          .update({
        'etiquetas': etiquetasLimpias,
        'fechaActualizacion': DateTime.now().toIso8601String(),
      });

      return true;

    } catch (e) {
      print('Error al actualizar etiquetas: $e');
      return false;
    }
  }

  /// Cambiar categoría de la nota
  Future<bool> cambiarCategoria(String notaId, String? nuevaCategoria) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final categoriaLimpia = nuevaCategoria?.trim();

      await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas')
          .doc(notaId)
          .update({
        'categoria': categoriaLimpia?.isEmpty == true ? null : categoriaLimpia,
        'fechaActualizacion': DateTime.now().toIso8601String(),
      });

      return true;

    } catch (e) {
      print('Error al cambiar categoría: $e');
      return false;
    }
  }

  /// Actualizar múltiples notas a la vez (operación batch)
  Future<int> actualizarMultiplesNotas(List<NotaModelo> notas) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      if (notas.isEmpty) return 0;

      final batch = _firestore.batch();
      final ahora = DateTime.now();
      int actualizadas = 0;

      for (final nota in notas) {
        if (nota.id == null || nota.id!.isEmpty) continue;
        if (nota.texto.trim().isEmpty) continue;

        final docRef = _firestore
            .collection('usuarios')
            .doc(user.uid)
            .collection('notas')
            .doc(nota.id!);

        final notaActualizada = nota.copyWith(
          fechaActualizacion: ahora,
        );

        batch.update(docRef, notaActualizada.toFirestore());
        actualizadas++;
      }

      if (actualizadas > 0) {
        await batch.commit();
      }

      return actualizadas;

    } catch (e) {
      print('Error al actualizar múltiples notas: $e');
      return 0;
    }
  }

  /// Marcar múltiples notas como importantes/no importantes
  Future<int> toggleImportanteMultiples(List<String> notaIds, bool esImportante) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      if (notaIds.isEmpty) return 0;

      final batch = _firestore.batch();
      final ahora = DateTime.now().toIso8601String();

      for (final notaId in notaIds) {
        final docRef = _firestore
            .collection('usuarios')
            .doc(user.uid)
            .collection('notas')
            .doc(notaId);

        batch.update(docRef, {
          'esImportante': esImportante,
          'fechaActualizacion': ahora,
        });
      }

      await batch.commit();
      return notaIds.length;

    } catch (e) {
      print('Error al cambiar múltiples importantes: $e');
      return 0;
    }
  }

  // ========== MÉTODOS DE VALIDACIÓN ==========

  /// Validar formato de color hexadecimal
  bool _esColorValido(String color) {
    if (color.isEmpty) return false;
    
    // Debe empezar con # y tener 7 caracteres (#RRGGBB) o 9 (#AARRGGBB)
    final regex = RegExp(r'^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$');
    return regex.hasMatch(color);
  }

  /// Validar formato de etiqueta
  bool _esEtiquetaValida(String etiqueta) {
    if (etiqueta.isEmpty || etiqueta.length > 50) return false;
    
    // Solo letras, números, espacios, guiones y guiones bajos
    final regex = RegExp(r'^[\w\s\-_]+$');
    return regex.hasMatch(etiqueta);
  }

  /// Validar que una nota se puede actualizar
  bool validarActualizacion(NotaModelo nota) {
    if (nota.id == null || nota.id!.isEmpty) return false;
    if (nota.texto.trim().isEmpty) return false;
    if (nota.texto.length > 10000) return false;
    
    // Validar etiquetas
    for (final etiqueta in nota.etiquetas) {
      if (!_esEtiquetaValida(etiqueta)) return false;
    }
    
    // Validar color
    if (!_esColorValido(nota.color)) return false;
    
    return true;
  }
}
