// 4. Búsqueda y filtros para las metas de ahorro
import 'package:flutter/material.dart';
import 'utils_ahorros.dart';

class BarraBusquedaAhorros extends StatelessWidget {
  final TextEditingController controller;
  final String modoFiltro;
  final Function(String) onChanged;
  final Function() onClear;
  final Function(String) onFilterSelected;

  const BarraBusquedaAhorros({
    super.key,
    required this.controller,
    required this.modoFiltro,
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
                  hintText: 'Buscar por nombre de meta...',
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
                      color: UtilsAhorros.colorPrincipal.withOpacity(0.5),
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
              icon: const Icon(Icons.filter_alt_rounded, color: UtilsAhorros.colorPrincipal),
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: UtilsAhorros.colorPrincipal, width: 0.7),
              ),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  enabled: false,
                  padding: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.tune_rounded, color: UtilsAhorros.colorPrincipal, size: 18),
                      SizedBox(width: 8),
                      Text('Filtros de metas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UtilsAhorros.colorPrincipal)),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                _crearItemFiltro('todas', 'Todas las metas', Icons.list_rounded),
                _crearItemFiltro('activas', 'Metas activas', Icons.play_circle_outline_rounded),
                _crearItemFiltro('completadas', 'Metas completadas', Icons.check_circle_rounded),
              ],
              onSelected: onFilterSelected,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _crearItemFiltro(String valor, String texto, IconData icono) {
    return PopupMenuItem(
      value: valor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icono, color: modoFiltro == valor ? UtilsAhorros.colorPrincipal : Colors.grey, size: 20),
          const SizedBox(width: 10),
          Text(texto, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          if (modoFiltro == valor) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle_rounded, color: UtilsAhorros.colorPrincipal, size: 18),
          ]
        ],
      ),
    );
  }
}