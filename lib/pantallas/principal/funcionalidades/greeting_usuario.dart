import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../firebase/base_datos_servicio.dart';

class GreetingUsuario extends StatefulWidget {
	final BaseDatosServicio baseDatosService;
	final String nombreUsuario;
	final Function(String) onNombreUsuarioChange;
	final VoidCallback onCerrarSesion;
	final int selectedIndex;
	final Function(int) onPerfilTap;

	const GreetingUsuario({
		Key? key,
		required this.baseDatosService,
		required this.nombreUsuario,
		required this.onNombreUsuarioChange,
		required this.onCerrarSesion,
		required this.selectedIndex,
		required this.onPerfilTap,
	}) : super(key: key);

	@override
	State<GreetingUsuario> createState() => _GreetingUsuarioState();
}

class _GreetingUsuarioState extends State<GreetingUsuario> {
	@override
	Widget build(BuildContext context) {
		return Stack(
			children: [
				Container(
					padding: const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 20),
					decoration: BoxDecoration(
						color: const Color(0xFF2ecc71),
						borderRadius: BorderRadius.circular(20),
						border: Border.all(
							color: const Color(0xFF10B981).withOpacity(0.2),
							width: 1,
						),
					),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Image.asset(
										'images/logo.png',
										width: 38,
										height: 38,
									),
									const SizedBox(width: 2),
									const Text(
										'Wallet Flow',
										style: TextStyle(
											fontSize: 17,
											fontWeight: FontWeight.bold,
											color: Colors.white,
											letterSpacing: 0.5,
										),
									),
								],
							),
							const SizedBox(height: 16),
							Row(
								crossAxisAlignment: CrossAxisAlignment.center,
								children: [
									GestureDetector(
										onTap: () {
											widget.onPerfilTap(4);
										},
										child: Container(
											width: 62,
											height: 62,
											margin: const EdgeInsets.only(top: 2),
											decoration: BoxDecoration(
												shape: BoxShape.circle,
												border: Border.all(
													color: const Color(0xFF10B981),
													width: 2,
												),
												boxShadow: [
													BoxShadow(
														color: const Color(0xFF10B981).withOpacity(0.15),
														blurRadius: 6,
														offset: const Offset(0, 2),
													),
												],
											),
											child: ClipOval(
												child: _buildProfileImage(widget.nombreUsuario),
											),
										),
									),
									const SizedBox(width: 12),
									Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												'Hola, ${widget.nombreUsuario}',
												style: const TextStyle(
													fontSize: 24,
													fontWeight: FontWeight.bold,
													color: Colors.white,
												),
											),
										],
									),
								],
							),
						],
					),
				),
				Positioned(
					top: 50,
					right: 0,
					child: IconButton(
						onPressed: widget.onCerrarSesion,
						icon: const Icon(
							Icons.logout_rounded,
							color: Colors.red,
							size: 28,
						),
						style: IconButton.styleFrom(
							backgroundColor: Colors.transparent,
							elevation: 0,
							padding: EdgeInsets.zero,
							shape: const CircleBorder(),
						),
						tooltip: 'Cerrar sesión',
					),
				),
			],
		);
	}

	Widget _buildProfileImage(String nombreUsuario) {
		final user = FirebaseAuth.instance.currentUser;
		final photoURL = user?.photoURL;
		if (photoURL != null && photoURL.isNotEmpty) {
			return Image.network(
				photoURL,
				fit: BoxFit.cover,
				width: 52,
				height: 52,
				loadingBuilder: (context, child, loadingProgress) {
					if (loadingProgress == null) return child;
					return Container(
						width: 52,
						height: 52,
						decoration: const BoxDecoration(
							color: Color(0xFF10B981),
							shape: BoxShape.circle,
						),
						child: const Center(
							child: CircularProgressIndicator(
								valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
								strokeWidth: 2,
							),
						),
					);
				},
				errorBuilder: (context, error, stackTrace) {
					return _buildDefaultAvatar(nombreUsuario);
				},
			);
		} else {
			return _buildDefaultAvatar(nombreUsuario);
		}
	}

	Widget _buildDefaultAvatar(String nombreUsuario) {
		return Container(
			width: 52,
			height: 52,
			decoration: const BoxDecoration(
				color: Color(0xFF10B981),
				shape: BoxShape.circle,
			),
			child: Center(
				child: Text(
					nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : 'U',
					style: const TextStyle(
						fontSize: 24,
						fontWeight: FontWeight.bold,
						color: Colors.white,
					),
				),
			),
		);
	}
}
// Widget y lógica del saludo personalizado y avatar para PantallaPrincipal

