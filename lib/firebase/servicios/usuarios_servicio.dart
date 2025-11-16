import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para gestionar perfiles de usuarios en Firestore
/// Estructura: usuarios/{uid}
class UsuariosServicio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _perfilRef() {
    final uid = _userId;
    return _firestore.collection('usuarios').doc(uid);
  }

  /// Verifica si existe el documento de perfil del usuario autenticado
  Future<bool> existePerfilUsuario() async {
    final uid = _userId;
    if (uid == null) return false;
    final doc = await _perfilRef().get();
    return doc.exists;
  }

  /// Crea el perfil básico del usuario si no existe
  Future<String?> crearPerfilUsuario({
    required String nombre,
  }) async {
    final uid = _userId;
    final user = _auth.currentUser;
    if (uid == null || user == null) {
      return 'Usuario no autenticado';
    }

    try {
      final now = FieldValue.serverTimestamp();
      await _perfilRef().set({
        'uid': uid,
        'nombre': nombre,
        'email': user.email,
        'photoURL': user.photoURL,
        'fechaRegistro': now,
        'fechaActualizacion': now,
      }, SetOptions(merge: true));
      return null;
    } catch (e) {
      return 'Error al crear perfil: $e';
    }
  }

  /// Obtiene el perfil del usuario autenticado
  Future<DocumentSnapshot<Map<String, dynamic>>?> obtenerPerfil() async {
    final uid = _userId;
    if (uid == null) return null;
    try {
      return await _perfilRef().get();
    } catch (e) {
      return null;
    }
  }

  /// Actualiza campos puntuales del perfil
  Future<String?> actualizarPerfil(Map<String, dynamic> datos) async {
    final uid = _userId;
    if (uid == null) return 'Usuario no autenticado';
    try {
      datos['fechaActualizacion'] = FieldValue.serverTimestamp();
      await _perfilRef().update(datos);
      return null;
    } catch (e) {
      return 'Error al actualizar perfil: $e';
    }
  }
}
