// FiltrosGastos: Widget para búsqueda y selección de modo de visualización de gastos.
import 'package:flutter/material.dart';
import 'utils_gastos.dart';

class FiltrosGastos extends StatelessWidget {
  final TextEditingController controller;
  final String modoBusqueda;
  final Function(String) onChanged;
  final Function() onClear;
  final Function(String) onModeChanged;

  const FiltrosGastos({
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: modoBusqueda == 'categoría'
                    ? 'Buscar por categoría...'
                    : 'Buscar por mes (ej: noviembre)...',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: onClear,
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.red.shade300,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
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
              child: Icon(Icons.filter_alt_rounded, color: UtilsGastos.colorPrincipal, key: ValueKey(modoBusqueda)),
            ),
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: UtilsGastos.colorPrincipal, width: 0.7),
            ),
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, color: UtilsGastos.colorPrincipal, size: 18),
                    const SizedBox(width: 8),
                    Text('Modo de búsqueda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UtilsGastos.colorPrincipal)),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem(
                value: 'categoría',
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.category_rounded, color: modoBusqueda == 'categoría' ? UtilsGastos.colorPrincipal : Colors.grey, size: 20),
                    const SizedBox(width: 10),
                    const Text('Por categoría', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    if (modoBusqueda == 'categoría') ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle_rounded, color: UtilsGastos.colorPrincipal, size: 18),
                    ]
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'mes',
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: modoBusqueda == 'mes' ? UtilsGastos.colorPrincipal : Colors.grey, size: 20),
                    const SizedBox(width: 10),
                    const Text('Por mes', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    if (modoBusqueda == 'mes') ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle_rounded, color: UtilsGastos.colorPrincipal, size: 18),
                    ]
                  ],
                ),
              ),
            ],
            onSelected: onModeChanged,
          ),
        ),
      ],
    );
  }
}