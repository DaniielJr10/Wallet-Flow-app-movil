/// HEADER DE LA PANTALLA
/// Barra superior transparente con título estilizado y botón de retorno.
/// Mantiene el estilo visual consistente con el resto de la aplicación.
import 'package:flutter/material.dart';
import 'utils_ingresos.dart';

class AppBarIngresos extends StatelessWidget implements PreferredSizeWidget {
  const AppBarIngresos({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: UtilsIngresos.colorSecundario),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'INGRESOS',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: UtilsIngresos.colorSecundario,
          letterSpacing: 2.2,
          fontFamily: 'Montserrat',
          height: 1.1,
          shadows: [
            Shadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}