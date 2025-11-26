/// UTILIDADES DE PERFIL
/// Centraliza constantes de diseño (colores), listas de datos estáticos (categorías)
/// y funciones auxiliares de formateo (moneda, fecha) para mantener la consistencia.
import 'package:flutter/material.dart';

class UtilsPerfil {
  // Colores
  static const Color colorFondo = Color(0xFFF8FAFC);
  static const Color colorHeaderInicio = Color(0xFF1E293B);
  static const Color colorHeaderFin = Color(0xFF334155);
  static const Color colorPrincipal = Color(0xFF10B981);
  static const Color colorTexto = Color(0xFF1F2937);

  // Listas
  static const List<String> categorias = [
    'General',
    'Alimentación',
    'Transporte',
    'Entretenimiento',
    'Educación',
    'Salud',
    'Compras',
    'Servicios',
  ];

  // Formateadores
  static String formatearMoneda(double valor) {
    return '\$${valor.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  static String formatearFecha(dynamic fecha) {
    if (fecha == null) return 'No disponible';
    // Si viene de Firebase Timestamp, convertirlo antes de llamar a esta función o manejarlo aquí
    // Asumimos que llega DateTime o String compatible
    if (fecha is! DateTime) return 'Fecha inválida';
    
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}