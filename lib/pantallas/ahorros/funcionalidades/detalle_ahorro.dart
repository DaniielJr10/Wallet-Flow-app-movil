import 'package:flutter/material.dart';

/// Widget para mostrar el detalle de una meta de ahorro en un modal.
class DetalleAhorroModal extends StatelessWidget {
  final String metaId;
  final Map<String, dynamic> meta;
  final List<Map<String, dynamic>> categorias;
  final Function(String, Map<String, dynamic>) onEditar;
  final Function(String, String) onEliminar;

  const DetalleAhorroModal({
    super.key,
    required this.metaId,
    required this.meta,
    required this.categorias,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar el modal de detalles aquí
    return Container();
  }
}
