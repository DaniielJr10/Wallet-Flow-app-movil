// ListaGastosBuilder: Construye la lista de gastos usando Stream y lógica de filtrado.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/gastos_servicio.dart';
import 'tarjeta_gasto.dart';
import 'estados_gastos.dart';

class ListaGastosBuilder extends StatelessWidget {
  final GastosServicio gastosServicio;
  final String textoBusqueda;
  final Function(Map<String, dynamic>) onTapGasto;
  final Function(String) onEliminarGasto;

  const ListaGastosBuilder({
    super.key,
    required this.gastosServicio,
    required this.textoBusqueda,
    required this.onTapGasto,
    required this.onEliminarGasto,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: gastosServicio.obtenerGastos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return EstadoGastosError(error: snapshot.error.toString());
        }
        
        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const EstadoGastosVacio();
        }
        
        // Procesamiento de datos
        final gastos = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          // Conversiones de seguridad
          if (data['fecha'] is Timestamp) {
            data['fecha'] = (data['fecha'] as Timestamp).toDate();
          }
          data['descripcion'] = data['descripcion'] ?? 'Sin descripción';
          data['monto'] = (data['monto'] as num?)?.toDouble() ?? 0.0;
          data['categoria'] = data['categoria'] ?? 'otro';
          data['metodoPago'] = data['metodoPago'] ?? 'efectivo';
          data['fecha'] = data['fecha'] ?? DateTime.now();
          return data;
        }).toList();

        // Filtrado
        List<Map<String, dynamic>> gastosFiltrados = gastos;
        if (textoBusqueda.isNotEmpty) {
          gastosFiltrados = gastos.where((gasto) {
            final descripcion = (gasto['descripcion'] ?? '').toString().toLowerCase();
            final categoria = (gasto['categoria'] ?? '').toString().toLowerCase();
            final busqueda = textoBusqueda.toLowerCase();
            return descripcion.contains(busqueda) || categoria.contains(busqueda);
          }).toList();
        }

        if (gastosFiltrados.isEmpty && textoBusqueda.isNotEmpty) {
          return const EstadoSinResultadosBusqueda();
        }

        // Ordenar por fecha descendente
        gastosFiltrados.sort((a, b) => b['fecha'].compareTo(a['fecha']));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gastosFiltrados.length,
          itemBuilder: (context, index) {
            final gasto = gastosFiltrados[index];
            return TarjetaGasto(
              gasto: gasto,
              index: index,
              onTap: () => onTapGasto(gasto),
              onEliminar: () => onEliminarGasto(gasto['id']),
            );
          },
        );
      },
    );
  }
}