import 'package:flutter/material.dart';

class BarraInferior extends StatelessWidget {
	final int selectedIndex;
	final Function(int) onTap;
	const BarraInferior({
		Key? key,
		required this.selectedIndex,
		required this.onTap,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		final List<Color> itemColors = [
			Color(0xFF2563EB), // Inicio - azul
			Color(0xFFF59E42), // Perfil - naranja
			Colors.grey.shade700, // Configuración
		];
		return BottomNavigationBar(
			type: BottomNavigationBarType.fixed,
			currentIndex: selectedIndex <= 2 ? selectedIndex : 0,
			onTap: onTap,
			backgroundColor: Colors.white,
			selectedFontSize: 13,
			unselectedFontSize: 12,
			elevation: 10,
			showUnselectedLabels: true,
			items: [
				BottomNavigationBarItem(
					icon: Icon(Icons.dashboard_outlined, color: selectedIndex == 0 ? itemColors[0] : Colors.grey.shade400),
					label: 'Inicio',
				),
				BottomNavigationBarItem(
					icon: Icon(Icons.person_outline_rounded, color: selectedIndex == 1 ? itemColors[1] : Colors.grey.shade400),
					label: 'Perfil',
				),
				BottomNavigationBarItem(
					icon: Icon(Icons.settings_outlined, color: selectedIndex == 2 ? itemColors[2] : Colors.grey.shade400),
					label: 'Configuración',
				),
			],
			selectedItemColor: itemColors[selectedIndex <= 2 ? selectedIndex : 0],
			unselectedItemColor: Colors.grey.shade400,
		);
	}
}
// Widget y lógica de la barra inferior para PantallaPrincipal

