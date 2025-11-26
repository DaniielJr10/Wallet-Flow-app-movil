/// BARRA DE NAVEGACIÓN INFERIOR
/// Controla las pestañas principales (Inicio, Perfil, Configuración).
/// Gestiona los colores y estados visuales de selección.
import 'package:flutter/material.dart';
import 'utils_principal.dart';

class BottomNavPrincipal extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavPrincipal({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Solo índices 0, 1 y 2 son válidos para el bottom nav
    final validIndex = currentIndex <= 2 ? currentIndex : 0;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: validIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      selectedFontSize: 13,
      unselectedFontSize: 12,
      elevation: 10,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined, color: validIndex == 0 ? UtilsPrincipal.navInicio : Colors.grey.shade400),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded, color: validIndex == 1 ? UtilsPrincipal.navPerfil : Colors.grey.shade400),
          label: 'Perfil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined, color: validIndex == 2 ? UtilsPrincipal.navConfig : Colors.grey.shade400),
          label: 'Configuración',
        ),
      ],
      selectedItemColor: _getItemColor(validIndex),
      unselectedItemColor: Colors.grey.shade400,
    );
  }

  Color _getItemColor(int index) {
    switch (index) {
      case 0: return UtilsPrincipal.navInicio;
      case 1: return UtilsPrincipal.navPerfil;
      case 2: return UtilsPrincipal.navConfig;
      default: return UtilsPrincipal.navInicio;
    }
  }
}