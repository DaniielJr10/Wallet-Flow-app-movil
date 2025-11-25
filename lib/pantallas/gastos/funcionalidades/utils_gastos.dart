// UtilsGastos: Utilidades, colores, iconos y listas para la gestión de gastos.
import 'package:flutter/material.dart';

class UtilsGastos {
  static final Color colorPrincipal = Colors.red.shade600;
  static final Color colorSecundario = Colors.red.shade700;

  static const List<String> categorias = [
    'alimentación',
    'transporte',
    'entretenimiento',
    'salud',
    'educación',
    'servicios',
    'compras',
    'viajes',
    'otro'
  ];

  static const List<String> metodosPago = [
    'efectivo',
    'transferencia',
  ];

  static IconData obtenerIconoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'alimentación':
        return Icons.restaurant_rounded;
      case 'transporte':
        return Icons.directions_car_rounded;
      case 'entretenimiento':
        return Icons.movie_rounded;
      case 'salud':
        return Icons.local_hospital_rounded;
      case 'educación':
        return Icons.school_rounded;
      case 'servicios':
        return Icons.build_rounded;
      case 'compras':
        return Icons.shopping_bag_rounded;
      case 'viajes':
        return Icons.flight_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  static String capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }
  
  static String getNombreMes(int mes) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return meses[mes - 1];
  }
}