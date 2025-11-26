/// UTILIDADES DE REGISTRO
/// Centraliza los colores, estilos y, lo más importante, la lógica de validación
/// compleja (regex de email, lista de dominios permitidos, seguridad de contraseña).
import 'package:flutter/material.dart';

class UtilsRegistro {
  // Colores
  static const Color colorFondo = Color(0xFFE8F5E8);
  static const Color colorPrincipal = Color(0xFF10B981);
  static const Color colorSecundario = Color(0xFF059669);
  static const Color colorTexto = Color(0xFF065F46);
  static const Color colorError = Color(0xFFEF4444);

  // Validadores
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nombre completo';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    
    // Validación de dominios permitidos
    final domain = value.toLowerCase().split('@')[1];
    final dominiosValidos = [
      'gmail.com', 'hotmail.com', 'outlook.com', 'yahoo.com', 'yahoo.es',
      'icloud.com', 'live.com', 'msn.com', 'protonmail.com', 'zoho.com',
      'aol.com', 'mail.com', 'yandex.com', 'tutanota.com', 'fastmail.com',
      'empresa.com', 'company.com', 'corp.com',
      'soy.sena.edu.co', 'edu.co', 'edu', 'ac.uk', 'edu.mx', 'edu.ar',
    ];
    
    if (!dominiosValidos.contains(domain)) {
      return 'Por favor usa un correo de un proveedor conocido\n(Gmail, Hotmail, Yahoo, etc.)';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Debe contener mayúscula, minúscula y número';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String passwordOriginal) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    if (value != passwordOriginal) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}