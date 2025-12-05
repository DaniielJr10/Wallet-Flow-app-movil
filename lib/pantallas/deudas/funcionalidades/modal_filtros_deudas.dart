// Modal para seleccionar el modo de búsqueda de deudas
import 'package:flutter/material.dart';
import 'utils_deudas.dart';

/// Widget para mostrar el modal de filtros de búsqueda
class ModalFiltrosBusquedaDeudas {
  static void mostrar({
    required BuildContext context,
    required GlobalKey filterButtonKey,
    required String modoBusquedaActual,
    required Function(String) onModoCambiado,
  }) {
    final keyContext = filterButtonKey.currentContext;
    if (keyContext == null) return;
    
    final renderBox = keyContext.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Tap fuera del modal para cerrar
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Modal posicionado cerca del botón
            Positioned(
              top: offset.dy + size.height - 50,
              right: MediaQuery.of(context).size.width - offset.dx - size.width,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: UtilsDeudas.colorPrincipal.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        const Row(
                          children: [
                            Icon(Icons.filter_list, color: UtilsDeudas.colorPrincipal, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Modo de búsqueda',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: UtilsDeudas.colorPrincipal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Opción: Por categoría
                        _OpcionFiltro(
                          icon: Icons.category_outlined,
                          texto: 'Por categoría',
                          seleccionado: modoBusquedaActual == 'categoría',
                          onTap: () {
                            onModoCambiado('categoría');
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 12),
                        // Opción: Por mes
                        _OpcionFiltro(
                          icon: Icons.calendar_today_outlined,
                          texto: 'Por mes',
                          seleccionado: modoBusquedaActual == 'mes',
                          onTap: () {
                            onModoCambiado('mes');
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget para cada opción de filtro
class _OpcionFiltro extends StatelessWidget {
  final IconData icon;
  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;

  const _OpcionFiltro({
    required this.icon,
    required this.texto,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: seleccionado ? UtilsDeudas.colorPrincipal.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: seleccionado ? UtilsDeudas.colorPrincipal : Colors.grey[700],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
                  color: seleccionado ? UtilsDeudas.colorPrincipal : Colors.grey[800],
                ),
              ),
            ),
            if (seleccionado)
              const Icon(
                Icons.check_circle,
                color: UtilsDeudas.colorPrincipal,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
