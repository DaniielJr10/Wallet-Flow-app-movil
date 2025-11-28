/// ORQUESTADOR PRINCIPAL
/// Coordina la pantalla de Ingresos. Maneja el estado global de la pantalla
/// (búsqueda, modo de filtro, animaciones) y la navegación hacia los modales
/// de creación, edición y detalle.
import 'package:flutter/material.dart';
import '../../firebase/servicios/ingresoService/ingresos_servicio.dart';

// Importaciones modulares
import 'funcionalidades/app_bar_ingresos.dart';
import 'funcionalidades/resumen_ingresos.dart';
import 'funcionalidades/filtros_ingresos.dart';
import 'funcionalidades/lista_ingresos_builder.dart';
import 'funcionalidades/formulario_ingreso.dart';
import 'funcionalidades/detalle_ingreso.dart';
import 'funcionalidades/dialogos_ingresos.dart';
import 'funcionalidades/utils_ingresos.dart';

class PantallaIngresos extends StatefulWidget {
  const PantallaIngresos({super.key});

  @override
  State<PantallaIngresos> createState() => _PantallaIngresosState();
}

class _PantallaIngresosState extends State<PantallaIngresos> with TickerProviderStateMixin {
  final IngresosServicio _ingresosServicio = IngresosServicio();
  final TextEditingController _busquedaController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _busqueda = '';
  String _modoBusqueda = 'categoría';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtilsIngresos.colorFondo,
      appBar: const AppBarIngresos(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResumenIngresos(ingresosServicio: _ingresosServicio),
              const SizedBox(height: 24),
              
              FiltrosIngresos(
                controller: _busquedaController,
                modoBusqueda: _modoBusqueda,
                onChanged: (v) => setState(() => _busqueda = v),
                onClear: () => setState(() {
                  _busqueda = '';
                  _busquedaController.clear();
                }),
                onModeChanged: (v) => setState(() {
                  _modoBusqueda = v;
                  _busqueda = '';
                  _busquedaController.clear();
                }),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Historial de Ingresos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: UtilsIngresos.colorTexto,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarFormularioIngreso(),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Nuevo ingreso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UtilsIngresos.colorPrincipal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              ListaIngresosBuilder(
                ingresosServicio: _ingresosServicio,
                busqueda: _busqueda,
                modoBusqueda: _modoBusqueda,
                onTapIngreso: _mostrarDetallesIngreso,
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarFormularioIngreso([Map<String, dynamic>? ingresoAEditar]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FormularioIngreso(
        esEdicion: ingresoAEditar != null,
        ingresoExistente: ingresoAEditar,
        onGuardar: () => setState(() {}),
      ),
    );
  }

  void _mostrarDetallesIngreso(Map<String, dynamic> ingreso) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetalleIngreso(
        ingreso: ingreso,
        onEditar: () => _mostrarFormularioIngreso(ingreso),
        onEliminar: () => _confirmarEliminar(ingreso['id']),
      ),
    );
  }

  void _confirmarEliminar(String ingresoId) {
    showDialog(
      context: context,
      builder: (context) => DialogoEliminarIngreso(
        ingresoId: ingresoId,
        onEliminado: () => setState(() {}),
      ),
    );
  }
}