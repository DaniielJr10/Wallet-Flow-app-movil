import '../../perfil/perfil.dart';
import '../../configuracion/configuracion.dart';
import 'package:flutter/material.dart';
import '../../ingresos/ingresos.dart';
import '../../gastos/gastos.dart';
import '../../cuentas/cuentas.dart';
import '../../deudas/deudas.dart';
import '../../ahorros/ahorros.dart';
import '../../herramientass/calculadora.dart';
import '../../perfil/perfil.dart';
import '../../configuracion/configuracion.dart';

void navegarASeccion(BuildContext context, int index, Function(int) setSelectedIndex) {
		// Barra inferior: 0-Inicio, 1-Perfil, 2-Configuración
		if (index == 0) {
			setSelectedIndex(index);
		} else if (index == 1) {
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaPerfil()),
			);
		} else if (index == 2) {
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaConfiguracion()),
			);
		}
		// Tarjetas del resumen financiero con nuevos índices
		else if (index == 10) {
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaIngresos()),
			);
		} else if (index == 11) {
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaGastos()),
			);
		} else if (index == 12) {
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaCuentas()),
			);
		} else if (index == 13) {
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaDeudas()),
			);
		} else if (index == 14) {
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const PantallaAhorros()),
			);
		} else if (index == 15) {
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => const CalculadoraPantalla()),
			);
		} else {
			setSelectedIndex(index);
		}
}
// Funciones de navegación entre secciones para PantallaPrincipal

