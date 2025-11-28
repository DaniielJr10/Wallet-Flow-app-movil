import 'package:flutter/material.dart';
import '../../firebase/servicios/gastoService/gastos_servicio.dart';

// Importaciones modularizadas
import 'funcionalidades/app_bar_gastos.dart';
import 'funcionalidades/resumen_gastos.dart';
import 'funcionalidades/filtros_gastos.dart';
import 'funcionalidades/lista_gastos_builder.dart';
import 'funcionalidades/formulario_gasto.dart';
import 'funcionalidades/detalle_gasto.dart';
import 'funcionalidades/dialogos_gastos.dart';
import 'funcionalidades/utils_gastos.dart';

class PantallaGastos extends StatefulWidget {
  const PantallaGastos({super.key});

  @override
  State<PantallaGastos> createState() => _PantallaGastosState();
}

class _PantallaGastosState extends State<PantallaGastos> with TickerProviderStateMixin {
  final GastosServicio _gastosServicio = GastosServicio();
  final TextEditingController _busquedaController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _textoBusqueda = '';
  String _modoBusqueda = 'categoría';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppBarGastos(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResumenGastos(gastosServicio: _gastosServicio),
              const SizedBox(height: 24),
              
              FiltrosGastos(
                controller: _busquedaController,
                modoBusqueda: _modoBusqueda,
                onChanged: (v) => setState(() => _textoBusqueda = v),
                onClear: () => setState(() {
                  _busquedaController.clear();
                  _textoBusqueda = '';
                }),
                onModeChanged: (v) => setState(() {
                  _modoBusqueda = v;
                  _busquedaController.clear();
                  _textoBusqueda = '';
                }),
              ),
              
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Historial de Gastos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _mostrarFormularioGasto,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Nuevo Gasto',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UtilsGastos.colorPrincipal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              ListaGastosBuilder(
                gastosServicio: _gastosServicio,
                textoBusqueda: _textoBusqueda,
                modoBusqueda: _modoBusqueda,
                onTapGasto: _mostrarDetalleGasto,
                onEliminarGasto: _confirmarEliminarGasto,
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarFormularioGasto() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FormularioGasto(
        onGuardar: () => setState(() {}), // Recargar si es necesario
      ),
    );
  }

  void _mostrarDetalleGasto(Map<String, dynamic> gasto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetalleGasto(
        gasto: gasto,
        onEditar: () => _mostrarFormularioEdicion(gasto),
        onEliminar: () => _confirmarEliminarGasto(gasto['id']),
      ),
    );
  }

  void _mostrarFormularioEdicion(Map<String, dynamic> gasto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FormularioGasto(
        esEdicion: true,
        gastoExistente: gasto,
        onGuardar: () => setState(() {}),
      ),
    );
  }

  void _confirmarEliminarGasto(String gastoId) {
    showDialog(
      context: context,
      builder: (context) => DialogoEliminarGasto(
        gastoId: gastoId,
        onEliminado: () => setState(() {}),
      ),
    );
  }
}