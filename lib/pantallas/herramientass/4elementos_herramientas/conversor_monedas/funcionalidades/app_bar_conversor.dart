/// HEADER DE NAVEGACIÓN
/// Barra superior transparente con el botón de retorno estilizado.
import 'package:flutter/material.dart';
import 'utils_conversor.dart';

class AppBarConversor extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onRefresh;

  const AppBarConversor({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: UtilsConversor.colorPrincipal),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      actions: [
        if (onRefresh != null)
          IconButton(
            tooltip: 'Actualizar tasas',
            icon: const Icon(Icons.refresh, color: UtilsConversor.colorPrincipal),
            onPressed: onRefresh,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}