// Header naranja con SliverAppBar personalizado para la sección de deudas.
import 'package:flutter/material.dart';
import 'utils_deudas.dart';

class AppBarDeudas extends StatelessWidget {
  const AppBarDeudas({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 96,
      floating: false,
      pinned: true,
      backgroundColor: UtilsDeudas.colorPrincipal,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Gestión de Deudas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                UtilsDeudas.colorPrincipal,
                UtilsDeudas.colorSecundario,
              ],
            ),
          ),
        ),
      ),
    );
  }
}