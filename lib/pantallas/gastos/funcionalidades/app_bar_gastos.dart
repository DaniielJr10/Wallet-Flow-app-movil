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
      title: const Text(
        'Gastos',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F2937),
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