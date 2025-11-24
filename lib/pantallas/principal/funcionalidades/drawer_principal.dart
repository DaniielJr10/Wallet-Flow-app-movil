import 'package:flutter/material.dart';

class DrawerPrincipal extends StatelessWidget {
	final VoidCallback onCerrarSesion;
	final Function(int) onNavigateToSection;
	const DrawerPrincipal({
		Key? key,
		required this.onCerrarSesion,
		required this.onNavigateToSection,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Drawer(
			backgroundColor: Colors.white,
			shape: const RoundedRectangleBorder(
				borderRadius: BorderRadius.only(
					topRight: Radius.circular(24),
					bottomRight: Radius.circular(24),
				),
			),
			child: Column(
				children: [
					Container(
						height: 220,
						decoration: const BoxDecoration(
							gradient: LinearGradient(
								begin: Alignment.topLeft,
								end: Alignment.bottomRight,
								colors: [
									Color(0xFF10B981),
									Color(0xFF059669),
								],
							),
							borderRadius: BorderRadius.only(
								topRight: Radius.circular(24),
							),
						),
						child: SafeArea(
							child: Padding(
								padding: const EdgeInsets.all(24),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Row(
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											children: [
												const Text(
													'Wallet Flow',
													style: TextStyle(
														fontSize: 24,
														fontWeight: FontWeight.w800,
														color: Colors.white,
													),
												),
												IconButton(
													onPressed: () => Navigator.pop(context),
													icon: const Icon(
														Icons.close_rounded,
														color: Colors.white,
														size: 24,
													),
													style: IconButton.styleFrom(
														backgroundColor: Colors.white.withOpacity(0.2),
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(12),
														),
													),
												),
											],
										),
										const SizedBox(height: 16),
										Row(
											children: [
												Container(
													padding: const EdgeInsets.all(12),
													decoration: BoxDecoration(
														color: Colors.white.withOpacity(0.2),
														borderRadius: BorderRadius.circular(16),
													),
													child: const Icon(
														Icons.person_rounded,
														size: 32,
														color: Colors.white,
													),
												),
												const SizedBox(width: 16),
												const Expanded(
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(
																'Usuario Premium',
																style: TextStyle(
																	fontSize: 18,
																	fontWeight: FontWeight.w700,
																	color: Colors.white,
																),
															),
															Text(
																'usuario@example.com',
																style: TextStyle(
																	fontSize: 14,
																	color: Colors.white70,
																),
															),
														],
													),
												),
											],
										),
										const SizedBox(height: 16),
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
											decoration: BoxDecoration(
												color: Colors.white.withOpacity(0.2),
												borderRadius: BorderRadius.circular(20),
											),
											child: const Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Icon(
														Icons.diamond_rounded,
														color: Colors.white,
														size: 16,
													),
													SizedBox(width: 8),
													Text(
														'Cuenta Premium',
														style: TextStyle(
															fontSize: 12,
															fontWeight: FontWeight.w600,
															color: Colors.white,
														),
													),
												],
											),
										),
									],
								),
							),
						),
					),
					Expanded(
						child: ListView(
							padding: const EdgeInsets.all(20),
							children: [
								_buildMenuSection(
									title: 'Acceso Rápido',
									items: [
										_buildDrawerMenuItem(
											icon: Icons.dashboard_outlined,
											title: 'Dashboard',
											color: const Color(0xFF10B981),
											onTap: () {
												Navigator.pop(context);
												onNavigateToSection(0);
											},
										),
										_buildDrawerMenuItem(
											icon: Icons.person_rounded,
											title: 'Mi Perfil',
											color: Colors.purple.shade600,
											onTap: () {
												Navigator.pop(context);
												onNavigateToSection(4);
											},
										),
										_buildDrawerMenuItem(
											icon: Icons.analytics_outlined,
											title: 'Reportes',
											color: Colors.cyan.shade600,
											onTap: () {
												Navigator.pop(context);
												// TODO: Implementar reportes
											},
										),
									],
								),
								const SizedBox(height: 20),
								_buildMenuSection(
									title: 'Gestión Financiera',
									items: [
										_buildDrawerMenuItem(
											icon: Icons.credit_card_rounded,
											title: 'Deudas',
											color: Colors.orange.shade600,
											badge: '2',
											onTap: () {
												Navigator.pop(context);
												onNavigateToSection(5);
											},
										),
										_buildDrawerMenuItem(
											icon: Icons.account_balance_rounded,
											title: 'Cuentas Bancarias',
											color: Colors.purple.shade600,
											onTap: () {
												Navigator.pop(context);
												onNavigateToSection(3);
											},
										),
									],
								),
								const SizedBox(height: 20),
								_buildMenuSection(
									title: 'Herramientas',
									items: [
										_buildDrawerMenuItem(
											icon: Icons.build_outlined,
											title: 'Calculadoras',
											color: Colors.indigo.shade600,
											onTap: () {
												Navigator.pop(context);
												onNavigateToSection(7);
											},
										),
										_buildDrawerMenuItem(
											icon: Icons.file_download_outlined,
											title: 'Exportar Datos',
											color: Colors.amber.shade600,
											onTap: () {
												Navigator.pop(context);
												// TODO: Implementar exportación
											},
										),
									],
								),
								const SizedBox(height: 20),
								_buildMenuSection(
									title: 'Configuración',
									items: [
										_buildDrawerMenuItem(
											icon: Icons.settings_outlined,
											title: 'Ajustes',
											color: Colors.grey.shade700,
											onTap: () {
												Navigator.pop(context);
												onNavigateToSection(8);
											},
										),
										_buildDrawerMenuItem(
											icon: Icons.notifications_outlined,
											title: 'Notificaciones',
											color: Colors.pink.shade600,
											badge: '3',
											onTap: () {
												Navigator.pop(context);
												// TODO: Implementar notificaciones
											},
										),
										_buildDrawerMenuItem(
											icon: Icons.help_outline_rounded,
											title: 'Ayuda y Soporte',
											color: Colors.lime.shade600,
											onTap: () {
												Navigator.pop(context);
												// TODO: Implementar ayuda y soporte
											},
										),
									],
								),
							],
						),
					),
					Container(
						padding: const EdgeInsets.all(16),
						child: ListTile(
							leading: Container(
								padding: const EdgeInsets.all(8),
								decoration: BoxDecoration(
									color: Colors.red.shade50,
									borderRadius: BorderRadius.circular(12),
								),
								child: Icon(
									Icons.logout_rounded,
									color: Colors.red.shade600,
									size: 20,
								),
							),
							title: Text(
								'Cerrar Sesión',
								style: TextStyle(
									fontWeight: FontWeight.w600,
									color: Colors.red.shade600,
								),
							),
							onTap: onCerrarSesion,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(12),
							),
						),
					),
				],
			),
		);
	}

	Widget _buildMenuSection({
		required String title,
		required List<Widget> items,
	}) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Padding(
					padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
					child: Text(
						title,
						style: TextStyle(
							fontSize: 13,
							fontWeight: FontWeight.w700,
							color: Colors.grey.shade600,
							letterSpacing: 0.5,
						),
					),
				),
				...items,
			],
		);
	}

	Widget _buildDrawerMenuItem({
		required IconData icon,
		required String title,
		required Color color,
		required VoidCallback onTap,
		String? badge,
	}) {
		return Container(
			margin: const EdgeInsets.only(bottom: 4),
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(12),
			),
			child: ListTile(
				leading: Container(
					padding: const EdgeInsets.all(8),
					decoration: BoxDecoration(
						color: color.withOpacity(0.1),
						borderRadius: BorderRadius.circular(10),
					),
					child: Icon(
						icon,
						color: color,
						size: 20,
					),
				),
				title: Text(
					title,
					style: const TextStyle(
						fontWeight: FontWeight.w600,
						color: Color(0xFF1F2937),
						fontSize: 15,
					),
				),
				trailing: badge != null
						? Container(
								padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
								decoration: BoxDecoration(
									color: color,
									borderRadius: BorderRadius.circular(12),
								),
								child: Text(
									badge,
									style: const TextStyle(
										color: Colors.white,
										fontSize: 12,
										fontWeight: FontWeight.w600,
									),
								),
							)
						: Icon(
								Icons.arrow_forward_ios_rounded,
								color: Colors.grey.shade400,
								size: 16,
							),
				onTap: onTap,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(12),
				),
				contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
			),
		);
	}
}
// Widget y lógica del Drawer para PantallaPrincipal

