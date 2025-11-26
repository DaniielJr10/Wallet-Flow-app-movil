/// CONFIGURACIÓN Y DATOS
/// Centraliza la lista estática de herramientas disponibles y sus rutas.
/// Aquí se definen los colores, iconos y destinos de navegación.
import 'package:flutter/material.dart';
import 'modelo_herramienta.dart';

// Importación de las sub-pantallas (Ajusta la ruta si es necesario)
import '../4elementos_herramientas/calculadora/calculadora.dart';
import '../4elementos_herramientas/calendario/calendario.dart';
import '../4elementos_herramientas/conversor_monedas/conversor_monedas.dart';
import '../4elementos_herramientas/notas/notas.dart';

class UtilsHerramientas {
  // Color principal del módulo
  static const Color colorPrincipal = Color(0xFF10B981);
  static const Color colorFondo = Color(0xFFF3FAFB);

  // Generador de la lista de herramientas
  static List<ToolInfo> obtenerHerramientas() {
    return [
      ToolInfo(
        title: 'Calculadora',
        description: 'Realiza cálculos rápidos y operaciones matemáticas básicas',
        icon: Icons.calculate_rounded,
        color: Colors.blue,
        badge: 'BÁSICA',
        tags: ['Operaciones básicas', 'Porcentajes'],
        destination: const CalculadoraPantalla(),
      ),
      ToolInfo(
        title: 'Calendario',
        description: 'Organiza fechas importantes y eventos financieros',
        icon: Icons.calendar_month_rounded,
        color: Colors.redAccent,
        badge: 'ORGANIZACIÓN',
        tags: ['Eventos', 'Recordatorios'],
        destination: const CalendarioScreen(),
      ),
      ToolInfo(
        title: 'Notas',
        description: 'Guarda ideas, recordatorios y apuntes importantes',
        icon: Icons.note_alt_rounded,
        color: Colors.orange,
        badge: 'PRODUCTIVIDAD',
        tags: ['Edición rápida', 'Auto-guardado'],
        destination: const NotasScreen(),
      ),
      ToolInfo(
        title: 'Conversor',
        description: 'Convierte entre diferentes divisas con tipos actualizados',
        icon: Icons.currency_exchange_rounded,
        color: Colors.purple,
        badge: 'FINANCIERA',
        tags: ['Múltiples divisas', 'Tiempo real'],
        destination: const ConversorMonedasScreen(),
      ),
    ];
  }
}