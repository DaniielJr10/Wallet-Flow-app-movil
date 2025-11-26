/// HEADER DE NAVEGACIÓN
/// Barra superior minimalista y transparente que contiene solo el botón
/// de retroceso estilizado con el color del tema.
import 'package:flutter/material.dart';
import 'utils_herramientas.dart';

class AppBarHerramientas extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHerramientas({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: UtilsHerramientas.colorPrincipal),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}