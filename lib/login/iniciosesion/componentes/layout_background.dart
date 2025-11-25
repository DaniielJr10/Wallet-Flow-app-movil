// Fondo, Scroll y SafeArea para la pantalla de inicio de sesión
import 'package:flutter/material.dart';
import 'utils_login.dart';

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
      color: UtilsLogin.colorFondo,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? size.width * 0.25 : 32,
              vertical: 48,
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
      ),
    );
  }
}