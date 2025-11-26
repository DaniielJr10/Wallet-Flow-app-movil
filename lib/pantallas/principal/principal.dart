import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../firebase/servicios/principal_servicio.dart';
import 'funcionalidades/greeting_usuario.dart';
import 'funcionalidades/resumen_financiero.dart';
import 'funcionalidades/barra_inferior.dart';
import 'funcionalidades/drawer_principal.dart';
import 'funcionalidades/navegacion_principal.dart' show navegarASeccion;
import 'funcionalidades/controlador_principal.dart' show PrincipalController;
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({Key? key}) : super(key: key);

  @override
  _PantallaPrincipalState createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> with TickerProviderStateMixin {
  final PrincipalController controller = PrincipalController();
  final PrincipalServicio principalServicio = PrincipalServicio();
  int selectedIndex = 0;
  String nombreUsuario = 'Usuario';

  @override
  void initState() {
    super.initState();
    controller.initController(this, () {
      setState(() {
        nombreUsuario = controller.nombreUsuario;
      });
    });
  }

  @override
  void dispose() {
    controller.disposeController();
    super.dispose();
  }

  void setSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void handleBottomNavigation(int index) {
    navegarASeccion(context, index, setSelectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 45),
                GreetingUsuario(
                  baseDatosService: controller.baseDatosService,
                  nombreUsuario: nombreUsuario,
                  onNombreUsuarioChange: (nuevoNombre) {
                    setState(() {
                      nombreUsuario = nuevoNombre;
                    });
                  },
                  onCerrarSesion: () => controller.cerrarSesion(context),
                  selectedIndex: selectedIndex,
                  onPerfilTap: (index) => navegarASeccion(context, index, setSelectedIndex),
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
                ResumenFinanciero(
                  principalServicio: principalServicio,
                  onNavigateToSection: (index) => navegarASeccion(context, index, setSelectedIndex),
                ),
              ],
            ),
          ),
          // Aquí puedes agregar las otras pantallas como Perfil y Configuración
          Container(), // const PantallaPerfil()
          Container(), // const PantallaConfiguracion()
        ],
      ),
      bottomNavigationBar: BarraInferior(
        selectedIndex: selectedIndex,
        onTap: handleBottomNavigation,
      ),
      drawer: DrawerPrincipal(
        onCerrarSesion: () => controller.cerrarSesion(context),
        onNavigateToSection: (index) => navegarASeccion(context, index, setSelectedIndex),
      ),
    );
  }
}
