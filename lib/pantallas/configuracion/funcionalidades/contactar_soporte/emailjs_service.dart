import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../firebase/servicios/UsuarioService/usuarios_servicio.dart';
import 'soporte_dialogs.dart';
import 'emailjs_config.dart';

/// Servicio para enviar emails directamente usando EmailJS (REST API)
class EmailJSService {
  static Future<void> enviarCorreoDirecto({
    required BuildContext context,
    required String asunto,
    required String categoria,
    required String mensaje,
    required VoidCallback onExito,
    required VoidCallback onError,
  }) async {
    try {
      // Validación básica
      if (!EmailJSConfig.isConfigured) {
        SoporteDialogs.mostrarError(
          context,
          'EmailJS no está configurado. Verifica claves en emailjs_config.dart',
        );
        onError();
        return;
      }

      // Información de usuario
      final user = FirebaseAuth.instance.currentUser;
      final usuariosServicio = UsuariosServicio();
      String nombreCompleto = (user?.displayName ?? '').trim();
      try {
        if (nombreCompleto.isEmpty) {
          final perfil = await usuariosServicio.obtenerPerfil();
          if (perfil != null && perfil.exists) {
            final datos = perfil.data();
            final n = datos?['nombre'] as String?;
            if (n != null && n.trim().isNotEmpty) nombreCompleto = n;
          }
        }
      } catch (_) {}
      final userEmail = user?.email ?? 'sin-correo@walletflow.app';
      if (nombreCompleto.isEmpty) {
        // Fallback: usa la parte local del email como nombre
        final local = userEmail.split('@').first;
        nombreCompleto = local.isNotEmpty ? local : 'Usuario';
      }

      // Formatear tiempo (DD/MM/YYYY HH:mm) para lectura más clara
      final now = DateTime.now();
      final timeStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // Parámetros de plantilla (coinciden con tu plantilla)
      final Map<String, String> templateParams = {
        // Opcional: prefijo de asunto para identificar origen
        'subject': '[WalletFlow] Soporte: $asunto — $nombreCompleto',
        'name': nombreCompleto,
        'time': timeStr,
        'message': mensaje,
        'email': userEmail,
        // opcional: si quieres mostrar categoría en la plantilla añade {{category}}
        'category': categoria,
      };

      // Enviar usando REST API
      final uri = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      final payload = {
        'service_id': EmailJSConfig.serviceId,
        'template_id': EmailJSConfig.templateId,
        'user_id': EmailJSConfig.publicKey,
        'template_params': templateParams,
      };

      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (resp.statusCode == 200) {
        if (context.mounted) {
          SoporteDialogs.mostrarExito(context);
        }
        onExito();
      } else {
        if (context.mounted) {
          SoporteDialogs.mostrarError(
            context,
            'Error EmailJS ${resp.statusCode}: ${resp.body}',
          );
        }
        onError();
      }
    } catch (e) {
      if (context.mounted) {
        SoporteDialogs.mostrarError(
          context,
          'Error al enviar el mensaje: ${e.toString()}',
        );
      }
      onError();
    }
  }
  /// Verifica si EmailJS está configurado y funcionando
  static Future<bool> verificarConfiguracion() async {
    try {
      if (!EmailJSConfig.isConfigured) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
// Envío solo vía EmailJS REST; fallback eliminado
