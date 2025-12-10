/// ARCHIVO PRINCIPAL (ORQUESTADOR)
/// Se encarga de la estructura base (Scaffold), maneja el estado global
/// de la pantalla (filtros, búsquedas) y coordina la navegación hacia
/// los formularios y modales.
import 'package:flutter/material.dart';
import '../../firebase/servicios/CuentaService/cuentas_servicio.dart';

// Importación de las funcionalidades divididas
import 'funcionalidades/app_bar_cuentas.dart';
import 'funcionalidades/resumen_financiero.dart';
import 'funcionalidades/filtros_cuentas.dart';
import 'funcionalidades/lista_builder.dart';
import 'funcionalidades/formulario_main.dart';
import 'funcionalidades/detalle_cuenta.dart';

class PantallaCuentas extends StatefulWidget {
  const PantallaCuentas({super.key});

  @override
  State<PantallaCuentas> createState() => _PantallaCuentasState();
}

class _PantallaCuentasState extends State<PantallaCuentas> with TickerProviderStateMixin {
  final TextEditingController _busquedaController = TextEditingController();

  String _modoFiltro = 'ordenar';
  String _ordenSaldo = 'desc';
  String _busquedaCuenta = '';
  String _busquedaNumero = '';

  final CuentasServicio _cuentasServicio = CuentasServicio();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _cuentasServicio.migrarCuentasDesdeColeccionRaiz();
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
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: const AppBarCuentas(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              ResumenFinanciero(cuentasServicio: _cuentasServicio),
              const SizedBox(height: 24),
              
              BarraBusquedaYFiltros(
                controller: _busquedaController,
                modoFiltro: _modoFiltro,
                ordenSaldo: _ordenSaldo,
                onChanged: (value) {
                  setState(() {
                    if (_modoFiltro == 'buscar') {
                      _busquedaNumero = value;
                    } else {
                      _busquedaCuenta = value;
                    }
                  });
                },
                onClear: () {
                  setState(() {
                    _busquedaController.clear();
                    _busquedaCuenta = '';
                    _busquedaNumero = '';
                  });
                },
                onFilterSelected: (value) {
                  setState(() {
                    if (value == 'ordenar_desc') {
                      _modoFiltro = 'ordenar';
                      _ordenSaldo = 'desc';
                    } else if (value == 'ordenar_asc') {
                      _modoFiltro = 'ordenar';
                      _ordenSaldo = 'asc';
                    } else if (value == 'buscar') {
                      _modoFiltro = 'buscar';
                    }
                    _busquedaController.text = '';
                    _busquedaCuenta = '';
                    _busquedaNumero = '';
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cuentas registradas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    GestureDetector(
                      onTap: _mostrarDialogoAgregarCuenta,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007bff),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.add, color: Colors.white, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Nueva cuenta',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListaCuentasBuilder(
                  cuentasServicio: _cuentasServicio,
                  busquedaCuenta: _busquedaCuenta,
                  busquedaNumero: _busquedaNumero,
                  modoFiltro: _modoFiltro,
                  ordenSaldo: _ordenSaldo,
                  onCuentaTap: _mostrarDetallesCuenta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarCuenta() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FormularioCuenta(onCuentaAgregada: () => setState(() {})),
      ),
    );
  }

  void _mostrarDetallesCuenta(String id, Map<String, dynamic> cuenta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetalleCuenta(
        cuentaId: id,
        cuenta: cuenta,
        onEditar: () => _mostrarDialogoEditarCuenta(id, cuenta),
        onEliminar: () => _confirmarEliminarCuenta(id, 'esta cuenta'),
      ),
    );
  }

  void _mostrarDialogoEditarCuenta(String id, Map<String, dynamic> cuenta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FormularioCuenta(
          cuentaId: id,
          cuentaExistente: cuenta,
          onCuentaAgregada: () => setState(() {}),
        ),
      ),
    );
  }

  Future<void> _confirmarEliminarCuenta(String id, String nombre) async {
    final bool? confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar cuenta'),
        content: Text('¿Estás seguro de que deseas eliminar $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      try {
        final error = await _cuentasServicio.eliminarCuentaPermanente(id);
        if (mounted) {
          if (error == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$nombre eliminada correctamente'), backgroundColor: const Color(0xFF007bff)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $error'), backgroundColor: const Color(0xFF007bff)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar la cuenta'), backgroundColor: Color(0xFF007bff)),
          );
        }
      }
    }
  }
}