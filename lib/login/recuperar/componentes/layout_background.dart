/// ESTRUCTURA VISUAL BASE
/// Define el contenedor principal con el color de fondo, el SafeArea
/// y la lógica de scroll responsivo para tablets y móviles.
import 'package:flutter/material.dart';
import 'utils_recuperar.dart';

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
      color: UtilsRecuperar.colorFondo,
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
                    vertical: 80,
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