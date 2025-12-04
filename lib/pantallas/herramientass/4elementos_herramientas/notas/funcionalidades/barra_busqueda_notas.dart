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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: UtilsNotas.colorBorde, width: 2),
              boxShadow: [
                BoxShadow(
                  color: UtilsNotas.colorPrincipal.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: UtilsNotas.colorPrincipal, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar en mis notas...',
                      hintStyle: TextStyle(color: UtilsNotas.colorTextoGris.withOpacity(0.7)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: onSearchChanged,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: onNewNote,
          style: ElevatedButton.styleFrom(
            backgroundColor: UtilsNotas.colorPrincipal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            shadowColor: UtilsNotas.colorPrincipal.withOpacity(0.4),
          ),
          child: Row(
            children: const [
              Icon(Icons.add_rounded, size: 22),
              SizedBox(width: 8),
              Text(
                'Nueva Nota',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}