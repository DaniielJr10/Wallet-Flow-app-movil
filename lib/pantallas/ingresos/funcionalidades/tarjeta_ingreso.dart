/// TARJETA DE INGRESO
/// Componente visual que representa un ingreso individual en la lista.
/// Muestra icono de categoría, descripción, fecha y monto formateado.
import 'package:flutter/material.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_ingresos.dart';

class TarjetaIngreso extends StatelessWidget {
  final Map<String, dynamic> ingreso;
  final int index;
  final VoidCallback onTap;

  const TarjetaIngreso({
    super.key,
    required this.ingreso,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              UtilsIngresos.obtenerIconoCategoria(ingreso['categoria']),
              color: Colors.green.shade600,
              size: 24,
            ),
          ),
          title: Text(
            ingreso['descripcion'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: UtilsIngresos.colorTexto,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${UtilsIngresos.capitalizar(ingreso['categoria'])} • ${UtilsIngresos.capitalizar(ingreso['metodoPago'])}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                '${ingreso['fecha'].day}/${ingreso['fecha'].month}/${ingreso['fecha'].year}',
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
                    color: UtilsIngresos.colorPrincipal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}