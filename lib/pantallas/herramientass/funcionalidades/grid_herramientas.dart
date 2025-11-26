/// CONSTRUCTOR DE CUADRÍCULA
/// Genera el GridView que contiene todas las tarjetas.
/// Es responsivo: usa 1 columna en móviles y 2 columnas en pantallas anchas (>800px).
import 'package:flutter/material.dart';
import 'utils_herramientas.dart';
import 'tarjeta_herramienta.dart';

class GridHerramientas extends StatelessWidget {
  const GridHerramientas({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = UtilsHerramientas.obtenerHerramientas();

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 800;
      final crossAxisCount = isWide ? 2 : 1;
      
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tools.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          // Ajusta la relación de aspecto según el ancho para evitar overflow
          childAspectRatio: isWide ? 3.6 : 1.6,
        ),
        itemBuilder: (context, index) {
          return TarjetaHerramienta(info: tools[index]);
        },
      );
    });
  }
}