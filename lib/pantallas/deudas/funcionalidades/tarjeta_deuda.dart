// Diseño y visualización de cada ítem de deuda en la lista.
import 'package:flutter/material.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_deudas.dart';

class TarjetaDeuda extends StatelessWidget {
  final Map<String, dynamic> deuda;
  final int index;
  final VoidCallback onTap;

  const TarjetaDeuda({
    super.key,
    required this.deuda,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorEstado = UtilsDeudas.obtenerColorEstado(deuda);
    final fechaVenc = deuda['fechaVencimiento'] as DateTime?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              UtilsDeudas.obtenerIconoTipoDeuda(deuda['tipo']),
              color: colorEstado,
              size: 20,
            ),
          ),
          title: Text(
            deuda['titulo'],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${deuda['tipo']} • ${deuda['acreedor']}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                fechaVenc != null ? '${fechaVenc.day}/${fechaVenc.month}/${fechaVenc.year}' : '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          trailing: SizedBox(
            width: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${FormatoNumeros.formatearParaMostrar(deuda['montoPendiente'])}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorEstado == const Color(0xFF10B981) ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
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