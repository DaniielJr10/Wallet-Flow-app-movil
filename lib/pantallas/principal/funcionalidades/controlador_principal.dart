import 'package:flutter/material.dart';
import '../../../firebase/autenticacion_servicio.dart';
import '../../../firebase/base_datos_servicio.dart';
import '../../../login/iniciosesion.dart';

class PrincipalController {
	final AutenticacionServicio authService = AutenticacionServicio();
	final BaseDatosServicio baseDatosService = BaseDatosServicio();
	int selectedIndex = 0;
	late AnimationController animationController;
	late Animation<double> fadeAnimation;
	String nombreUsuario = 'Usuario';

	void initController(TickerProvider vsync, VoidCallback onNombreUsuarioChange) {
		animationController = AnimationController(
			duration: const Duration(milliseconds: 1000),
			vsync: vsync,
		);
		fadeAnimation = Tween<double>(
			begin: 0.0,
			end: 1.0,
		).animate(CurvedAnimation(
			parent: animationController,
			curve: Curves.easeInOut,
		));
		animationController.forward();
		cargarNombreUsuario(onNombreUsuarioChange);
	}

	void disposeController() {
		animationController.dispose();
	}

	Future<void> cargarNombreUsuario(VoidCallback onNombreUsuarioChange) async {
		try {
			final user = authService.usuarioActual;
			if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
				final nombreCompleto = user.displayName!;
				final primerNombre = nombreCompleto.split(' ')[0];
				nombreUsuario = primerNombre;
				onNombreUsuarioChange();
				return;
			}
			final perfil = await baseDatosService.obtenerPerfilUsuario();
			if (perfil != null && perfil.exists) {
				final datos = perfil.data() as Map<String, dynamic>?;
				if (datos != null && datos['nombre'] != null) {
					final nombreCompleto = datos['nombre'] as String;
					final primerNombre = nombreCompleto.split(' ')[0];
					nombreUsuario = primerNombre;
					onNombreUsuarioChange();
				}
			}
		} catch (e) {
			print('Error al cargar nombre del usuario: $e');
		}
	}

	Future<void> cerrarSesion(BuildContext context) async {
		final bool? confirmacion = await showDialog<bool>(
			context: context,
			barrierDismissible: false,
			builder: (BuildContext context) {
				return AlertDialog(
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(20),
					),
					backgroundColor: Colors.white,
					elevation: 24,
					title: Row(
						children: [
							Container(
								padding: const EdgeInsets.all(8),
								decoration: BoxDecoration(
									color: Colors.red.shade50,
									borderRadius: BorderRadius.circular(12),
								),
								child: Icon(
									Icons.logout_rounded,
									color: Colors.red.shade600,
									size: 24,
								),
							),
							const SizedBox(width: 12),
							const Text(
								'Cerrar Sesión',
								style: TextStyle(
									fontSize: 20,
									fontWeight: FontWeight.w600,
									color: Color(0xFF1F2937),
								),
							),
						],
					),
					content: const Text(
						'¿Estás seguro de que deseas cerrar sesión? Serás redirigido al menú principal.',
						style: TextStyle(
							fontSize: 16,
							color: Color(0xFF6B7280),
							height: 1.5,
						),
					),
					actions: [
						TextButton(
							onPressed: () => Navigator.of(context).pop(false),
							style: TextButton.styleFrom(
								padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(12),
								),
							),
							child: Text(
								'Cancelar',
								style: TextStyle(
									color: Colors.grey.shade600,
									fontWeight: FontWeight.w500,
								),
							),
						),
						ElevatedButton(
							onPressed: () => Navigator.of(context).pop(true),
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.red.shade600,
								foregroundColor: Colors.white,
								padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(12),
								),
								elevation: 0,
							),
							child: const Text(
								'Cerrar Sesión',
								style: TextStyle(fontWeight: FontWeight.w600),
							),
						),
					],
				);
			},
		);
		if (confirmacion == true) {
			try {
				await authService.cerrarSesion();
				if (context.mounted) {
					Navigator.pushAndRemoveUntil(
						context,
						MaterialPageRoute(builder: (context) => const InicioSesionScreen()),
						(route) => false,
					);
				}
			} catch (e) {
				if (context.mounted) {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Text('Error al cerrar sesión: $e'),
							backgroundColor: Colors.red.shade600,
							behavior: SnackBarBehavior.floating,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(12),
							),
						),
					);
				}
			}
		}
	}
}
// Lógica de controlador, animaciones y cierre de sesión para PantallaPrincipal

