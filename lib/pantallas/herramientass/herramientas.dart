/// ORQUESTADOR PRINCIPAL (HERRAMIENTAS)
/// Pantalla contenedora que ensambla el AppBar, el Header y la Grid de herramientas.
/// Mantiene el fondo y el scroll principal.
import 'package:flutter/material.dart';

// Importaciones modularizadas
import 'funcionalidades/app_bar_herramientas.dart';
import 'funcionalidades/header_herramientas.dart';
import 'funcionalidades/grid_herramientas.dart';
import 'funcionalidades/utils_herramientas.dart';

class PantallaHerramientas extends StatelessWidget {
  const PantallaHerramientas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtilsHerramientas.colorFondo,
      appBar: const AppBarHerramientas(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              HeaderHerramientas(),
              SizedBox(height: 20),
              GridHerramientas(),
            ],
          ),
        ),
      ),
    );
  }
}