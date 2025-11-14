import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase/servicios/usuarios_servicio.dart';
import 'login/iniciosesion.dart';
import 'pantallas/principal.dart';

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

        // Si hay un usuario autenticado, verificar perfil y mostrar la pantalla principal
        if (snapshot.hasData && snapshot.data != null) {
          return _PerfilVerificador(user: snapshot.data!);
        }

        // Si no hay usuario autenticado, mostrar el login
        return const InicioSesionScreen();
      },
    );
  }
}

/// Widget que verifica si existe el perfil del usuario y lo crea si es necesario
class _PerfilVerificador extends StatefulWidget {
  final User user;
  
  const _PerfilVerificador({required this.user});

  @override
  State<_PerfilVerificador> createState() => _PerfilVerificadorState();
}

class _PerfilVerificadorState extends State<_PerfilVerificador> {
  late Future<bool> _verificacionPerfil;
  
  @override
  void initState() {
    super.initState();
    _verificacionPerfil = _verificarYCrearPerfil();
  }
  
  Future<bool> _verificarYCrearPerfil() async {
    try {
      final usuariosServicio = UsuariosServicio();
      
      print('🔍 Verificando perfil para usuario: ${widget.user.uid}');
      
      // Verificar si existe el perfil
      final existePerfil = await usuariosServicio.existePerfilUsuario();
      
      if (!existePerfil) {
        print('🔍 Perfil no existe, creando automáticamente...');
        
        // Extraer nombre del displayName o email
        final displayName = widget.user.displayName ?? '';
        final email = widget.user.email ?? '';
        
        String nombre = 'Usuario';
    
        
        if (displayName.isNotEmpty) {
          final partes = displayName.split(' ');
          nombre = partes.isNotEmpty ? partes.first : 'Usuario';
        } else if (email.isNotEmpty) {
          nombre = email.split('@').first;
        }
        
        final error = await usuariosServicio.crearPerfilUsuario(
          nombre: nombre,
        );
        
        if (error != null) {
          print('🚨 Error al crear perfil automático: $error');
          return false;
        }
        
        print('✅ Perfil creado automáticamente');
      } else {
        print('✅ Perfil ya existe');
      }
      
      return true;
    } catch (e) {
      print('🚨 Error en verificación de perfil: $e');
      return false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _verificacionPerfil,
      builder: (context, snapshot) {
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
                    'Configurando perfil...',
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
        
        if (snapshot.hasError || (snapshot.hasData && !snapshot.data!)) {
          return Scaffold(
            backgroundColor: Colors.red,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Error al configurar perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _verificacionPerfil = _verificarYCrearPerfil();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Perfil verificado/creado exitosamente
        return const PantallaPrincipal();
      },
    );
  }
}