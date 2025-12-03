// 2. Título e icono morado para la sección de ahorros
import 'package:flutter/material.dart';
import 'utils_ahorros.dart';

class AppBarAhorros extends StatelessWidget implements PreferredSizeWidget {
  const AppBarAhorros({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
        color: UtilsAhorros.colorPrincipal,
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
                  Icons.savings_rounded,
                  color: UtilsAhorros.colorPrincipal,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'AHORROS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: UtilsAhorros.colorPrincipal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Gestiona y alcanza tus metas de ahorro',
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