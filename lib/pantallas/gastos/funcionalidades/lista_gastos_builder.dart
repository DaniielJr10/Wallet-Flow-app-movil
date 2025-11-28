// ListaGastosBuilder: Construye la lista de gastos usando Stream y lógica de filtrado.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/gastoService/gastos_servicio.dart';
import 'tarjeta_gasto.dart';
import 'estados_gastos.dart';

class ListaGastosBuilder extends StatelessWidget {
  final GastosServicio gastosServicio;
  final String textoBusqueda;
  final String modoBusqueda;
  final Function(Map<String, dynamic>) onTapGasto;
  final Function(String) onEliminarGasto;

  const ListaGastosBuilder({
    super.key,
    required this.gastosServicio,
    required this.textoBusqueda,
    required this.modoBusqueda,
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
          final busqueda = textoBusqueda.toLowerCase().trim();

          if (modoBusqueda == 'mes') {
            // Mapas simples de meses en español/abreviaturas a número
            final Map<String, int> meses = {
              'enero': 1, 'ene': 1,
              'febrero': 2, 'feb': 2,
              'marzo': 3, 'mar': 3,
              'abril': 4, 'abr': 4,
              'mayo': 5, 'may': 5,
              'junio': 6, 'jun': 6,
              'julio': 7, 'jul': 7,
              'agosto': 8, 'ago': 8,
              'septiembre': 9, 'sep': 9, 'set': 9,
              'octubre': 10, 'oct': 10,
              'noviembre': 11, 'nov': 11,
              'diciembre': 12, 'dic': 12,
            };

            int? mes;
            int? anio;

            // Intentar extraer formato "mes año" (ej: "noviembre 2024")
            final parts = busqueda.split(RegExp(r'\s+'));
            if (parts.isNotEmpty) {
              final posibleMes = parts[0].replaceAll('.', '');
              if (meses.containsKey(posibleMes)) mes = meses[posibleMes];
              // si hay segundo token y es año
              if (parts.length >= 2) {
                final posibleAnio = int.tryParse(parts[1]);
                if (posibleAnio != null && posibleAnio > 1900) anio = posibleAnio;
              }
              // también aceptar búsquedas por número de mes
              if (mes == null) {
                final asNum = int.tryParse(posibleMes);
                if (asNum != null && asNum >= 1 && asNum <= 12) mes = asNum;
              }
            }

            if (mes != null) {
              gastosFiltrados = gastos.where((gasto) {
                final fecha = gasto['fecha'] as DateTime?;
                if (fecha == null) return false;
                if (anio != null) return fecha.month == mes && fecha.year == anio;
                return fecha.month == mes;
              }).toList();
            } else {
              // Si no se pudo interpretar como mes, no hay resultados
              gastosFiltrados = [];
            }
          } else {
            // Búsqueda por categoría/descripcion por defecto
            gastosFiltrados = gastos.where((gasto) {
              final descripcion = (gasto['descripcion'] ?? '').toString().toLowerCase();
              final categoria = (gasto['categoria'] ?? '').toString().toLowerCase();
              return descripcion.contains(busqueda) || categoria.contains(busqueda);
            }).toList();
          }
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