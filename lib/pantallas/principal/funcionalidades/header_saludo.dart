/// HEADER DE BIENVENIDA
/// La tarjeta verde superior. Muestra el logo, el saludo personalizado
/// con el nombre del usuario y su avatar. Contiene también el botón de logout.
import 'package:flutter/material.dart';
import 'user_avatar.dart';

class HeaderSaludo extends StatelessWidget {
  final String nombreUsuario;
  final VoidCallback onAvatarTap;
  final VoidCallback onLogoutTap;

  const HeaderSaludo({
    super.key,
    required this.nombreUsuario,
    required this.onAvatarTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF2ecc71),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo y nombre app centrados arriba
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/logo.png',
                    width: 38,
                    height: 38,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance_wallet, color: Colors.white),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    'Wallet Flow',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Foto de perfil
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Container(
                      width: 62,
                      height: 62,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: UserAvatar(nombreUsuario: nombreUsuario),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, $nombreUsuario',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 50,
          right: 0,
          child: IconButton(
            onPressed: onLogoutTap,
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFB71C1C), // Rojo más intenso
              size: 32, // Más grande/grueso
              weight: 800, // Si usas Flutter 3.10+ para iconos variables
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
            ),
            tooltip: 'Cerrar sesión',
          ),
        ),
      ],
    );
  }
}