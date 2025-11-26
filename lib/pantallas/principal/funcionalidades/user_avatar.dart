/// AVATAR DE USUARIO
/// Maneja la visualización de la foto de perfil.
/// - Si el usuario tiene foto en Firebase, la carga.
/// - Si está cargando, muestra un spinner.
/// - Si no tiene foto o falla, muestra la inicial del nombre.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAvatar extends StatelessWidget {
  final String nombreUsuario;
  final double size;

  const UserAvatar({
    super.key,
    required this.nombreUsuario,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoURL = user?.photoURL;
    
    if (photoURL != null && photoURL.isNotEmpty) {
      return Image.network(
        photoURL,
        fit: BoxFit.cover,
        width: size,
        height: size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildContainer(
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return _buildContainer(
      child: Center(
        child: Text(
          nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: size * 0.46,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF10B981),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}