import 'package:flutter/material.dart';
import 'herramientass/calculadora.dart';
import 'herramientass/calendario.dart';
import 'herramientass/conversor_monedas.dart';
import 'herramientass/notas.dart';

/// Pantalla principal de Herramientas - rediseño visual tipo tarjeta grande
class PantallaHerramientas extends StatelessWidget {
	const PantallaHerramientas({super.key});

	@override
	Widget build(BuildContext context) {
		final List<_ToolInfo> tools = [
			_ToolInfo(
				title: 'Calculadora',
				description: 'Realiza cálculos rápidos y operaciones matemáticas básicas',
				icon: Icons.calculate_rounded,
				color: Colors.blue, // blue accent
				badge: 'BÁSICA',
				tags: ['Operaciones básicas', 'Porcentajes'],
				destination: const CalculadoraPantalla(),
			),
			_ToolInfo(
				title: 'Calendario',
				description: 'Organiza fechas importantes y eventos financieros',
				icon: Icons.calendar_month_rounded,
				color: Colors.redAccent,
				badge: 'ORGANIZACIÓN',
				tags: ['Eventos', 'Recordatorios'],
				destination: const CalendarioScreen(),
			),
			_ToolInfo(
				title: 'Notas',
				description: 'Guarda ideas, recordatorios y apuntes importantes',
				icon: Icons.note_alt_rounded,
				color: Colors.orange,
				badge: 'PRODUCTIVIDAD',
				tags: ['Edición rápida', 'Auto-guardado'],
				destination: const NotasScreen(),
			),
			_ToolInfo(
				title: 'Conversor de Monedas',
				description: 'Convierte entre diferentes divisas con tipos actualizados',
				icon: Icons.currency_exchange_rounded,
				color: Colors.purple,
				badge: 'FINANCIERA',
				tags: ['Múltiples divisas', 'Tiempo real'],
				destination: const ConversorMonedasScreen(),
			),
		];

		return Scaffold(
			backgroundColor: const Color(0xFFF3FAFB),
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				elevation: 0,
				toolbarHeight: 0,
			),
			body: SafeArea(
				child: SingleChildScrollView(
					padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							// Header
							_Header(),
							const SizedBox(height: 20),

							// Grid of big cards (2 columns)
							LayoutBuilder(builder: (context, constraints) {
								final isWide = constraints.maxWidth > 800;
								final crossAxisCount = isWide ? 2 : 1;
								return GridView.builder(
									shrinkWrap: true,
									physics: const NeverScrollableScrollPhysics(),
									itemCount: tools.length,
									gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
										crossAxisCount: crossAxisCount,
										mainAxisSpacing: 18,
										crossAxisSpacing: 18,
										// Give more vertical room on narrow screens to avoid content overflow
										childAspectRatio: isWide ? 3.6 : 1.6,
									),
									itemBuilder: (context, index) {
											final t = tools[index];
											return _ToolCard(info: t);
										},
								);
							}),
						],
					),
				),
			),
		);
	}
}

class _Header extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 10),
			child: LayoutBuilder(builder: (context, constraints) {
				final maxTextWidth = constraints.maxWidth * 0.74;
				return Row(
					mainAxisAlignment: MainAxisAlignment.center,
					crossAxisAlignment: CrossAxisAlignment.center,
					children: [
						// Icon to the left of the title (moved slightly upward)
						Transform.translate(
							// move the icon further up to align with the title
							offset: const Offset(0, -12),
							child: Container(
								width: 52,
								height: 52,
								decoration: BoxDecoration(
									color: const Color(0xFFE6F7F0),
									borderRadius: BorderRadius.circular(12),
								),
								child: const Icon(
									Icons.build_rounded,
									color: Color(0xFF10B981),
									size: 28,
								),
							),
						),
						const SizedBox(width: 6),
						ConstrainedBox(
							constraints: BoxConstraints(maxWidth: maxTextWidth),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: const [
									Text(
										'HERRAMIENTAS',
										style: TextStyle(
											color: Color(0xFF10B981),
											fontSize: 26,
											fontWeight: FontWeight.w700,
											letterSpacing: 1.0,
										),
									),
									SizedBox(height: 6),
									Text(
										'Accede a herramientas útiles para gestionar mejor tus finanzas',
										textAlign: TextAlign.start,
										style: TextStyle(fontSize: 13, color: Colors.black54),
									),
								],
							),
						),
					],
				);
			}),
		);
	}
}

class _ToolInfo {
	final String title;
	final String description;
	final IconData icon;
	final Color color;
	final String badge;
	final List<String> tags;
	final Widget destination;

	_ToolInfo({
		required this.title,
		required this.description,
		required this.icon,
		required this.color,
		required this.badge,
		required this.tags,
		required this.destination,
	});
}

class _ToolCard extends StatelessWidget {
	final _ToolInfo info;
	const _ToolCard({Key? key, required this.info}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return InkWell(
			borderRadius: BorderRadius.circular(14),
			onTap: () => Navigator.push(
				context,
				MaterialPageRoute(builder: (_) => info.destination),
			),
			child: Container(
				decoration: BoxDecoration(
					color: Colors.white,
					borderRadius: BorderRadius.circular(14),
					boxShadow: [
						BoxShadow(
							color: const Color(0xFF10B981).withOpacity(0.08),
							blurRadius: 18,
							offset: const Offset(0, 8),
						),
					],
					border: Border.all(color: Colors.transparent),
				),
				child: Column(
					children: [
												// top colored border (accent)
						Container(
							height: 6,
							decoration: BoxDecoration(
								color: const Color(0xFF10B981),
								borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
							),
						),
												Flexible(
														fit: FlexFit.loose,
														child: Padding(
								padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
								child: Row(
									children: [
										// Info (icon moved next to title)
										Expanded(
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Row(
														children: [
															// small leading icon next to title
															Container(
																width: 44,
																height: 44,
																decoration: BoxDecoration(
																	color: info.color.withOpacity(0.14),
																	borderRadius: BorderRadius.circular(10),
																),
																child: Icon(info.icon, color: info.color, size: 22),
															),
															const SizedBox(width: 12),
															Expanded(
																child: Text(
																	info.title,
																	style: const TextStyle(
																			fontSize: 18, fontWeight: FontWeight.w700),
																),
															),
															Container(
																padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
																decoration: BoxDecoration(
																	color: const Color(0xFFEFFCF3),
																	borderRadius: BorderRadius.circular(20),
																),
																child: Text(
																	info.badge,
																	style: const TextStyle(
																			color: Color(0xFF10B981),
																			fontSize: 11,
																			fontWeight: FontWeight.w700),
																),
															),
														],
													),
													const SizedBox(height: 6),
													Text(
														info.description,
														style: const TextStyle(color: Colors.black54, fontSize: 13),
														maxLines: 2,
														overflow: TextOverflow.ellipsis,
													),
													const SizedBox(height: 10),
													Wrap(
														spacing: 8,
														runSpacing: 6,
														children: info.tags
																.map((t) => Container(
																			padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
																			decoration: BoxDecoration(
																				color: const Color(0xFFEFFCF3),
																				borderRadius: BorderRadius.circular(16),
																			),
																			child: Text(
																				t,
																				style: const TextStyle(
																						color: Color(0xFF10B981), fontSize: 12),
																			),
																		))
																.toList(),
													),
												],
											),
										)
									],
								),
							),
						),
						// divider and action
						Container(
							padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
							decoration: const BoxDecoration(
								borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
							),
							child: Row(
								children: [
									Expanded(
										child: Text(
											'Abrir herramienta',
											style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600),
										),
									),
									Container(
										width: 36,
										height: 36,
										decoration: BoxDecoration(
											color: Colors.green.shade50,
											shape: BoxShape.circle,
										),
										child: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.green.shade700),
									)
								],
							),
						),
					],
				),
			),
		);
	}
}

// Nota: Si implementas las otras pantallas, estas ya están referenciadas en sus destinos.
