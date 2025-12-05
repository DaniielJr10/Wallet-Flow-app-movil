import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../firebase/servicios/UsuarioService/usuarios_servicio.dart';
import 'soporte_modelos.dart';
import 'soporte_dialogs.dart';

/// Widgets principales para la pantalla de contactar soporte
class SoporteWidgetsPrincipales {
  /// Obtiene información del usuario actual
  static Future<Map<String, String>> _obtenerInfoUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    final usuariosServicio = UsuariosServicio();
    
    String nombreCompleto = 'Usuario';
    
    try {
      // Intentar obtener nombre de Firebase Auth
      if (user?.displayName?.isNotEmpty == true) {
        nombreCompleto = user!.displayName!;
      } else {
        // Si no, buscar en Firestore
        final perfil = await usuariosServicio.obtenerPerfil();
        
        if (perfil != null && perfil.exists) {
          final datos = perfil.data();
          if (datos != null && datos['nombre'] != null) {
            nombreCompleto = datos['nombre'] as String;
          }
        }
      }
    } catch (e) {
      print('Error obteniendo nombre de usuario: $e');
    }
    
    String primerNombre = nombreCompleto.split(' ')[0];
    
    return {
      'nombre': primerNombre,
      'nombreCompleto': nombreCompleto,
      'email': user?.email?.isNotEmpty == true 
          ? user!.email! 
          : 'correo@ejemplo.com',
      'iniciales': primerNombre.trim()[0].toUpperCase(),
    };
  }

  /// Construye el header con información del usuario
  static Widget buildUserHeader() {
    return FutureBuilder<Map<String, String>>(
      future: _obtenerInfoUsuario(),
      builder: (context, snapshot) {
        // Valores por defecto mientras carga
        final userInfo = snapshot.data ?? {
          'nombre': 'Usuario',
          'email': 'correo@ejemplo.com',
          'iniciales': 'U',
        };
        
        final displayName = userInfo['nombre']!;
        final displayEmail = userInfo['email']!;
        final initials = userInfo['iniciales']!;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981),
                const Color(0xFF10B981).withOpacity(0.8),
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: Center(
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
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
                      'Cuéntanos cómo podemos ayudarte',
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye la información de contacto
  static Widget buildInfoContacto(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Información importante',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => SoporteDialogs.mostrarInfoContacto(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Ver más',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu mensaje se enviará a ${SoporteConstantes.emailDestino}. '
                  'Responderemos en un plazo de 24-48 horas.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el botón de envío
  static Widget buildBotonEnvio({
    required bool enviandoCorreo,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: enviandoCorreo ? null : onPressed,
        icon: enviandoCorreo
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.send_rounded),
        label: Text(
          enviandoCorreo ? 'Enviando...' : 'Enviar mensaje',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
    );
  }
}