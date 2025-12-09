import 'package:flutter/material.dart';
import '../../firebase/servicios/AhorroService/ahorros_servicio.dart';

// Importación de funcionalidades
import 'funcionalidades/app_bar_ahorros.dart';
import 'funcionalidades/resumen_ahorros.dart';
import 'funcionalidades/barra_busqueda_ahorros.dart';
import 'funcionalidades/lista_ahorros_builder.dart';
import 'funcionalidades/formulario_meta.dart';
import 'funcionalidades/detalle_meta.dart';
import 'funcionalidades/utils_ahorros.dart';

class PantallaAhorros extends StatefulWidget {
  const PantallaAhorros({super.key});

  @override
  State<PantallaAhorros> createState() => _PantallaAhorrosState();
}

class _PantallaAhorrosState extends State<PantallaAhorros> with TickerProviderStateMixin {
  final TextEditingController _busquedaController = TextEditingController();
  final AhorrosServicio _ahorrosServicio = AhorrosServicio();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _modoFiltro = 'todas';
  String _busquedaMeta = '';

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
      appBar: const AppBarAhorros(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              ResumenAhorros(ahorrosServicio: _ahorrosServicio),
              const SizedBox(height: 24),
              BarraBusquedaAhorros(
                controller: _busquedaController,
                modoFiltro: _modoFiltro,
                onChanged: (value) => setState(() => _busquedaMeta = value),
                onClear: () => setState(() {
                  _busquedaController.clear();
                  _busquedaMeta = '';
                }),
                onFilterSelected: (value) => setState(() {
                  _modoFiltro = value;
                  _busquedaController.text = '';
                  _busquedaMeta = '';
                }),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mis ahorros',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _mostrarDialogoAgregarMeta(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: UtilsAhorros.colorPrincipal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.add, color: Colors.white, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Nuevo ahorro',
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
                child: ListaAhorrosBuilder(
                  ahorrosServicio: _ahorrosServicio,
                  busquedaMeta: _busquedaMeta,
                  modoFiltro: _modoFiltro,
                  onTap: _mostrarDetallesMeta,
                  onAccion: _manejarAccionMeta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarMeta({bool esEdicion = false, String? metaId, Map<String, dynamic>? meta}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FormularioMeta(
          esEdicion: esEdicion,
          metaId: metaId,
          meta: meta,
          onGuardarExitoso: () => setState(() {}),
        ),
      ),
    );
  }

  void _mostrarDetallesMeta(String metaId, Map<String, dynamic> meta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetalleMeta(
        metaId: metaId,
        meta: meta,
        onEditar: () => _mostrarDialogoAgregarMeta(esEdicion: true, metaId: metaId, meta: meta),
        onEliminar: () => _confirmarEliminarMeta(metaId, meta['nombre'] ?? 'esta meta'),
      ),
    );
  }

  void _manejarAccionMeta(String accion, String id, Map<String, dynamic> meta) {
    switch (accion) {
      case 'agregar':
        _mostrarDialogoAgregarMonto(id, meta);
        break;
      case 'editar':
        _mostrarDialogoAgregarMeta(esEdicion: true, metaId: id, meta: meta);
        break;
      case 'eliminar':
        _confirmarEliminarMeta(id, meta['nombre'] ?? 'esta meta');
        break;
    }
  }

  void _mostrarDialogoAgregarMonto(String metaId, Map<String, dynamic> meta) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agregar dinero a: ${meta['nombre'] ?? 'Meta sin nombre'}'),
        backgroundColor: UtilsAhorros.colorPrincipal,
      ),
    );
  }

  Future<void> _confirmarEliminarMeta(String id, String nombre) async {
    final bool? confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar meta'),
        content: Text('¿Estás seguro de que deseas eliminar la meta "$nombre"?'),
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
      final error = await _ahorrosServicio.eliminarMetaAhorro(id);
      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Meta "$nombre" eliminada correctamente'),
              backgroundColor: UtilsAhorros.colorPrincipal,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}