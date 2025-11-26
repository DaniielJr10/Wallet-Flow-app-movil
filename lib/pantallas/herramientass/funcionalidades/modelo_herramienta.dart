/// MODELO DE DATOS
/// Define la estructura de información que requiere cada herramienta
/// para ser renderizada en el menú (título, icono, destino, etiquetas, etc.).
import 'package:flutter/material.dart';

class ToolInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String badge;
  final List<String> tags;
  final Widget destination;

  ToolInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.badge,
    required this.tags,
    required this.destination,
  });
}