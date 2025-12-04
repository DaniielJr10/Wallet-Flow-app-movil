import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../firebase/servicios/UsuarioService/usuarios_servicio.dart';
import 'soporte_modelos.dart';
import 'soporte_dialogs.dart';

/// Servicio para manejar el envío de correos electrónicos de soporte
class SoporteEmailService {
  /// Envía un correo electrónico usando la aplicación de correo del dispositivo
  static Future<void> enviarCorreo({
    required BuildContext context,
    required String asunto,
    required String categoria,
    required String mensaje,
    required VoidCallback onExito,
    required VoidCallback onError,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email ?? 'usuario@ejemplo.com';
      
      // Obtener información del usuario incluyendo nombre desde Firestore
      final userInfo = await obtenerInfoUsuario();
      final userName = userInfo['nombreCompleto'] ?? 'Usuario de Wallet Flow';
      
      // Construir el cuerpo del correo
      final String cuerpoCorreo = SoporteConstantes.generarCuerpoCorreo(
        asunto: asunto,
        categoria: categoria,
        mensaje: mensaje,
        nombreUsuario: userName, // Usar nombre completo para el correo
        emailUsuario: userEmail,
      );

      // Crear la URL del mailto
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: SoporteConstantes.emailDestino,
        queryParameters: {
          'subject': '${SoporteConstantes.asuntoPrefix} $asunto',
          'body': cuerpoCorreo,
        },
      );

      // Intentar abrir la aplicación de correo
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        
        if (context.mounted) {
          SoporteDialogs.mostrarExito(context);
          onExito();
        }
      } else {
        if (context.mounted) {
          SoporteDialogs.mostrarError(
            context,
            'No se pudo abrir la aplicación de correo. \\n\\n'
            'Por favor, envía tu consulta manualmente a: ${SoporteConstantes.emailDestino}',
          );
          onError();
        }
      }
    } catch (e) {
      if (context.mounted) {
        SoporteDialogs.mostrarError(context, 'Error al enviar el correo: $e');
        onError();
      }
    }
  }

  /// Valida si el dispositivo puede enviar correos
  static Future<bool> puedeEnviarCorreo() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: SoporteConstantes.emailDestino,
    );
    
    try {
      return await canLaunchUrl(emailUri);
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la información del usuario actual
  static Future<Map<String, String>> obtenerInfoUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    final usuariosServicio = UsuariosServicio();
    
    // Obtener solo el primer nombre como en la pantalla principal
    String nombreCompleto = 'Usuario';
    
    try {
      // 1. Intentar obtener nombre de Firebase Auth (Google, etc)
      if (user?.displayName?.isNotEmpty == true) {
        nombreCompleto = user!.displayName!;
      } else {
        // 2. Si no, buscar en Firestore usando el servicio
        final perfil = await usuariosServicio.obtenerPerfil();
        
        if (perfil != null && perfil.exists) {
          final datos = perfil.data();
          if (datos != null && datos['nombre'] != null) {
            nombreCompleto = datos['nombre'] as String;
          }
        }
      }
    } catch (e) {
      // Mantener valor por defecto en caso de error
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
}