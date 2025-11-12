import 'package:flutter/material.dart';
import 'herramientass/calculadora.dart';
import 'herramientass/calendario.dart';
import 'herramientass/conversor_monedas.dart';
import 'herramientass/notas.dart';

/// Pantalla principal de Herramientas
/// Muestra 4 tarjetas para acceder a utilidades: Calculadora, Calendario, Conversor de Monedas y Notas.
class PantallaHerramientas extends StatelessWidget {
	const PantallaHerramientas({super.key});

	@override
	Widget build(BuildContext context) {
		// Lista de herramientas con su información y navegación
		final List<_HerramientaInfo> herramientas = [
			_HerramientaInfo(
				nombre: 'Calculadora',
				icono: Icons.calculate_rounded,
				color: Colors.blueAccent,
				destino: const CalculadoraPantalla(), // Calculadora profesional
			),
			_HerramientaInfo(
				nombre: 'Calendario',
				icono: Icons.calendar_month_rounded,
				color: Colors.deepPurple,
				destino: const CalendarioScreen(),
			),
			_HerramientaInfo(
				nombre: 'Conversor',
				icono: Icons.currency_exchange_rounded,
				color: Colors.teal,
				destino: const ConversorMonedasScreen(),
			),
			_HerramientaInfo(
				nombre: 'Notas',
				icono: Icons.note_alt_rounded,
				color: Colors.orange,
				destino: const NotasScreen(),
			),
		];

		return Scaffold(
			appBar: AppBar(
				title: const Text('Herramientas'),
				centerTitle: true,
				backgroundColor: const Color(0xFF10B981),
				elevation: 2,
			),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: GridView.builder(
					itemCount: herramientas.length,
					gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
						crossAxisCount: 2,
						crossAxisSpacing: 20,
						mainAxisSpacing: 20,
						childAspectRatio: 0.95,
					),
					itemBuilder: (context, index) {
						final herramienta = herramientas[index];
						return _TarjetaHerramienta(herramienta: herramienta);
					},
				),
			),
		);
	}
}

/// Modelo para la información de cada herramienta
class _HerramientaInfo {
	final String nombre;
	final IconData icono;
	final Color color;
	final Widget destino;
	const _HerramientaInfo({
		required this.nombre,
		required this.icono,
		required this.color,
		required this.destino,
	});
}

/// Widget de tarjeta individual para cada herramienta
class _TarjetaHerramienta extends StatelessWidget {
	final _HerramientaInfo herramienta;
	const _TarjetaHerramienta({required this.herramienta});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			borderRadius: BorderRadius.circular(20),
			onTap: () {
				// Navega a la pantalla de la herramienta seleccionada
				Navigator.push(
					context,
					MaterialPageRoute(builder: (_) => herramienta.destino),
				);
			},
			child: Ink(
				decoration: BoxDecoration(
					color: herramienta.color.withOpacity(0.12),
					borderRadius: BorderRadius.circular(20),
					boxShadow: [
						BoxShadow(
							color: herramienta.color.withOpacity(0.10),
							blurRadius: 8,
							offset: const Offset(0, 4),
						),
					],
				),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						CircleAvatar(
							backgroundColor: herramienta.color.withOpacity(0.18),
							radius: 32,
							child: Icon(
								herramienta.icono,
								color: herramienta.color,
								size: 38,
							),
						),
						const SizedBox(height: 18),
						Text(
							herramienta.nombre,
											style: TextStyle(
												fontSize: 18,
												fontWeight: FontWeight.w600,
												color: herramienta.color.withOpacity(0.85), // Color más oscuro
												letterSpacing: 0.5,
											),
						),
					],
				),
			),
		);
	}
}

// ===================
// Si implementas las otras herramientas, elimina los Scaffold temporales y usa las pantallas reales.
