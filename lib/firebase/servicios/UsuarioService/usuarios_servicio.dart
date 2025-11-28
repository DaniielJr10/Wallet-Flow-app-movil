import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase_configuracion.dart'; // Asegúrate de que la ruta sea correcta según tu estructura

/// Servicio para gestionar perfiles de usuarios en Firestore
/// Estructura: usuarios/{uid}
class UsuariosServicio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _perfilRef() {
    final uid = _userId;
    if (uid == null) {
      throw FirebaseAuthException(
          code: 'no-user', 
          message: FirebaseConfiguracion.errorUsuarioNoAutenticado
      );
    }
    return _firestore.collection(FirebaseConfiguracion.coleccionUsuarios).doc(uid);
  }

  /// Verifica si existe el documento de perfil del usuario autenticado
  Future<bool> existePerfilUsuario() async {
    final uid = _userId;
    if (uid == null) return false;
    try {
      final doc = await _perfilRef().get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Crea el perfil básico del usuario si no existe
  Future<String?> crearPerfilUsuario({
    required String nombre,
  }) async {
    final uid = _userId;
    final user = _auth.currentUser;
    
    if (uid == null || user == null) {
      return FirebaseConfiguracion.errorUsuarioNoAutenticado;
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
      
      return null; // Éxito
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
      print('Error al obtener perfil: $e');
      return null;
    }
  }
  
  /// PERFIL USUARIO - Obtener stream del documento de perfil (actualizaciones en tiempo real)
  Stream<DocumentSnapshot<Map<String, dynamic>>?> obtenerPerfilStream() {
    final uid = _userId;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection(FirebaseConfiguracion.coleccionUsuarios)
        .doc(uid)
        .snapshots();
  }

  /// Actualiza campos puntuales del perfil
  Future<String?> actualizarPerfil(Map<String, dynamic> datos) async {
    final uid = _userId;
    if (uid == null) return FirebaseConfiguracion.errorUsuarioNoAutenticado;
    
    try {
      final datosAActualizar = Map<String, dynamic>.from(datos);
      datosAActualizar['fechaActualizacion'] = FieldValue.serverTimestamp();
      
      await _perfilRef().update(datosAActualizar);
      return null; // Podrías retornar FirebaseConfiguracion.exitoPerfilActualizado si cambiaras el tipo de retorno
    } catch (e) {
      return 'Error al actualizar perfil: $e';
    }
  }

  /// === ELIMINAR DATOS DEL USUARIO PERMANENTEMENTE ===
  /// Rescatado de BaseDatosServicio.
  /// Borra todas las subcolecciones y finalmente el perfil.
  Future<String?> eliminarUsuarioPermanente() async {
    try {
      final uid = _userId;
      if (uid == null) return FirebaseConfiguracion.errorUsuarioNoAutenticado;

      final userDocRef = _firestore
          .collection(FirebaseConfiguracion.coleccionUsuarios)
          .doc(uid);

      // Lista de todas las colecciones que maneja tu app usando la configuración centralizada
      final List<String> colecciones = [
        FirebaseConfiguracion.coleccionAhorros,
        FirebaseConfiguracion.coleccionGastos,
        FirebaseConfiguracion.coleccionCuentas,
        FirebaseConfiguracion.coleccionDeudas,
        FirebaseConfiguracion.coleccionIngresos,
        // Agregamos otras si es necesario, como presupuestos o inversiones
        FirebaseConfiguracion.coleccionPresupuestos,
        FirebaseConfiguracion.coleccionInversiones,
        FirebaseConfiguracion.coleccionObjetivos,
        FirebaseConfiguracion.coleccionNotificaciones,
      ];

      for (final coleccion in colecciones) {
        final collRef = userDocRef.collection(coleccion);
        final snapshot = await collRef.get();
        
        for (final doc in snapshot.docs) {
          // Caso especial: Cuentas tiene sub-colección 'movimientos'
          if (coleccion == FirebaseConfiguracion.coleccionCuentas) {
            try {
              final movs = await doc.reference.collection('movimientos').get();
              for (final mv in movs.docs) {
                await mv.reference.delete();
              }
            } catch (_) {
              // Ignorar si no tiene movimientos
            }
          }

          // Borrar el documento principal
          await doc.reference.delete();
        }
      }

      // Finalmente borrar el documento de usuario (perfil)
      await userDocRef.delete();

      return null;
    } catch (e) {
      return 'Error al eliminar datos del usuario: $e';
    }
  }
}