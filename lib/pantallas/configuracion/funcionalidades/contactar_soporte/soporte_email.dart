import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
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
      final userName = user?.displayName ?? 'Usuario de Wallet Flow';
      
      // Construir el cuerpo del correo
      final String cuerpoCorreo = SoporteConstantes.generarCuerpoCorreo(
        asunto: asunto,
        categoria: categoria,
        mensaje: mensaje,
        nombreUsuario: userName,
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
  static Map<String, String> obtenerInfoUsuario() {
    final user = FirebaseAuth.instance.currentUser;
    
    return {
      'nombre': user?.displayName?.isNotEmpty == true 
          ? user!.displayName! 
          : 'Usuario',
      'email': user?.email?.isNotEmpty == true 
          ? user!.email! 
          : 'correo@ejemplo.com',
      'iniciales': (user?.displayName?.isNotEmpty == true 
          ? user!.displayName! 
          : 'Usuario').trim()[0].toUpperCase(),
    };
  }
}