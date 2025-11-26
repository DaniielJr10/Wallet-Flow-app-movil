/// BARRA DE HERRAMIENTAS
/// Contiene el campo de búsqueda de texto y el botón principal
/// para crear una "Nueva Nota".
import 'package:flutter/material.dart';
import 'utils_notas.dart';

class BarraBusquedaNotas extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onNewNote;

  const BarraBusquedaNotas({
    super.key,
    required this.onSearchChanged,
    required this.onNewNote,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.search, color: UtilsNotas.colorPrincipal),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar en mis notas...',
                      border: InputBorder.none,
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: onNewNote,
          icon: const Icon(Icons.add),
          label: const Text('Nueva Nota'),
          style: ElevatedButton.styleFrom(
            backgroundColor: UtilsNotas.colorPrincipal,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}