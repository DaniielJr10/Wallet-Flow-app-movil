// Barra principal para la sección de deudas, estilo similar a la de ahorros.
import 'package:flutter/material.dart';
import 'utils_deudas.dart';

class AppBarDeudas extends StatelessWidget implements PreferredSizeWidget {
  const AppBarDeudas({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
        color: UtilsDeudas.colorPrincipal,
        tooltip: 'Regresar',
        iconSize: 26,
        splashRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      toolbarHeight: 120,
      title: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.receipt,
                  color: UtilsDeudas.colorPrincipal,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'DEUDAS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: UtilsDeudas.colorPrincipal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Gestiona tus deudas y pagos pendientes',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}