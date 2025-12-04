// Barra de búsqueda y botón de filtros para filtrar y buscar deudas.
import 'package:flutter/material.dart';
import 'utils_deudas.dart';

class FiltrosYOrdenDeudas extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onNuevaDeudaPressed;
  final GlobalKey filterButtonKey;
  final String modoBusqueda;

  const FiltrosYOrdenDeudas({
    super.key,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.onNuevaDeudaPressed,
    required this.filterButtonKey,
    required this.modoBusqueda,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: onSearchChanged,
                        decoration: InputDecoration(
                          hintText: modoBusqueda == 'categoría' 
                              ? 'Buscar por categoría...' 
                              : 'Buscar por mes (ej: enero 2024)...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            Container(
              key: filterButtonKey,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onFilterPressed,
                icon: const Icon(Icons.filter_alt_rounded, color: UtilsDeudas.colorPrincipal, size: 20),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Historial de Deudas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            ElevatedButton.icon(
              onPressed: onNuevaDeudaPressed,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Nueva deuda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UtilsDeudas.colorPrincipal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}