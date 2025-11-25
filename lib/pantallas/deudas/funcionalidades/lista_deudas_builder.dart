// Construcción dinámica de la lista visual de deudas.
import 'package:flutter/material.dart';
import 'tarjeta_deuda.dart';
import 'estados_deudas.dart';

class ListaDeudasBuilder extends StatelessWidget {
  final List<Map<String, dynamic>> deudas;
  final Function(Map<String, dynamic>) onTapDeuda;
  final String filtroSeleccionado;

  const ListaDeudasBuilder({
    super.key,
    required this.deudas,
    required this.onTapDeuda,
    required this.filtroSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    if (deudas.isEmpty) {
      return EstadoListaVacia(filtroSeleccionado: filtroSeleccionado);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: deudas.length,
      itemBuilder: (context, index) {
        final deuda = deudas[index];
        return TarjetaDeuda(
          deuda: deuda,
          index: index,
          onTap: () => onTapDeuda(deuda),
        );
      },
    );
  }
}