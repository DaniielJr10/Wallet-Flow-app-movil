import 'package:flutter/material.dart';

class UtilsIngresos {
  static const List<String> categorias = [
    'trabajo', 'negocio', 'freelance', 'inversiones', 
    'regalo', 'ventas', 'renta', 'bonificacion', 'otro'
  ];

  static const List<String> metodosPago = ['Efectivo', 'Transferencia'];

  static IconData getIconoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'trabajo': return Icons.work_rounded;
      case 'negocio': return Icons.business_rounded;
      case 'freelance': return Icons.laptop_rounded;
      case 'inversiones': return Icons.trending_up_rounded;
      case 'regalo': return Icons.card_giftcard_rounded;
      case 'ventas': return Icons.sell_rounded;
      case 'renta': return Icons.house_rounded;
      case 'bonificacion': return Icons.star_rounded;
      case 'otro': return Icons.attach_money_rounded;
      default: return Icons.attach_money_rounded;
    }
  }

  static String getNombreMes(int mes) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return meses[mes - 1];
  }
}