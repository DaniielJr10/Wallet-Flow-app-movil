/// FUNCIONALIDAD PARA CREAR NOTAS
/// Maneja toda la lógica de creación de nuevas notas en Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelo_nota.dart';

class NotasCrear {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotasCrear(this._firestore, this._auth);

  /// Crear una nueva nota en Firestore
  Future<NotaModelo?> crearNota({
    required String texto,
    List<String> etiquetas = const [],
    String color = '#FFE082',
    bool esImportante = false,
    String? categoria,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Validar que el texto no esté vacío
      if (texto.trim().isEmpty) {
        throw Exception('El texto de la nota no puede estar vacío');
      }

      final ahora = DateTime.now();
      
      // Crear el modelo de nota
      final nuevaNota = NotaModelo(
        texto: texto.trim(),
        fechaCreacion: ahora,
        fechaActualizacion: ahora,
        etiquetas: etiquetas,
        color: color,
        esImportante: esImportante,
        categoria: categoria?.trim(),
      );

      // Referencia a la colección de notas del usuario
      final notasRef = _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas');

      // Agregar la nota a Firestore
      final docRef = await notasRef.add(nuevaNota.toFirestore());

      // Retornar la nota con el ID generado
      return nuevaNota.copyWith(id: docRef.id);

    } catch (e) {
      // Log del error para debugging
      print('Error al crear nota: $e');
      
      // Re-lanzar el error para que lo maneje quien llame a esta función
      rethrow;
    }
  }

  /// Crear múltiples notas en una sola operación (batch)
  Future<List<NotaModelo>> crearMultiplesNotas(List<Map<String, dynamic>> datosNotas) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      if (datosNotas.isEmpty) {
        return [];
      }

      final batch = _firestore.batch();
      final notasRef = _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('notas');

      final notasCreadas = <NotaModelo>[];
      final ahora = DateTime.now();

      for (final datos in datosNotas) {
        // Validar datos básicos
        if (datos['texto'] == null || datos['texto'].toString().trim().isEmpty) {
          continue;
        }

        final nuevaNota = NotaModelo(
          texto: datos['texto'].toString().trim(),
          fechaCreacion: ahora,
          fechaActualizacion: ahora,
          etiquetas: List<String>.from(datos['etiquetas'] ?? []),
          color: datos['color'] ?? '#FFE082',
          esImportante: datos['esImportante'] ?? false,
          categoria: datos['categoria']?.toString().trim(),
        );

        final docRef = notasRef.doc();
        batch.set(docRef, nuevaNota.toFirestore());
        
        notasCreadas.add(nuevaNota.copyWith(id: docRef.id));
      }

      // Ejecutar todas las operaciones de una vez
      await batch.commit();
      
      return notasCreadas;

    } catch (e) {
      print('Error al crear múltiples notas: $e');
      rethrow;
    }
  }

  /// Crear nota desde datos locales (migración)
  Future<NotaModelo?> crearNotaDesdeDatosLocales(Map<String, dynamic> datosLocales) async {
    try {
      final nota = NotaModelo.fromLocal(datosLocales);
      
      return await crearNota(
        texto: nota.texto,
        etiquetas: nota.etiquetas,
        color: nota.color,
        esImportante: nota.esImportante,
        categoria: nota.categoria,
      );

    } catch (e) {
      print('Error al crear nota desde datos locales: $e');
      rethrow;
    }
  }

  /// Validar si una nota se puede crear
  bool validarDatosNota({
    required String texto,
    List<String>? etiquetas,
    String? categoria,
  }) {
    // El texto no puede estar vacío
    if (texto.trim().isEmpty) return false;
    
    // El texto no puede ser demasiado largo (límite de 10000 caracteres)
    if (texto.length > 10000) return false;
    
    // Las etiquetas no pueden tener caracteres especiales
    if (etiquetas != null) {
      for (final etiqueta in etiquetas) {
        if (etiqueta.contains(RegExp(r'[^\w\s-_]'))) return false;
      }
    }
    
    // La categoría no puede tener caracteres especiales
    if (categoria != null && categoria.contains(RegExp(r'[^\w\s-_]'))) return false;
    
    return true;
  }
}
