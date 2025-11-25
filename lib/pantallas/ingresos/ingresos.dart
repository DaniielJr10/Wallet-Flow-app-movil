import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase/servicios/ingresos_servicio.dart';
import 'funcionalidades/formulario_ingreso.dart';
import 'funcionalidades/detalle_ingreso.dart';
import 'funcionalidades/resumen_ingresos.dart';
import 'funcionalidades/filtros_ingresos.dart';
import 'funcionalidades/tarjeta_ingreso.dart';
import 'funcionalidades/utils_ingresos.dart';

class PantallaIngresos extends StatefulWidget {
  const PantallaIngresos({super.key});

  @override
  State<PantallaIngresos> createState() => _PantallaIngresosState();
}

class _PantallaIngresosState extends State<PantallaIngresos> with SingleTickerProviderStateMixin {
  final IngresosServicio _ingresosServicio = IngresosServicio();
  
  // Estado de filtros
  String _busqueda = '';
  String _modoBusqueda = 'categoría';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // --- NAVEGACIÓN Y MODALES ---

  void _mostrarFormulario([Map<String, dynamic>? ingreso]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FormularioIngresoModal(ingresoAEditar: ingreso),
    );
  }

  void _mostrarDetalles(Map<String, dynamic> ingreso) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetalleIngresoModal(
        ingreso: ingreso,
        onEditar: (ing) => _mostrarFormulario(ing),
        onEliminar: _confirmarEliminar,
      ),
    );
  }

  void _confirmarEliminar(Map<String, dynamic> ingreso) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ingreso'),
        content: const Text('¿Estás seguro de que deseas eliminar este ingreso? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await _ingresosServicio.eliminarIngreso(ingreso['id']);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Ingreso eliminado correctamente'), backgroundColor: Colors.red.shade600));
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // --- FILTRADO DE LISTA ---
  List<Map<String, dynamic>> _aplicarFiltros(List<Map<String, dynamic>> ingresos) {
    if (_busqueda.isEmpty) return ingresos;

    return ingresos.where((ingreso) {
      if (_modoBusqueda == 'categoría') {
        return ingreso['categoria'].toString().toLowerCase().contains(_busqueda.toLowerCase());
      } else {
        // Filtrado por mes
        final fecha = ingreso['fecha'] is Timestamp ? (ingreso['fecha'] as Timestamp).toDate() : ingreso['fecha'] as DateTime;
        final nombreMes = UtilsIngresos.getNombreMes(fecha.month);
        return nombreMes.toLowerCase().contains(_busqueda.toLowerCase());
      }
    }).toList();
  }

  // --- BUILD UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF27ae60)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'INGRESOS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF27ae60),
            letterSpacing: 2.2,
            fontFamily: 'Montserrat',
            height: 1.1,
            shadows: [
              Shadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResumenIngresos(),
              const SizedBox(height: 24),
              
              // Buscador
              FiltrosIngresos(
                busqueda: _busqueda,
                onBusquedaChanged: (val) => setState(() => _busqueda = val),
                modoBusqueda: _modoBusqueda,
                onModoChanged: (val) => setState(() => _modoBusqueda = val),
              ),
              
              const SizedBox(height: 32),
              
              // Header Lista
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Historial de Ingresos',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarFormulario(),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Nuevo ingreso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ecc71),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Lista de Ingresos
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _ingresosServicio.obtenerIngresos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return const Center(child: Text('Error al cargar ingresos'));
                  
                  final ingresos = snapshot.data ?? [];
                  final ingresosFiltrados = _aplicarFiltros(ingresos);

                  if (ingresosFiltrados.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(24)),
                            child: Icon(Icons.attach_money_rounded, size: 64, color: Colors.green.shade300),
                          ),
                          const SizedBox(height: 24),
                          Text('No hay ingresos registrados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ingresosFiltrados.length,
                    itemBuilder: (context, index) {
                      final ingreso = ingresosFiltrados[index];
                      return TarjetaIngreso(
                        ingreso: ingreso,
                        onTap: () => _mostrarDetalles(ingreso),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}