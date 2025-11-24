import 'package:flutter/material.dart';
import '../../ingresos.dart';
import '../../gastos.dart';
import '../../cuentas.dart';
import '../../deudas.dart';
import '../../ahorros.dart';
import '../../herramientas.dart';

void navegarASeccion(BuildContext context, int index, Function(int) setSelectedIndex) {
	switch (index) {
		case 1:
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaIngresos()),
			);
			break;
		case 2:
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaGastos()),
			);
			break;
		case 3:
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaCuentas()),
			);
			break;
		case 5:
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaDeudas()),
			);
			break;
		case 6:
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaAhorros()),
			);
			break;
		case 7:
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaHerramientas()),
			);
			break;
		default:
			setSelectedIndex(index);
	}
}
// Funciones de navegación entre secciones para PantallaPrincipal

