/// COMPONENTE VISUAL
/// Contiene únicamente el diseño del título superior, el icono y
/// el subtítulo de la pantalla. Se separó para limpiar el archivo principal.
import 'package:flutter/material.dart';

class AppBarCuentas extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCuentas({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 120,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF007bff)),
        onPressed: () => Navigator.pop(context),
      ),
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
                  Icons.credit_card,
                  color: Color(0xFF007bff),
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'CUENTAS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007bff),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Administra y visualiza todas tus cuentas bancarias',
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