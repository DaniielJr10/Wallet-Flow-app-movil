/// MENÚ LATERAL (DRAWER)
/// Contiene la navegación secundaria de la app, con un header personalizado
/// y la lista de opciones organizadas por secciones (Acceso Rápido, Gestión, etc.).
import 'package:flutter/material.dart';
import '../../configuracion/funcionalidades/contactar_soporte/contactar_soporte.dart';
import '../../configuracion/funcionalidades/preguntas_frecuentes/preguntas_frecuentes.dart';

class PrincipalDrawer extends StatelessWidget {
  final Function(int) onNavigate;
  final VoidCallback onLogout;

  const PrincipalDrawer({
    super.key,
    required this.onNavigate,
    required this.onLogout,
  });

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
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildMenuSection(
                  title: 'Acceso Rápido',
                  items: [
                    _buildMenuItem(Icons.dashboard_outlined, 'Dashboard', const Color(0xFF10B981), () => _handleTap(context, 0)),
                    _buildMenuItem(Icons.person_rounded, 'Mi Perfil', Colors.purple.shade600, () => _handleTap(context, 4)),
                    _buildMenuItem(Icons.analytics_outlined, 'Reportes', Colors.cyan.shade600, () { Navigator.pop(context); /* TODO */ }),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMenuSection(
                  title: 'Gestión Financiera',
                  items: [
                    _buildMenuItem(Icons.credit_card_rounded, 'Deudas', Colors.orange.shade600, () => _handleTap(context, 5), badge: '2'),
                    _buildMenuItem(Icons.account_balance_rounded, 'Cuentas Bancarias', Colors.purple.shade600, () => _handleTap(context, 3)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMenuSection(
                  title: 'Herramientas',
                  items: [
                    _buildMenuItem(Icons.build_outlined, 'Calculadoras', Colors.indigo.shade600, () => _handleTap(context, 7)),
                    _buildMenuItem(Icons.file_download_outlined, 'Exportar Datos', Colors.amber.shade600, () { Navigator.pop(context); /* TODO */ }),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMenuSection(
                  title: 'Configuración',
                  items: [
                    _buildMenuItem(Icons.settings_outlined, 'Ajustes', Colors.grey.shade700, () => _handleTap(context, 8)),
                    _buildMenuItem(Icons.notifications_outlined, 'Notificaciones', Colors.pink.shade600, () { Navigator.pop(context); /* TODO */ }, badge: '3'),
                    _buildMenuItem(Icons.help_outline_rounded, 'Preguntas Frecuentes', Colors.blue.shade600, () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PreguntasFrecuentesPantalla()));
                    }),
                    _buildMenuItem(Icons.support_agent, 'Contactar Soporte', Colors.lime.shade600, () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactarSoportePantalla()));
                    }),
                  ],
                ),
              ],
            ),
          ),
          _buildLogoutItem(),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, int index) {
    Navigator.pop(context);
    onNavigate(index);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
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
                  const Text('Wallet Flow', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.person_rounded, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Usuario Premium', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('usuario@example.com', style: TextStyle(fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.diamond_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('Cuenta Premium', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 0.5)),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color, VoidCallback onTap, {String? badge}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2937), fontSize: 15)),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              )
            : Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildLogoutItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 20),
        ),
        title: Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade600)),
        onTap: onLogout,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}