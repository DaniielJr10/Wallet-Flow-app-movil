/// BUILDER DE LISTA
/// Maneja el Stream de datos de Firebase, aplica los filtros de búsqueda
/// (categoría o mes) y decide qué estado mostrar (Lista, Vacío, Error).
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/ingresos_servicio.dart';
import 'tarjeta_ingreso.dart';
import 'estados_ingresos.dart';
import 'utils_ingresos.dart';

class ListaIngresosBuilder extends StatelessWidget {
  final IngresosServicio ingresosServicio;
  final String busqueda;
  final String modoBusqueda;
  final Function(Map<String, dynamic>) onTapIngreso;

  const ListaIngresosBuilder({
    super.key,
    required this.ingresosServicio,
    required this.busqueda,
    required this.modoBusqueda,
    required this.onTapIngreso,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ingresosServicio.obtenerIngresos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const EstadoIngresosError();
        }

        final ingresos = snapshot.data ?? [];
        final ingresosFiltrados = _aplicarFiltros(ingresos);

        if (ingresos.isEmpty) {
          return const EstadoIngresosVacio();
        }
        
        if (ingresosFiltrados.isEmpty && busqueda.isNotEmpty) {
          // Si hay ingresos pero el filtro no encuentra nada
           return const EstadoIngresosVacio(mensaje: 'No se encontraron coincidencias');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ingresosFiltrados.length,
          itemBuilder: (context, index) {
            final ingreso = ingresosFiltrados[index];
            return TarjetaIngreso(
              ingreso: ingreso,
              index: index,
              onTap: () => onTapIngreso(ingreso),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _aplicarFiltros(List<Map<String, dynamic>> ingresos) {
    if (busqueda.isEmpty) return ingresos;

    return ingresos.where((ingreso) {
      bool coincide = true;
      if (modoBusqueda == 'categoría') {
        final categoria = ingreso['categoria']?.toString().toLowerCase() ?? '';
        coincide = categoria.contains(busqueda.toLowerCase());
      } else if (modoBusqueda == 'mes') {
        final fecha = ingreso['fecha'] as DateTime;
        final mesIngreso = UtilsIngresos.getNombreMes(fecha.month);
        coincide = mesIngreso.contains(busqueda.toLowerCase());
      }
      return coincide;
    }).toList();
  }
}