/// HEADER DE NAVEGACIÓN
/// Barra superior transparente con el botón de retorno estilizado.
import 'package:flutter/material.dart';
import 'utils_conversor.dart';

class AppBarConversor extends StatelessWidget implements PreferredSizeWidget {
  const AppBarConversor({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: UtilsConversor.colorPrincipal),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}