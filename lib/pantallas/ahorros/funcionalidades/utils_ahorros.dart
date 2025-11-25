// 10. Utilidades y funciones auxiliares para la sección de ahorros
import 'package:flutter/material.dart';

class UtilsAhorros {
  static const Color colorPrincipal = Color(0xFF8570FA);

  static final List<Map<String, dynamic>> categorias = [
    {
      'valor': 'vacaciones',
      'nombre': 'Vacaciones',
      'icono': Icons.flight_takeoff_rounded,
      'color': colorPrincipal,
    },
    {
      'valor': 'casa',
      'nombre': 'Casa',
      'icono': Icons.home_rounded,
      'color': colorPrincipal,
    },
    {
      'valor': 'auto',
      'nombre': 'Auto',
      'icono': Icons.directions_car_rounded,
      'color': colorPrincipal,
    },
    {
      'valor': 'emergencia',
      'nombre': 'Emergencia',
      'icono': Icons.security_rounded,
      'color': colorPrincipal,
    },
    {
      'valor': 'educacion',
      'nombre': 'Educación',
      'icono': Icons.school_rounded,
      'color': colorPrincipal,
    },
    {
      'valor': 'inversion',
      'nombre': 'Inversión',
      'icono': Icons.trending_up_rounded,
      'color': colorPrincipal,
    },
    {
      'valor': 'salud',
      'nombre': 'Salud',
      'icono': Icons.health_and_safety_rounded,
      'color': colorPrincipal,
    },
    {
      'valor': 'otros',
      'nombre': 'Otros',
      'icono': Icons.more_horiz_rounded,
      'color': colorPrincipal,
    },
  ];

  static Map<String, dynamic> obtenerInfoCategoria(String valor) {
    return categorias.firstWhere(
      (cat) => cat['valor'] == valor,
      orElse: () => categorias.last,
    );
  }
}