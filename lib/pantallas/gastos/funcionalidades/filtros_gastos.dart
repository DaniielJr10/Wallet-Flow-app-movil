import 'package:flutter/material.dart';

/// Widget para la barra de búsqueda y filtros de gastos.
class FiltrosGastosBar extends StatelessWidget {
  final TextEditingController busquedaController;
  final String modoBusqueda;
  final Function(String) onModoBusquedaChanged;
  final Function(String) onBusquedaChanged;

  const FiltrosGastosBar({
    super.key,
    required this.busquedaController,
    required this.modoBusqueda,
    required this.onModoBusquedaChanged,
    required this.onBusquedaChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar barra de búsqueda y filtros aquí
    return Container();
  }
}
