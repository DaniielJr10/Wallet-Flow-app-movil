import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContrasenaHeader extends StatelessWidget {
  const ContrasenaHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Usuario';
    final displayEmail = user?.email ?? 'correo@ejemplo.com';
    
    // Obtener iniciales del nombre
    String initials = 'U';
    if (displayName != 'Usuario' && displayName.isNotEmpty) {
      final names = displayName.split(' ');
      if (names.length >= 2) {
        initials = names[0][0] + names[1][0];
      } else {
        initials = displayName[0];
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF10B981),
            Color(0xFF059669),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(initials),
          const SizedBox(width: 16),
          Expanded(
            child: _buildUserInfo(displayName, displayEmail),
          ),
        ],
      ),
    );
  }

  /// Construye el avatar del usuario
  Widget _buildAvatar(String initials) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Construye la información del usuario
  Widget _buildUserInfo(String displayName, String displayEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Hola, $displayName!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Actualiza tu contraseña de forma segura',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayEmail,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}