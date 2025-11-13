import 'package:flutter/material.dart';
import '../firebase/base_datos_servicio.dart';
/// Pantalla principal para la gestión de cuentas bancarias
class PantallaCuentas extends StatefulWidget {
	const PantallaCuentas({super.key});

	@override
	State<PantallaCuentas> createState() => _PantallaCuentasState();
}

class _PantallaCuentasState extends State<PantallaCuentas> with TickerProviderStateMixin {
	final BaseDatosServicio _baseDatosService = BaseDatosServicio();
	late AnimationController _animationController;
	late Animation<double> _fadeAnimation;
	late Animation<Offset> _slideAnimation;

	@override
	void initState() {
		super.initState();
		_animationController = AnimationController(
			duration: const Duration(milliseconds: 900),
			vsync: this,
		);
		_fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
			CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
		);
		_slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
			CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
		);
		_animationController.forward();
	}

	@override
	void dispose() {
		_animationController.dispose();
		super.dispose();
	}

	/// Muestra un diálogo para agregar una nueva cuenta bancaria
	Future<void> _mostrarDialogoAgregarCuenta() async {
		String nombreBanco = '';
		String numeroCuenta = '';
		String tipoCuenta = '';
		String alias = '';
		double saldoInicial = 0.0;
		final formKey = GlobalKey<FormState>();

		await showModalBottomSheet(
			context: context,
			isScrollControlled: true,
			backgroundColor: Colors.transparent,
			builder: (context) {
				return FractionallySizedBox(
					heightFactor: 0.85,
					child: Container(
						decoration: const BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.only(
								topLeft: Radius.circular(25),
								topRight: Radius.circular(25),
							),
						),
						child: Padding(
							padding: EdgeInsets.only(
								top: 24,
								left: 24,
								right: 24,
								bottom: MediaQuery.of(context).viewInsets.bottom + 24,
							),
							child: Form(
								key: formKey,
								child: SingleChildScrollView(
									child: Column(
										mainAxisSize: MainAxisSize.min,
										children: [
											Row(
												children: [
													Icon(Icons.account_balance, color: Color(0xFF007bff), size: 28),
													const SizedBox(width: 10),
													Text('Agregar cuenta bancaria',
														style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF22223B))),
												],
											),
											const SizedBox(height: 18),
											TextFormField(
												decoration: InputDecoration(
													labelText: 'Banco',
													prefixIcon: Icon(Icons.account_balance_outlined),
													border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
													filled: true,
													fillColor: Colors.grey[100],
												),
												onChanged: (v) => nombreBanco = v,
												validator: (v) => v == null || v.isEmpty ? 'Ingrese el banco' : null,
											),
											const SizedBox(height: 14),
											TextFormField(
												decoration: InputDecoration(
													labelText: 'Número de cuenta',
													prefixIcon: Icon(Icons.numbers),
													border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
													filled: true,
													fillColor: Colors.grey[100],
												),
												keyboardType: TextInputType.number,
												onChanged: (v) => numeroCuenta = v,
												validator: (v) => v == null || v.isEmpty ? 'Ingrese el número de cuenta' : null,
											),
											const SizedBox(height: 14),
											TextFormField(
												decoration: InputDecoration(
													labelText: 'Tipo de cuenta',
													prefixIcon: Icon(Icons.credit_card),
													border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
													filled: true,
													fillColor: Colors.grey[100],
												),
												onChanged: (v) => tipoCuenta = v,
												validator: (v) => v == null || v.isEmpty ? 'Ingrese el tipo de cuenta' : null,
											),
											const SizedBox(height: 14),
											TextFormField(
												decoration: InputDecoration(
													labelText: 'Alias',
													prefixIcon: Icon(Icons.alternate_email),
													border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
													filled: true,
													fillColor: Colors.grey[100],
												),
												onChanged: (v) => alias = v,
												validator: (v) => v == null || v.isEmpty ? 'Ingrese un alias' : null,
											),
											const SizedBox(height: 14),
											TextFormField(
												decoration: InputDecoration(
													labelText: 'Saldo inicial',
													prefixIcon: Icon(Icons.attach_money),
													border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
													filled: true,
													fillColor: Colors.grey[100],
												),
												keyboardType: TextInputType.numberWithOptions(decimal: true),
												onChanged: (v) => saldoInicial = double.tryParse(v) ?? 0.0,
												validator: (v) => v == null || v.isEmpty ? 'Ingrese el saldo' : null,
											),
											const SizedBox(height: 24),
											Row(
												mainAxisAlignment: MainAxisAlignment.end,
												children: [
													TextButton(
														onPressed: () => Navigator.pop(context),
														child: const Text('Cancelar', style: TextStyle(color: Color(0xFF007bff))),
													),
													const SizedBox(width: 8),
													ElevatedButton(
														style: ElevatedButton.styleFrom(
															backgroundColor: const Color(0xFF007bff),
															shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
															padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
															elevation: 2,
														),
														child: const Text('Agregar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
														onPressed: () async {
															if (formKey.currentState!.validate()) {
																final error = await _baseDatosService.crearCuentaBancaria(
																	nombreBanco: nombreBanco,
																	numeroCuenta: numeroCuenta,
																	tipoCuenta: tipoCuenta,
																	alias: alias,
																	saldoInicial: saldoInicial,
																);
																if (mounted) {
																	Navigator.pop(context);
																	ScaffoldMessenger.of(context).showSnackBar(
																		SnackBar(
																			content: Text(error ?? 'Cuenta agregada exitosamente'),
																			backgroundColor: error == null ? Colors.green : Colors.red,
																		),
																	);
																}
															}
														},
													),
												],
											),
										],
									),
								),
							),
						),
					),
				);
			},
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF8FAFC),
			appBar: AppBar(
							backgroundColor: Colors.white,
							elevation: 0,
							title: Row(
								mainAxisAlignment: MainAxisAlignment.center,
								mainAxisSize: MainAxisSize.min,
								children: [
									Icon(
										Icons.account_balance_rounded,
										color: Color(0xFF007bff), // Morado igual que en la barra inferior
										size: 28,
									),
									const SizedBox(width: 10),
															Text(
																'Cuentas',
																style: TextStyle(
																	color: Color(0xFF007bff),
																	fontWeight: FontWeight.bold,
																	fontSize: 24,
																),
															),
														],
							),
							centerTitle: true,
							actions: [
								IconButton(
									icon: const Icon(Icons.add_circle_outline, color: Color(0xFF007bff), size: 28),
								tooltip: 'Agregar cuenta',
								onPressed: _mostrarDialogoAgregarCuenta,
							),
							],
						),
			body: FadeTransition(
				opacity: _fadeAnimation,
				child: SlideTransition(
					position: _slideAnimation,
					child: Padding(
						padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
						child: StreamBuilder(
							stream: _baseDatosService.obtenerCuentas(),
							builder: (context, snapshot) {
								if (snapshot.connectionState == ConnectionState.waiting) {
									return const Center(child: CircularProgressIndicator(color: Color(0xFF007bff)));
								}
								if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
									return _buildEmptyState();
								}
								final cuentas = snapshot.data!.docs;
								return ListView.separated(
									itemCount: cuentas.length,
									separatorBuilder: (_, __) => const SizedBox(height: 12),
									itemBuilder: (context, i) {
										final cuenta = cuentas[i].data() as Map<String, dynamic>;
										return _buildCuentaCard(cuenta);
									},
								);
							},
						),
					),
				),
			),
		);
	}

	/// Widget para mostrar una tarjeta de cuenta bancaria
	Widget _buildCuentaCard(Map<String, dynamic> cuenta) {
		return Container(
			decoration: BoxDecoration(
				gradient: const LinearGradient(
					colors: [Color(0xFF007bff), Color(0xFF0056b3)],
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
				),
				borderRadius: BorderRadius.circular(18),
				boxShadow: [
					BoxShadow(
						color: const Color(0xFF007bff).withOpacity(0.10),
						blurRadius: 10,
						offset: const Offset(0, 4),
					),
				],
			),
			child: ListTile(
				contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
				leading: CircleAvatar(
					backgroundColor: Colors.white,
					child: Icon(Icons.account_balance_wallet, color: Color(0xFF007bff)),
				),
				title: Text(
					cuenta['alias'] ?? 'Sin alias',
					style: const TextStyle(
						color: Colors.white,
						fontWeight: FontWeight.bold,
						fontSize: 18,
					),
				),
				subtitle: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text(
							cuenta['nombreBanco'] ?? '',
							style: const TextStyle(color: Colors.white70, fontSize: 15),
						),
						Text(
							'N° ${cuenta['numeroCuenta'] ?? ''}  |  ${cuenta['tipoCuenta'] ?? ''}',
							style: const TextStyle(color: Colors.white60, fontSize: 13),
						),
					],
				),
				trailing: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						const Text('Saldo', style: TextStyle(color: Colors.white70, fontSize: 13)),
						Text(
							' 24${cuenta['saldo']?.toStringAsFixed(2) ?? '0.00'}',
							style: const TextStyle(
								color: Colors.white,
								fontWeight: FontWeight.bold,
								fontSize: 16,
							),
						),
					],
				),
			),
		);
	}

	/// Estado vacío cuando no hay cuentas
	Widget _buildEmptyState() {
		return Center(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey.shade300),
					const SizedBox(height: 16),
					const Text(
						'No tienes cuentas registradas',
						style: TextStyle(fontSize: 18, color: Color(0xFF007bff), fontWeight: FontWeight.w600),
					),
					const SizedBox(height: 8),
					const Text(
						'Agrega tu primera cuenta bancaria para empezar a gestionar tu dinero.',
						textAlign: TextAlign.center,
						style: TextStyle(fontSize: 15, color: Colors.black54),
					),
					const SizedBox(height: 24),
					ElevatedButton.icon(
						style: ElevatedButton.styleFrom(
							backgroundColor: const Color(0xFF007bff),
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
							padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
						),
						icon: const Icon(Icons.add, color: Colors.white),
						label: const Text('Agregar cuenta', style: TextStyle(color: Colors.white)),
						onPressed: _mostrarDialogoAgregarCuenta,
					),
				],
			),
		);
	}
}