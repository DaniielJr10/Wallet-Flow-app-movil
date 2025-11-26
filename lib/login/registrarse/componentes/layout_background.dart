/// ESTRUCTURA VISUAL BASE
/// Contenedor que maneja el fondo verde suave, el SafeArea y el sistema de scroll
/// adaptativo que asegura que el formulario sea visible en cualquier pantalla.
import 'package:flutter/material.dart';
import 'utils_registro.dart';

class LayoutBackground extends StatelessWidget {
  final Widget child;

  const LayoutBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: UtilsRegistro.colorFondo,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: constraints.maxHeight > 700
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? size.width * 0.25 : 32,
                    vertical: 16,
                  ),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 450 : double.infinity,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}