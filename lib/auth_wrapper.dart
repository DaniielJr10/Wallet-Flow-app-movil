import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login/iniciosesion.dart';
import 'pantallas/principal/principal.dart';

/// Wrapper de autenticación que decide qué pantalla mostrar
/// basado en el estado de autenticación del usuario
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mostrar indicador de carga mientras se verifica el estado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF10B981),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Cargando Wallet Flow...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Si hay un usuario autenticado, mostrar la pantalla principal directamente
        if (snapshot.hasData && snapshot.data != null) {
          return const PantallaPrincipal();
        }

        // Si no hay usuario autenticado, mostrar el login
        return const InicioSesionScreen();
      },
    );
  }
}

