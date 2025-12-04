import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContrasenaDialogs {
  
  /// Muestra el diálogo de éxito cuando la contraseña se actualiza correctamente
  static Future<void> mostrarDialogoExito(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 12),
            Text('¡Éxito!'),
          ],
        ),
        content: const Text(
          'Tu contraseña ha sido actualizada correctamente.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Aceptar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra un error basado en la excepción de Firebase
  static void mostrarError(BuildContext context, FirebaseAuthException e) {
    String msg = 'Error al actualizar contraseña.';
    IconData icono = Icons.error;
    
    if (e.code == 'wrong-password') {
      msg = 'Contraseña actual incorrecta';
      icono = Icons.lock_outline;
    } else if (e.code == 'weak-password') {
      msg = 'La nueva contraseña es demasiado débil';
      icono = Icons.security;
    } else if (e.code == 'requires-recent-login') {
      msg = 'Necesitas volver a iniciar sesión para cambiar la contraseña';
      icono = Icons.login;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icono, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Muestra un error genérico
  static void mostrarErrorGenerico(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Muestra diálogo de confirmación antes de cambiar la contraseña
  static Future<bool> mostrarDialogoConfirmacion(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Confirmar cambio'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres cambiar tu contraseña? Deberás usar la nueva contraseña para futuras sesiones.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}