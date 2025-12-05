/// SERVICIO DE NOTAS SOLO EN BD (Firestore)
/// Este servicio usa exclusivamente Firebase Firestore para leer/escribir.
/// No se guarda nada en almacenamiento local.
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../firebase/servicios/NotasService/notas_servicio.dart';
import '../../../../../firebase/servicios/NotasService/modelo_nota.dart';

class ServicioNotas {
  final NotasServicio _notasFirebase = NotasServicio();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Cargar notas desde Firebase (única fuente)
  Future<List<Map<String, dynamic>>> cargarNotas() async {
    try {
      if (_auth.currentUser == null) return [];

      final notasFirebase = await _notasFirebase.obtenerNotas();
      return notasFirebase.map((nota) => nota.toLocal()).toList();
    } catch (e) {
      print('Error al cargar notas de Firebase: $e');
      return [];
    }
  }

  /// Guardar/sincronizar notas en Firebase.
  /// También elimina en BD las notas que ya no existan en la lista provista.
  Future<void> guardarNotas(List<Map<String, dynamic>> notes) async {
    try {
      if (_auth.currentUser == null) return;

      await _sincronizarNotasFirebase(notes);
    } catch (e) {
      print('Error al guardar en Firebase: $e');
    }
  }

  /// Crear una nota y devolver su representación local (incluye id)
  Future<Map<String, dynamic>?> crearNota({
    required String texto,
    List<String> etiquetas = const [],
    String color = '#FFE082',
    bool esImportante = false,
    String? categoria,
  }) async {
    if (_auth.currentUser == null) return null;
    final creada = await _notasFirebase.crearNota(
      texto: texto,
      etiquetas: etiquetas,
      color: color,
      esImportante: esImportante,
      categoria: categoria,
    );
    return creada?.toLocal();
  }

  /// Actualizar una sola nota en Firestore (no crea, requiere id)
  Future<bool> actualizarNota(Map<String, dynamic> nota) async {
    if (_auth.currentUser == null) return false;

    final id = nota['id'] as String?;
    if (id == null || id.isEmpty) {
      print('ActualizarNota: id faltante, no se puede actualizar');
      return false;
    }

    try {
      final modelo = NotaModelo(
        id: id,
        texto: nota['text'] ?? nota['texto'] ?? '',
        etiquetas: List<String>.from(nota['tags'] ?? nota['etiquetas'] ?? []),
        color: nota['color'] ?? '#FFE082',
        esImportante: nota['esImportante'] ?? false,
        categoria: nota['categoria'],
        fechaCreacion: DateTime.tryParse(nota['fechaCreacion'] ?? '' ?? '') ?? DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );
      return await _notasFirebase.actualizarNota(modelo);
    } catch (e) {
      print('Error al actualizar nota $id: $e');
      return false;
    }
  }

  /// Eliminar una nota por id directamente en Firestore
  Future<bool> eliminarNotaPorId(String id) async {
    if (_auth.currentUser == null) return false;
    return await _notasFirebase.eliminarNota(id);
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Sincroniza la lista de notas con Firestore:
  /// - Crea las notas sin id
  /// - Actualiza las que traen id
  /// - Elimina en BD las que existen en BD pero no vienen en `notes`
  Future<void> _sincronizarNotasFirebase(List<Map<String, dynamic>> notes) async {
    // Obtener estado actual en BD
    final actuales = await _notasFirebase.obtenerNotas();
    final idsActuales = actuales.map((n) => n.id).toSet();

    // Mapear por id las notas entrantes
    final entrantesConId = <String, Map<String, dynamic>>{};
    final entrantesSinId = <Map<String, dynamic>>[];

    for (final n in notes) {
      final id = n['id'] as String?;
      if (id == null || id.isEmpty) {
        entrantesSinId.add(n);
      } else {
        entrantesConId[id] = n;
      }
    }

    // 1) Crear nuevas (sin id)
    for (final n in entrantesSinId) {
      try {
        await _notasFirebase.crearNota(
          texto: n['text'] ?? n['texto'] ?? '',
          etiquetas: List<String>.from(n['tags'] ?? n['etiquetas'] ?? []),
          color: n['color'] ?? '#FFE082',
          esImportante: n['esImportante'] ?? false,
          categoria: n['categoria'],
        );
      } catch (e) {
        print('Error creando nota: $e');
      }
    }

    // 2) Actualizar existentes (con id)
    for (final actual in actuales) {
      final entrante = entrantesConId[actual.id];
      if (entrante != null) {
        try {
          final actualizado = NotaModelo(
            id: actual.id,
            texto: entrante['text'] ?? entrante['texto'] ?? actual.texto,
            etiquetas: List<String>.from(entrante['tags'] ?? entrante['etiquetas'] ?? actual.etiquetas),
            color: entrante['color'] ?? actual.color,
            esImportante: entrante['esImportante'] ?? actual.esImportante,
            categoria: entrante['categoria'] ?? actual.categoria,
            fechaCreacion: actual.fechaCreacion,
            fechaActualizacion: DateTime.now(),
          );
          await _notasFirebase.actualizarNota(actualizado);
        } catch (e) {
          print('Error actualizando nota ${actual.id}: $e');
        }
      }
    }

    // 3) Eliminar en BD las que no están en la lista entrante
    final idsEntrantes = entrantesConId.keys.toSet();
  final aEliminar = idsActuales.difference(idsEntrantes).where((id) => id != null && id.isNotEmpty);

  for (final id in aEliminar) {
      try {
    await _notasFirebase.eliminarNota(id!);
      } catch (e) {
        print('Error eliminando nota $id: $e');
      }
    }
  }
}