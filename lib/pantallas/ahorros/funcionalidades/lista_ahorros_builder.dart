// 5. Lógica de Stream y filtros para la lista de ahorros
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/AhorroService/ahorros_servicio.dart';
import 'tarjeta_meta.dart';
import 'estados_ahorros.dart';
import 'utils_ahorros.dart';

class ListaAhorrosBuilder extends StatelessWidget {
  final AhorrosServicio ahorrosServicio;
  final String busquedaMeta;
  final String modoFiltro;
  final Function(String id, Map<String, dynamic> meta) onTap;
  final Function(String accion, String id, Map<String, dynamic> meta) onAccion;

  const ListaAhorrosBuilder({
    super.key,
    required this.ahorrosServicio,
    required this.busquedaMeta,
    required this.modoFiltro,
    required this.onTap,
    required this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ahorrosServicio.obtenerMetasAhorro(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(UtilsAhorros.colorPrincipal),
            ),
          );
        }
        if (snapshot.hasError) {
          return const EstadoAhorrosError();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EstadoAhorrosVacio();
        }

        // Filtrado
        var metas = snapshot.data!;
        
        if (busquedaMeta.isNotEmpty) {
          metas = metas.where((meta) {
            final nombre = (meta['nombre'] ?? '').toString().toLowerCase();
            final categoria = (meta['categoria'] ?? '').toString().toLowerCase();
            return nombre.contains(busquedaMeta.toLowerCase()) || 
                   categoria.contains(busquedaMeta.toLowerCase());
          }).toList();
        }

        if (modoFiltro == 'activas') {
          metas = metas.where((meta) {
            final montoActual = (meta['montoActual'] ?? 0.0).toDouble();
            final montoObjetivo = (meta['montoObjetivo'] ?? 0.0).toDouble();
            return montoActual < montoObjetivo;
          }).toList();
        } else if (modoFiltro == 'completadas') {
          metas = metas.where((meta) {
            final montoActual = (meta['montoActual'] ?? 0.0).toDouble();
            final montoObjetivo = (meta['montoObjetivo'] ?? 0.0).toDouble();
            return montoActual >= montoObjetivo;
          }).toList();
        }

        // Ordenar por fecha de creación (más recientes primero)
        metas.sort((a, b) {
          final fechaA = a['fechaCreacion'] is Timestamp
              ? (a['fechaCreacion'] as Timestamp).toDate()
              : a['fechaCreacion'] as DateTime?;
          final fechaB = b['fechaCreacion'] is Timestamp
              ? (b['fechaCreacion'] as Timestamp).toDate()
              : b['fechaCreacion'] as DateTime?;
          if (fechaA == null && fechaB == null) return 0;
          if (fechaA == null) return 1;
          if (fechaB == null) return -1;
          return fechaB.compareTo(fechaA);
        });

        if (metas.isEmpty) {
          return const EstadoSinResultadosBusqueda();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: metas.length,
          itemBuilder: (context, index) {
            final meta = metas[index];
            final id = meta['id'] as String;
            return TarjetaMeta(
              id: id,
              meta: meta,
              index: index,
              onTap: () => onTap(id, meta),
              onAccionSeleccionada: (accion, meta) => onAccion(accion, id, meta),
            );
          },
        );
      },
    );
  }
}