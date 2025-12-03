// AppBarGastos: AppBar personalizada para la sección de gastos, con título e icono principal.
import 'package:flutter/material.dart';
import 'utils_gastos.dart';

class AppBarGastos extends StatelessWidget implements PreferredSizeWidget {
  const AppBarGastos({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_rounded, color: UtilsGastos.colorPrincipal, size: 28),
                const SizedBox(width: 8),
                Text(
                  'GASTOS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: UtilsGastos.colorPrincipal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Administra y visualiza todos tus gastos',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
        color: UtilsGastos.colorPrincipal,
        tooltip: 'Regresar',
        iconSize: 26,
        splashRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}