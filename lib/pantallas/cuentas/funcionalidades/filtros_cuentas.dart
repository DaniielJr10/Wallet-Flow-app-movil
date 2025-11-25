/// BARRA DE HERRAMIENTAS
/// Agrupa el campo de texto para búsqueda y el botón de menú (Popup)
/// para ordenar la lista. Comunica los cambios al padre mediante callbacks.
import 'package:flutter/material.dart';

class BarraBusquedaYFiltros extends StatelessWidget {
  final TextEditingController controller;
  final String modoFiltro;
  final String ordenSaldo;
  final Function(String) onChanged;
  final Function() onClear;
  final Function(String value) onFilterSelected;

  const BarraBusquedaYFiltros({
    super.key,
    required this.controller,
    required this.modoFiltro,
    required this.ordenSaldo,
    required this.onChanged,
    required this.onClear,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
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
                  hintText: modoFiltro == 'buscar' ? 'Buscar por número de cuenta...' : 'Buscar cuenta...',
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
                            Icons.clear,
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
                      color: const Color(0xFF007bff).withOpacity(0.5),
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
              icon: const Icon(Icons.filter_alt_rounded, color: Color(0xFF007bff)),
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF007bff), width: 0.7),
              ),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  enabled: false,
                  padding: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.tune_rounded, color: Color(0xFF007bff), size: 18),
                      SizedBox(width: 8),
                      Text('Modo de búsqueda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF007bff))),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: 'ordenar_desc',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.trending_down_rounded, color: modoFiltro == 'ordenar' && ordenSaldo == 'desc' ? const Color(0xFF007bff) : Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      const Text('Mayor saldo', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      if (modoFiltro == 'ordenar' && ordenSaldo == 'desc') ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF007bff), size: 18),
                      ]
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'ordenar_asc',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up_rounded, color: modoFiltro == 'ordenar' && ordenSaldo == 'asc' ? const Color(0xFF007bff) : Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      const Text('Menor saldo', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      if (modoFiltro == 'ordenar' && ordenSaldo == 'asc') ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF007bff), size: 18),
                      ]
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'buscar',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: modoFiltro == 'buscar' ? const Color(0xFF007bff) : Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      const Text('Buscar por número de cuenta', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      if (modoFiltro == 'buscar') ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF007bff), size: 18),
                      ]
                    ],
                  ),
                ),
              ],
              onSelected: onFilterSelected,
            ),
          ),
        ],
      ),
    );
  }
}