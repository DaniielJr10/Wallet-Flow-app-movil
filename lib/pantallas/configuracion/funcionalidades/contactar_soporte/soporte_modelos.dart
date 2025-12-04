import 'package:flutter/material.dart';

/// Modelo para las categorías de soporte
class Categoriasoporte {
  final String nombre;
  final IconData icono;
  final Color color;
  final String descripcion;

  const Categoriasoporte({
    required this.nombre,
    required this.icono,
    required this.color,
    required this.descripcion,
  });
}

/// Constantes para la pantalla de contactar soporte
class SoporteConstantes {
  static const String emailDestino = 'walletfloww@gmail.com';
  static const String asuntoPrefix = '[Soporte Wallet Flow]';
  static const Duration tiempoAnimacion = Duration(milliseconds: 800);
  static const int minimoCaracteresAsunto = 5;
  static const int minimoCaracteresMensaje = 20;
  
  static const List<Categoriasoporte> categorias = [
    Categoriasoporte(
      nombre: 'General',
      icono: Icons.help_outline,
      color: Color(0xFF6366F1),
      descripcion: 'Consultas generales sobre la aplicación',
    ),
    Categoriasoporte(
      nombre: 'Problema Técnico',
      icono: Icons.bug_report,
      color: Color(0xFFEF4444),
      descripcion: 'Errores o problemas de funcionamiento',
    ),
    Categoriasoporte(
      nombre: 'Cuenta',
      icono: Icons.account_circle,
      color: Color(0xFF10B981),
      descripcion: 'Problemas con tu cuenta de usuario',
    ),
    Categoriasoporte(
      nombre: 'Finanzas',
      icono: Icons.attach_money,
      color: Color(0xFFF59E0B),
      descripcion: 'Consultas sobre transacciones y finanzas',
    ),
    Categoriasoporte(
      nombre: 'Sugerencia',
      icono: Icons.lightbulb_outline,
      color: Color(0xFF8B5CF6),
      descripcion: 'Ideas para mejorar la aplicación',
    ),
    Categoriasoporte(
      nombre: 'Seguridad',
      icono: Icons.security,
      color: Color(0xFFDC2626),
      descripcion: 'Problemas de seguridad o privacidad',
    ),
  ];

  /// Obtiene una categoría por nombre
  static Categoriasoporte getCategoriaByNombre(String nombre) {
    return categorias.firstWhere(
      (categoria) => categoria.nombre == nombre,
      orElse: () => categorias[0],
    );
  }

  /// Genera el cuerpo del correo electrónico
  static String generarCuerpoCorreo({
    required String asunto,
    required String categoria,
    required String mensaje,
    required String nombreUsuario,
    required String emailUsuario,
  }) {
    return '''
Asunto: $asunto
Categoría: $categoria

Mensaje:
$mensaje

---
Información del usuario:
Nombre: $nombreUsuario
Email: $emailUsuario
Fecha: ${DateTime.now().toString()}
Dispositivo: Flutter App
''';
  }
}

/// Modelo para validaciones del formulario
class ValidacionFormulario {
  static String? validarAsunto(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, escribe un asunto';
    }
    if (value.trim().length < SoporteConstantes.minimoCaracteresAsunto) {
      return 'El asunto debe tener al menos ${SoporteConstantes.minimoCaracteresAsunto} caracteres';
    }
    return null;
  }

  static String? validarMensaje(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, describe tu consulta';
    }
    if (value.trim().length < SoporteConstantes.minimoCaracteresMensaje) {
      return 'Por favor, proporciona más detalles (mínimo ${SoporteConstantes.minimoCaracteresMensaje} caracteres)';
    }
    return null;
  }
}