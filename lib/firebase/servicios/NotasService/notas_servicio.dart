/// SERVICIO PRINCIPAL DE NOTAS CON FIRESTORE
/// Gestiona todas las operaciones CRUD de notas usando Firebase Firestore
/// Las notas se almacenan como subcolección de cada usuario.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'modelo_nota.dart';
import 'funcionalidades/notas_crear.dart';
import 'funcionalidades/notas_leer.dart';
import 'funcionalidades/notas_actualizar.dart';
import 'funcionalidades/notas_eliminar.dart';

class NotasServicio {
  // Instancias de Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Servicios especializados
  late final NotasCrear _notasCrear;
  late final NotasLeer _notasLeer;
  late final NotasActualizar _notasActualizar;
  late final NotasEliminar _notasEliminar;

  NotasServicio() {
    _notasCrear = NotasCrear(_firestore, _auth);
    _notasLeer = NotasLeer(_firestore, _auth);
    _notasActualizar = NotasActualizar(_firestore, _auth);
    _notasEliminar = NotasEliminar(_firestore, _auth);
  }

  /// Obtiene la referencia de la colección de notas del usuario actual
  CollectionReference? get _notasCollection {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return _firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('notas');
  }

  /// Verifica si el usuario está autenticado
  bool get _isAuthenticated => _auth.currentUser != null;

  // ========== OPERACIONES PRINCIPALES ==========

  /// Crear una nueva nota
  Future<NotaModelo?> crearNota({
    required String texto,
    List<String> etiquetas = const [],
    String color = '#FFE082',
    bool esImportante = false,
    String? categoria,
  }) async {
    if (!_isAuthenticated) {
      throw Exception('Usuario no autenticado');
    }

    return await _notasCrear.crearNota(
      texto: texto,
      etiquetas: etiquetas,
      color: color,
      esImportante: esImportante,
      categoria: categoria,
    );
  }

  /// Obtener todas las notas del usuario
  Future<List<NotaModelo>> obtenerNotas() async {
    if (!_isAuthenticated) {
      return [];
    }

    return await _notasLeer.obtenerTodasLasNotas();
  }

  /// Stream de notas en tiempo real
  Stream<List<NotaModelo>>? obtenerNotasStream() {
    if (!_isAuthenticated) return null;
    
    return _notasLeer.obtenerNotasStream();
  }

  /// Buscar notas por texto
  Future<List<NotaModelo>> buscarNotas(String query) async {
    if (!_isAuthenticated) return [];
    
    return await _notasLeer.buscarNotas(query);
  }

  /// Obtener notas por categoría
  Future<List<NotaModelo>> obtenerNotasPorCategoria(String categoria) async {
    if (!_isAuthenticated) return [];
    
    return await _notasLeer.obtenerNotasPorCategoria(categoria);
  }

  /// Obtener notas importantes
  Future<List<NotaModelo>> obtenerNotasImportantes() async {
    if (!_isAuthenticated) return [];
    
    return await _notasLeer.obtenerNotasImportantes();
  }

  /// Actualizar una nota existente
  Future<bool> actualizarNota(NotaModelo nota) async {
    if (!_isAuthenticated) return false;
    
    return await _notasActualizar.actualizarNota(nota);
  }

  /// Marcar/desmarcar nota como importante
  Future<bool> toggleImportante(String notaId) async {
    if (!_isAuthenticated) return false;
    
    return await _notasActualizar.toggleImportante(notaId);
  }

  /// Cambiar color de la nota
  Future<bool> cambiarColor(String notaId, String nuevoColor) async {
    if (!_isAuthenticated) return false;
    
    return await _notasActualizar.cambiarColor(notaId, nuevoColor);
  }

  /// Eliminar una nota
  Future<bool> eliminarNota(String notaId) async {
    if (!_isAuthenticated) return false;
    
    return await _notasEliminar.eliminarNota(notaId);
  }

  /// Eliminar múltiples notas
  Future<int> eliminarMultiplesNotas(List<String> notaIds) async {
    if (!_isAuthenticated) return 0;
    
    return await _notasEliminar.eliminarMultiplesNotas(notaIds);
  }

  /// Eliminar todas las notas del usuario
  Future<bool> eliminarTodasLasNotas() async {
    if (!_isAuthenticated) return false;
    
    return await _notasEliminar.eliminarTodasLasNotas();
  }

  // ========== UTILIDADES ==========

  /// Obtener estadísticas de notas
  Future<Map<String, int>> obtenerEstadisticas() async {
    if (!_isAuthenticated) {
      return {'total': 0, 'importantes': 0, 'categorias': 0};
    }

    return await _notasLeer.obtenerEstadisticas();
  }

  /// Obtener todas las categorías únicas
  Future<List<String>> obtenerCategorias() async {
    if (!_isAuthenticated) return [];
    
    return await _notasLeer.obtenerCategorias();
  }

  /// Verificar si el servicio está disponible
  Future<bool> verificarDisponibilidad() async {
    try {
      return _isAuthenticated && _notasCollection != null;
    } catch (e) {
      return false;
    }
  }
}
