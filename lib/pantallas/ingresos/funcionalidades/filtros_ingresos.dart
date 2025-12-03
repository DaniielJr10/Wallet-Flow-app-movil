/// BARRA DE BÚSQUEDA Y FILTROS
/// Gestiona la entrada de texto para búsquedas y el menú desplegable
/// para alternar entre búsqueda por "Categoría" o por "Mes".
import 'package:flutter/material.dart';
import 'utils_ingresos.dart';

class FiltrosIngresos extends StatelessWidget {
  final TextEditingController controller;
  final String modoBusqueda;
  final Function(String) onChanged;
  final Function() onClear;
  final Function(String) onModeChanged;

  const FiltrosIngresos({
    super.key,
    required this.controller,
    required this.modoBusqueda,
    required this.onChanged,
    required this.onClear,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: modoBusqueda == 'categoría' 
                    ? 'Buscar por categoría...' 
                    : 'Buscar por mes (ej: noviembre)...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6B7280)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: UtilsIngresos.colorPrincipal, width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF)),
                        onPressed: onClear,
                      )
                    : null,
              ),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: PopupMenuButton<String>(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(Icons.filter_alt_rounded, color: UtilsIngresos.colorPrincipal, key: ValueKey(modoBusqueda)),
            ),
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: UtilsIngresos.colorPrincipal, width: 0.7),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Row(
                  children: const [
                    Icon(Icons.tune_rounded, color: UtilsIngresos.colorPrincipal, size: 18),
                    SizedBox(width: 8),
                    Text('Modo de búsqueda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UtilsIngresos.colorPrincipal)),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              _buildFilterItem('categoría', 'Por categoría', Icons.category_rounded),
              _buildFilterItem('mes', 'Por mes', Icons.calendar_month_rounded),
            ],
            onSelected: onModeChanged,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildFilterItem(String value, String text, IconData icon) {
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: modoBusqueda == value ? UtilsIngresos.colorPrincipal : Colors.grey, size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          if (modoBusqueda == value) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle_rounded, color: UtilsIngresos.colorPrincipal, size: 18),
          ]
        ],
      ),
    );
  }
}