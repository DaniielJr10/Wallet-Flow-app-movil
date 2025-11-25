import 'package:flutter/material.dart';

/// Widget para mostrar una tarjeta/lista de meta de ahorro.
class TarjetaAhorro extends StatelessWidget {
  final String id;
  final Map<String, dynamic> meta;
  final int index;
  final List<Map<String, dynamic>> categorias;
  final Function(String, Map<String, dynamic>) onTap;
  final Function(String, Map<String, dynamic>) onAccion;

  const TarjetaAhorro({
    super.key,
    required this.id,
    required this.meta,
    required this.index,
    required this.categorias,
    required this.onTap,
    required this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar tarjeta de meta aquí
    return Container();
  }
}
