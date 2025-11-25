import 'package:flutter/material.dart';

class FiltrosIngresos extends StatelessWidget {
  final String busqueda;
  final Function(String) onBusquedaChanged;
  final String modoBusqueda;
  final Function(String) onModoChanged;

  const FiltrosIngresos({
    super.key,
    required this.busqueda,
    required this.onBusquedaChanged,
    required this.modoBusqueda,
    required this.onModoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: modoBusqueda == 'categoría' 
                  ? 'Buscar por categoría...' 
                  : 'Buscar por mes (ej: noviembre)...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF27ae60), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: busqueda.isNotEmpty
                    ? IconButton(
                        key: const ValueKey('clear'),
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: () => onBusquedaChanged(''),
                      )
                    : null,
              ),
            ),
            onChanged: onBusquedaChanged,
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
              child: Icon(Icons.filter_alt_rounded, color: const Color(0xFF2ecc71), key: ValueKey(modoBusqueda)),
            ),
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF2ecc71), width: 0.7),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                enabled: false,
                padding: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, color: Color(0xFF2ecc71), size: 18),
                    SizedBox(width: 8),
                    Text('Modo de búsqueda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2ecc71))),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem(
                value: 'categoría',
                child: _buildFilterOption('Por categoría', Icons.category_rounded, modoBusqueda == 'categoría'),
              ),
              PopupMenuItem(
                value: 'mes',
                child: _buildFilterOption('Por mes', Icons.calendar_month_rounded, modoBusqueda == 'mes'),
              ),
            ],
            onSelected: onModoChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOption(String text, IconData icon, bool isSelected) {
    return Row(
      children: [
        Icon(icon, color: isSelected ? const Color(0xFF2ecc71) : Colors.grey, size: 20),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        if (isSelected) ...[
          const SizedBox(width: 8),
          const Icon(Icons.check_circle_rounded, color: Color(0xFF2ecc71), size: 18),
        ]
      ],
    );
  }
}