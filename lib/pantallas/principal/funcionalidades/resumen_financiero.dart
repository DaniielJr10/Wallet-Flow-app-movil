import 'package:flutter/material.dart';
import '../../../utilidades/formato_numeros.dart';
import '../../../firebase/servicios/principal_servicio.dart';

class ResumenFinanciero extends StatelessWidget {
	final PrincipalServicio principalServicio;
	final Function(int) onNavigateToSection;
	const ResumenFinanciero({
		Key? key,
		required this.principalServicio,
		required this.onNavigateToSection,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return FutureBuilder<Map<String, dynamic>>(
			future: principalServicio.obtenerEstadisticasRapidas(),
			builder: (context, snapshot) {
				if (snapshot.connectionState == ConnectionState.waiting) {
					return _buildLoadingFinancialSummary();
				}
				if (snapshot.hasError) {
					return _buildErrorFinancialSummary();
				}
				final data = snapshot.data ?? {};
				final totalCuentas = data['totalCuentas'] ?? 0.0;
				final ingresosDelMes = data['ingresosDelMes'] ?? 0.0;
				final gastosDelMes = data['gastosDelMes'] ?? 0.0;
				final totalAhorros = data['totalAhorros'] ?? 0.0;
				final totalDeudas = data['totalDeudas'] ?? 0.0;

				return Container(
					padding: const EdgeInsets.all(20),
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(20),
						boxShadow: [
							BoxShadow(
								color: Colors.black.withOpacity(0.05),
								blurRadius: 15,
								offset: const Offset(0, 5),
							),
						],
					),
					child: Column(
						children: [
							Row(
								children: [
									Expanded(
										   child: _buildSummaryItem(
											   title: 'Ingresos',
											   amount: FormatoNumeros.formatearParaMostrar(ingresosDelMes),
											   icon: Icons.trending_up_rounded,
											   color: Color(0xFF2ecc71),
											   onTap: () => onNavigateToSection(10),
										   ),
									),
									const SizedBox(width: 12),
									Expanded(
										   child: _buildSummaryItem(
											   title: 'Gastos',
											   amount: FormatoNumeros.formatearParaMostrar(gastosDelMes),
											   icon: Icons.trending_down_rounded,
											   color: Color(0xFFEF4444),
											   onTap: () => onNavigateToSection(11),
										   ),
									),
								],
							),
							const SizedBox(height: 12),
							Row(
								children: [
									Expanded(
										   child: _buildSummaryItem(
											   title: 'Cuentas',
											   amount: FormatoNumeros.formatearParaMostrar(totalCuentas),
											   icon: Icons.account_balance_wallet_rounded,
											   color: Color(0xFF2563EB),
											   onTap: () => onNavigateToSection(12),
										   ),
									),
									const SizedBox(width: 12),
									Expanded(
										   child: _buildSummaryItem(
											   title: 'Deudas',
											   amount: totalDeudas > 0
													   ? FormatoNumeros.formatearParaMostrar(totalDeudas)
													   : 'Sin deudas',
											   icon: Icons.credit_card_rounded,
											   color: Colors.orange.shade600,
											   onTap: () => onNavigateToSection(13),
										   ),
									),
								],
							),
							const SizedBox(height: 12),
							Row(
								children: [
									Expanded(
										   child: _buildSummaryItem(
											   title: 'Ahorros',
											   amount: FormatoNumeros.formatearParaMostrar(totalAhorros),
											   icon: Icons.savings_rounded,
											   color: Color(0xFF8570FA),
											   onTap: () => onNavigateToSection(14),
										   ),
									),
									const SizedBox(width: 12),
									Expanded(
										   child: _buildSummaryItem(
											   title: 'Herramientas',
											   amount: '',
											   icon: Icons.build_outlined,
											   color: Colors.indigo.shade600,
											   onTap: () => onNavigateToSection(15),
										   ),
									),
								],
							),
						],
					),
				);
			},
		);
	}

	Widget _buildLoadingFinancialSummary() {
		return Container(
			padding: const EdgeInsets.all(20),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(20),
				boxShadow: [
					BoxShadow(
						color: Colors.black.withOpacity(0.05),
						blurRadius: 15,
						offset: const Offset(0, 5),
					),
				],
			),
			child: Column(
				children: [
					Row(
						children: [
							Expanded(child: _buildLoadingSummaryItem()),
							const SizedBox(width: 12),
							Expanded(child: _buildLoadingSummaryItem()),
						],
					),
					const SizedBox(height: 12),
					Row(
						children: [
							Expanded(child: _buildLoadingSummaryItem()),
							const SizedBox(width: 12),
							Expanded(child: _buildLoadingSummaryItem()),
						],
					),
				],
			),
		);
	}

	Widget _buildLoadingSummaryItem() {
		return Container(
			padding: const EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: Colors.grey.shade50,
				borderRadius: BorderRadius.circular(12),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Container(
						width: 60,
						height: 12,
						decoration: BoxDecoration(
							color: Colors.grey.shade300,
							borderRadius: BorderRadius.circular(6),
						),
					),
					const SizedBox(height: 8),
					Container(
						width: 80,
						height: 16,
						decoration: BoxDecoration(
							color: Colors.grey.shade300,
							borderRadius: BorderRadius.circular(8),
						),
					),
				],
			),
		);
	}

	Widget _buildErrorFinancialSummary() {
		return Container(
			padding: const EdgeInsets.all(20),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(20),
				boxShadow: [
					BoxShadow(
						color: Colors.black.withOpacity(0.05),
						blurRadius: 15,
						offset: const Offset(0, 5),
					),
				],
			),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Icon(
						Icons.error_outline_rounded,
						color: Colors.red.shade400,
						size: 48,
					),
					const SizedBox(height: 12),
					Text(
						'Error al cargar datos',
						style: TextStyle(
							fontSize: 16,
							fontWeight: FontWeight.w600,
							color: Colors.grey.shade700,
						),
					),
					const SizedBox(height: 8),
					Text(
						'Toca para reintentar',
						style: TextStyle(
							fontSize: 14,
							color: Colors.grey.shade500,
						),
					),
				],
			),
		);
	}

	Widget _buildSummaryItem({
		required String title,
		required String amount,
		required IconData icon,
		required Color color,
		required VoidCallback onTap,
	}) {
		return Material(
			color: Colors.transparent,
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(16),
				child: Container(
					padding: const EdgeInsets.all(16),
					decoration: BoxDecoration(
						border: Border.all(
							color: color.withOpacity(0.2),
						),
						borderRadius: BorderRadius.circular(16),
					),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Container(
										padding: const EdgeInsets.all(8),
										decoration: BoxDecoration(
											color: color.withOpacity(0.1),
											borderRadius: BorderRadius.circular(8),
										),
										child: Icon(
											icon,
											color: color,
											size: 16,
										),
									),
									Icon(
										Icons.arrow_forward_ios_rounded,
										color: Colors.grey.shade400,
										size: 12,
									),
								],
							),
							const SizedBox(height: 12),
							Text(
								title,
								style: TextStyle(
									fontSize: 12,
									fontWeight: FontWeight.w600,
									color: Colors.grey.shade600,
								),
							),
							const SizedBox(height: 4),
							Text(
								amount,
								style: TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.w700,
									color: color,
								),
							),
						],
					),
				),
			),
		);
	}
}
// Widget y lógica del resumen financiero para PantallaPrincipal

