/// CUERPO DEL DASHBOARD
/// Agrupa el saludo (Header) y el resumen financiero en una vista scrolleable.
/// Recibe la animación de desvanecimiento para una entrada suave.
import 'package:flutter/material.dart';
import '../../../firebase/servicios/PrincipalService/principal_servicio.dart';
import 'header_saludo.dart';
import 'resumen_financiero_card.dart';

class DashboardBody extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final String nombreUsuario;
  final VoidCallback onAvatarTap;
  final VoidCallback onLogoutTap;
  final PrincipalServicio servicio;
  final Function(int) onNavigate;

  const DashboardBody({
    super.key,
    required this.fadeAnimation,
    required this.nombreUsuario,
    required this.onAvatarTap,
    required this.onLogoutTap,
    required this.servicio,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 45),
            
            HeaderSaludo(
              nombreUsuario: nombreUsuario,
              onAvatarTap: onAvatarTap,
              onLogoutTap: onLogoutTap,
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Resumen Financiero',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            
            const SizedBox(height: 10),
            
            ResumenFinancieroCard(
              servicio: servicio,
              onNavigate: onNavigate,
            ),
          ],
        ),
      ),
    );
  }
}