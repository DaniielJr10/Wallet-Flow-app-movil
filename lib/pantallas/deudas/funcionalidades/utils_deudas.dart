// Utilidades, colores, iconos y helpers para la gestión de deudas.
import 'package:flutter/material.dart';

class UtilsDeudas {
  static const Color colorPrincipal = Color(0xFFF97316);
  static const Color colorSecundario = Color(0xFFEA580C);

  static Color obtenerColorEstado(Map<String, dynamic> deuda) {
    final estado = deuda['estado'];
    final fechaVencimiento = deuda['fechaVencimiento'] as DateTime?;

    if (estado == 'Vencida') {
      return Colors.red;
    } else if (estado == 'Pagada') {
      return const Color(0xFF10B981); // Verde
    } else {
      // Verificar si está próxima a vencer (menos de 3 días)
      if (fechaVencimiento != null) {
        final diasHastaVencimiento = fechaVencimiento.difference(DateTime.now()).inDays;
        if (diasHastaVencimiento >= 0 && diasHastaVencimiento <= 3) {
          return Colors.orange;
        }
      }
      return const Color(0xFF3B82F6); // Azul normal
    }
  }

  static IconData obtenerIconoTipoDeuda(String tipo) {
    switch (tipo) {
      case 'Tarjeta de Crédito':
        return Icons.credit_card;
      case 'Préstamo Personal':
        return Icons.person;
      case 'Préstamo Hipotecario':
        return Icons.home;
      case 'Préstamo Vehicular':
        return Icons.directions_car;
      case 'Préstamo Estudiantil':
        return Icons.school;
      case 'Línea de Crédito':
        return Icons.account_balance;
      case 'Factoring':
        return Icons.business;
      default:
        return Icons.receipt_long;
    }
  }

  static String formatearFecha(DateTime fecha) {
    final meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  static String formatearFechaVencimiento(DateTime fecha) {
    final diferencia = fecha.difference(DateTime.now()).inDays;
    
    if (diferencia < 0) {
      return 'Vencida hace ${(-diferencia)} días';
    } else if (diferencia == 0) {
      return 'Vence hoy';
    } else if (diferencia == 1) {
      return 'Vence mañana';
    } else if (diferencia <= 7) {
      return 'Vence en $diferencia días';
    } else {
      final meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
      return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
    }
  }
}