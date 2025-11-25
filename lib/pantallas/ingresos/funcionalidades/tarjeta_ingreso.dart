import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utilidades/formato_numeros.dart';
import 'utils_ingresos.dart';

class TarjetaIngreso extends StatelessWidget {
  final Map<String, dynamic> ingreso;
  final VoidCallback onTap;

  const TarjetaIngreso({super.key, required this.ingreso, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fecha = ingreso['fecha'] is Timestamp 
        ? (ingreso['fecha'] as Timestamp).toDate() 
        : ingreso['fecha'] as DateTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              UtilsIngresos.getIconoCategoria(ingreso['categoria']),
              color: Colors.green.shade600,
              size: 24,
            ),
          ),
          title: Text(
            ingreso['descripcion'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${ingreso['categoria'].toString().substring(0, 1).toUpperCase()}${ingreso['categoria'].toString().substring(1)} • ${ingreso['metodoPago'].toString().substring(0, 1).toUpperCase()}${ingreso['metodoPago'].toString().substring(1)}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                '${fecha.day}/${fecha.month}/${fecha.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          trailing: SizedBox(
            width: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${FormatoNumeros.formatearParaMostrar(ingreso['monto'])}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2ecc71),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}