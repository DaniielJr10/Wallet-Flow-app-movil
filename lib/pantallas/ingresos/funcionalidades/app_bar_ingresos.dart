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
      automaticallyImplyLeading: false,
      leading: Semantics(
        label: 'Regresar',
        button: true,
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: UtilsIngresos.colorPrincipal,
          tooltip: 'Regresar',
          iconSize: 26,
          splashRadius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, color: UtilsIngresos.colorPrincipal, size: 28),
                SizedBox(width: 8),
                Text(
                  'INGRESOS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: UtilsIngresos.colorPrincipal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
            Text(
              'Administra y visualiza todos tus ingresos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
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