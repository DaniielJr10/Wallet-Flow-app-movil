/// GRILLA DE NOTAS
/// Muestra la lista de notas filtrada en un layout de cuadrícula responsiva.
/// Se adapta a 1, 2 o 3 columnas según el ancho de la pantalla.
import 'package:flutter/material.dart';
import 'tarjeta_nota.dart';

class GridNotas extends StatelessWidget {
  final List<Map<String, dynamic>> notasFiltradas;
  final Function(int index) onTapNota;
  final Function(int index) onDeleteNota;

  const GridNotas({
    super.key,
    required this.notasFiltradas,
    required this.onTapNota,
    required this.onDeleteNota,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cross = constraints.maxWidth > 1000 
          ? 3 
          : (constraints.maxWidth > 600 ? 2 : 1);
      
      return GridView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: 1.15,
        ),
        itemCount: notasFiltradas.length,
        itemBuilder: (context, i) {
          return TarjetaNota(
            note: notasFiltradas[i],
            onTap: () => onTapNota(i),
            onDelete: () => onDeleteNota(i),
          );
        },
      );
    });
  }
}