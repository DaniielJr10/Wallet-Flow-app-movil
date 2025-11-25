import 'package:flutter/material.dart';

/// Widget para la barra de búsqueda y filtros de deudas.
class FiltrosDeudasBar extends StatelessWidget {
  final TextEditingController busquedaController;
  final String filtroSeleccionado;
  final String ordenSeleccionado;
  final Function(String) onFiltroChanged;
  final Function(String) onOrdenChanged;
  final Function(String) onBusquedaChanged;

  const FiltrosDeudasBar({
    super.key,
    required this.busquedaController,
    required this.filtroSeleccionado,
    required this.ordenSeleccionado,
    required this.onFiltroChanged,
    required this.onOrdenChanged,
    required this.onBusquedaChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar barra de búsqueda y filtros aquí
    return Container();
  }
}
