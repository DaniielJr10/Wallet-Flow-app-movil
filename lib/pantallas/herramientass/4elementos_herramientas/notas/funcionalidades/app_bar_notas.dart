/// HEADER DE NAVEGACIÓN
/// Barra superior simple y transparente con botón de retroceso.
import 'package:flutter/material.dart';
import 'utils_notas.dart';

class AppBarNotas extends StatelessWidget implements PreferredSizeWidget {
  const AppBarNotas({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: UtilsNotas.colorPrincipal),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}