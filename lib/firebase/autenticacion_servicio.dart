import 'package:firebase_auth/firebase_auth.dart';

/// Servicio que maneja toda la autenticación de usuarios
/// Incluye: login, registro, cerrar sesión, recuperar contraseña
class AutenticacionServicio {
  // Instancia de Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Obtiene el usuario actual
  User? get usuarioActual => _auth.currentUser;
  
  /// Stream para escuchar cambios en el estado de autenticación
  Stream<User?> get cambiosAutenticacion => _auth.authStateChanges();
  
  /// INICIAR SESIÓN con email y contraseña
  Future<String?> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      // Intentar iniciar sesión
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      return null; // Éxito - sin error
      
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase
      switch (e.code) {
        case 'user-not-found':
          return 'No existe una cuenta con este correo electrónico';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'invalid-email':
          return 'El formato del correo electrónico es inválido';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Intenta más tarde';
        default:
          return 'Error al iniciar sesión: ${e.message}';
      }
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }
  
  /// REGISTRAR USUARIO nuevo
  Future<String?> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
  }) async {
    try {
      // Crear nueva cuenta
      UserCredential resultado = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Actualizar el perfil del usuario con su nombre
      await resultado.user?.updateDisplayName('$nombre $apellido');
      
      return null; // Éxito - sin error
      
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase
      switch (e.code) {
        case 'weak-password':
          return 'La contraseña es muy débil';
        case 'email-already-in-use':
          return 'Ya existe una cuenta con este correo electrónico';
        case 'invalid-email':
          return 'El formato del correo electrónico es inválido';
        case 'operation-not-allowed':
          return 'El registro con email/contraseña no está habilitado';
        default:
          return 'Error al registrar usuario: ${e.message}';
      }
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }
  
  /// RECUPERAR CONTRASEÑA
  Future<String?> recuperarPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // Éxito - sin error
      
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No existe una cuenta con este correo electrónico';
        case 'invalid-email':
          return 'El formato del correo electrónico es inválido';
        default:
          return 'Error al enviar email: ${e.message}';
      }
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }
  
  /// CERRAR SESIÓN
  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }
  
  /// VERIFICAR si el usuario está logueado
  bool get estaLogueado => _auth.currentUser != null;
  
  /// OBTENER EMAIL del usuario actual
  String? get emailUsuario => _auth.currentUser?.email;
  
  /// OBTENER NOMBRE del usuario actual
  String? get nombreUsuario => _auth.currentUser?.displayName;
}