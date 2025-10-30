import 'package:flutter/material.dart';

class InicioSesionPage extends StatefulWidget {
	@override
	_InicioSesionPageState createState() => _InicioSesionPageState();
}

class _InicioSesionPageState extends State<InicioSesionPage> {
	final TextEditingController _emailController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();
	bool _isObscure = true;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF5F6FA),
			body: Center(
				child: SingleChildScrollView(
					padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							const SizedBox(height: 30),
							// Logo o icono principal
							CircleAvatar(
								radius: 48,
								backgroundColor: Colors.deepPurple.shade100,
								child: Icon(Icons.account_balance_wallet_rounded, size: 56, color: Colors.deepPurple),
							),
							const SizedBox(height: 24),
							Text(
								'WalletFlow',
								textAlign: TextAlign.center,
								style: TextStyle(
									fontSize: 32,
									fontWeight: FontWeight.bold,
									color: Colors.deepPurple.shade700,
									letterSpacing: 1.2,
								),
							),
							const SizedBox(height: 8),
							Text(
								'Bienvenido de nuevo',
								textAlign: TextAlign.center,
								style: TextStyle(
									fontSize: 18,
									color: Colors.grey.shade700,
								),
							),
							const SizedBox(height: 32),
							// Campo de correo
							TextField(
								controller: _emailController,
								keyboardType: TextInputType.emailAddress,
								decoration: InputDecoration(
									labelText: 'Correo electrónico',
									prefixIcon: Icon(Icons.email_outlined),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(16),
									),
									filled: true,
									fillColor: Colors.white,
								),
							),
							const SizedBox(height: 20),
							// Campo de contraseña
							TextField(
								controller: _passwordController,
								obscureText: _isObscure,
								decoration: InputDecoration(
									labelText: 'Contraseña',
									prefixIcon: Icon(Icons.lock_outline),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(16),
									),
									filled: true,
									fillColor: Colors.white,
									suffixIcon: IconButton(
										icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
										onPressed: () {
											setState(() {
												_isObscure = !_isObscure;
											});
										},
									),
								),
							),
							const SizedBox(height: 12),
							Align(
								alignment: Alignment.centerRight,
								child: TextButton(
									onPressed: () {
										// Navegar a recuperar contraseña
									},
									child: const Text('¿Olvidaste tu contraseña?'),
								),
							),
							const SizedBox(height: 16),
							ElevatedButton(
								style: ElevatedButton.styleFrom(
									backgroundColor: Colors.deepPurple,
									padding: const EdgeInsets.symmetric(vertical: 16),
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(16),
									),
									elevation: 4,
								),
								onPressed: () {
									// Acción de inicio de sesión
								},
								child: const Text(
									'Iniciar sesión',
									style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
								),
							),
							const SizedBox(height: 24),
							Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									const Text('¿No tienes cuenta?'),
									TextButton(
										onPressed: () {
											// Navegar a registro
										},
										child: const Text('Regístrate'),
									),
								],
							),
							const SizedBox(height: 16),
							Row(
								children: [
									Expanded(child: Divider()),
									Padding(
										padding: const EdgeInsets.symmetric(horizontal: 8.0),
										child: Text('o'),
									),
									Expanded(child: Divider()),
								],
							),
							const SizedBox(height: 16),
							// Botón de Google (puedes agregar otros métodos de login)
							OutlinedButton.icon(
								style: OutlinedButton.styleFrom(
									padding: const EdgeInsets.symmetric(vertical: 14),
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(16),
									),
									side: BorderSide(color: Colors.deepPurple.shade100),
								),
								icon: Image.asset(
									'assets/google_logo.png',
									height: 24,
									width: 24,
								),
								label: const Text(
									'Continuar con Google',
									style: TextStyle(fontSize: 16),
								),
								onPressed: () {
									// Acción de login con Google
								},
							),
							const SizedBox(height: 30),
						],
					),
				),
			),
		);
	}
}
