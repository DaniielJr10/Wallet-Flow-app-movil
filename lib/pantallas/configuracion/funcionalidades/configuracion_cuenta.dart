/**
 * FUNCIONALIDAD: Gestión de cuenta de usuario
 * 
 * Este archivo maneja todas las operaciones relacionadas con la cuenta del usuario:
 * - Eliminación permanente de cuenta con todos sus datos
 * - Cierre de sesión seguro 
 * - Integración con servicios de autenticación de Firebase
 * - Limpieza de datos en Firestore al eliminar cuenta
 * - Navegación a pantallas de autenticación
 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importar servicios necesarios
import '../../../firebase/autenticacion_servicio.dart';
import '../../../firebase/servicios/UsuarioService/usuarios_servicio.dart';
import '../../../login/iniciosesion/iniciosesion.dart';

class ConfiguracionCuenta {
  // Servicios necesarios
  static final AutenticacionServicio _authService = AutenticacionServicio();
  static final UsuariosServicio _usuariosService = UsuariosServicio();

  /// Muestra diálogo de confirmación para eliminar cuenta
  static void confirmarEliminarCuenta(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cuenta'),
        content: const Text(
          'Esta acción eliminará todos tus datos permanentemente. ¿Estás seguro?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _procesarEliminacionCuenta(context);
            },
            child: const Text(
              'Eliminar', 
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo de confirmación para cerrar sesión
  static void confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _procesarCerrarSesion(context);
            },
            child: const Text(
              'Salir', 
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Procesa la eliminación completa de la cuenta del usuario
  static Future<void> _procesarEliminacionCuenta(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eliminando cuenta...')),
      );
    }

    try {
      // 1. Eliminar datos de Firestore usando el servicio modular
      final errorDb = await _usuariosService.eliminarUsuarioPermanente();
      
      if (errorDb != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorDb), 
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 2. Eliminar cuenta de Authentication
      await currentUser.delete();

    } catch (e) {
      debugPrint('Error eliminando cuenta: $e');
      
      // Manejar diferentes tipos de errores de autenticación
      String mensajeError;
      
      if (e.toString().contains('requires-recent-login')) {
        mensajeError = 'Por seguridad, necesitas iniciar sesión nuevamente para eliminar tu cuenta.';
      } else if (e.toString().contains('network-request-failed')) {
        mensajeError = 'Error de conexión. Verifica tu internet e intenta nuevamente.';
      } else {
        mensajeError = 'Error al eliminar la cuenta: $e';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeError),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // 3. Cerrar sesión y navegar a inicio de sesión
    try {
      await _authService.cerrarSesion();
    } catch (e) {
      debugPrint('Error cerrando sesión después de eliminar cuenta: $e');
    }

    // 4. Navegar a pantalla de inicio de sesión
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta eliminada exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const InicioSesionScreen()),
        (route) => false,
      );
    }
  }

  /// Procesa el cierre de sesión del usuario
  static Future<void> _procesarCerrarSesion(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cerrando sesión...')),
        );
      }

      // Cerrar sesión usando el servicio de autenticación
      await _authService.cerrarSesion();

      // Navegar a pantalla de inicio de sesión
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const InicioSesionScreen()),
          (route) => false,
        );
      }

    } catch (e) {
      debugPrint('Error cerrando sesión: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Crea el botón de cerrar sesión con estilo
  static Widget buildBotonCerrarSesion(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () => confirmarCerrarSesion(context),
        icon: const Icon(Icons.logout),
        label: const Text(
          'Cerrar Sesión', 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  /// Verifica si hay un usuario autenticado
  static bool hayUsuarioAutenticado() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Obtiene información básica del usuario actual
  static Map<String, String?> obtenerInfoUsuarioActual() {
    final user = FirebaseAuth.instance.currentUser;
    
    return {
      'uid': user?.uid,
      'email': user?.email,
      'nombre': user?.displayName,
      'fotoUrl': user?.photoURL,
    };
  }

  /// Valida que el usuario esté autenticado antes de realizar operaciones sensibles
  static Future<bool> validarAutenticacion(BuildContext context) async {
    if (!hayUsuarioAutenticado()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes estar autenticado para realizar esta acción.'),
            backgroundColor: Colors.orange,
          ),
        );
        
        // Navegar a inicio de sesión
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const InicioSesionScreen()),
          (route) => false,
        );
      }
      return false;
    }
    return true;
  }
}