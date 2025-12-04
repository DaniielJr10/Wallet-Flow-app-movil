import 'package:flutter/material.dart';

/// Modelo para representar una pregunta frecuente
class PreguntaFrecuente {
  final String id;
  final String pregunta;
  final String respuesta;
  final String categoria;
  final List<String> palabrasClave;
  final IconData icono;
  final Color colorIcono;

  const PreguntaFrecuente({
    required this.id,
    required this.pregunta,
    required this.respuesta,
    required this.categoria,
    required this.palabrasClave,
    required this.icono,
    required this.colorIcono,
  });
}

/// Categorías de preguntas frecuentes
enum CategoriaFAQ {
  cuentas('Cuentas y Saldos', Icons.account_balance_wallet, Color(0xFF3B82F6)),
  transacciones('Transacciones', Icons.swap_horiz, Color(0xFF10B981)),
  deudas('Deudas y Pagos', Icons.credit_card, Color(0xFFEF4444)),
  ahorros('Metas de Ahorro', Icons.savings, Color(0xFF8B5CF6)),
  seguridad('Seguridad', Icons.security, Color(0xFFF59E0B)),
  configuracion('Configuración', Icons.settings, Color(0xFF6B7280)),
  exportar('Reportes y Exportar', Icons.file_download, Color(0xFF06B6D4)),
  general('General', Icons.help_outline, Color(0xFF84CC16));

  const CategoriaFAQ(this.nombre, this.icono, this.color);
  
  final String nombre;
  final IconData icono;
  final Color color;
}

/// Constantes para la pantalla de FAQ
class FAQConstantes {
  static const Duration tiempoAnimacion = Duration(milliseconds: 600);
  static const Duration duracionBusqueda = Duration(milliseconds: 300);
  
  // Colores del tema
  static const Color colorPrimario = Color(0xFF10B981);
  static const Color colorFondo = Color(0xFFF8FAFC);
  static const Color colorTarjeta = Colors.white;
  static const Color colorTexto = Color(0xFF0F172A);
  static const Color colorTextoSecundario = Color(0xFF64748B);
  
  // Estilos de texto
  static const TextStyle estiloTitulo = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: colorTexto,
  );
  
  static const TextStyle estiloPregunta = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: colorTexto,
  );
  
  static const TextStyle estiloRespuesta = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: colorTextoSecundario,
  );
  
  static const TextStyle estiloCategoria = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: colorTextoSecundario,
  );
}