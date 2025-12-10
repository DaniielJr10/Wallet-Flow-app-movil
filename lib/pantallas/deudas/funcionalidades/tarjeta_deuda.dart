// Diseño y visualización de cada ítem de deuda en la lista.
import 'package:flutter/material.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_deudas.dart';

class TarjetaDeuda extends StatelessWidget {
  final Map<String, dynamic> deuda;
  final int index;
  final VoidCallback onTap;
  final void Function(Map<String, dynamic>)? onPagar;

  const TarjetaDeuda({
    super.key,
    required this.deuda,
    required this.index,
    required this.onTap,
    this.onPagar,
  });

  @override
  Widget build(BuildContext context) {
    final colorEstado = UtilsDeudas.obtenerColorEstado(deuda);
    final fechaVenc = deuda['fechaVencimiento'] as DateTime?;
    final esPagada = (deuda['estado'] ?? '') == 'Pagada';
    final montoPendiente = (deuda['montoPendiente'] ?? 0).toDouble();

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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono de categoría
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  UtilsDeudas.obtenerIconoTipoDeuda(deuda['tipo']),
                  color: colorEstado,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Información de la deuda
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deuda['titulo'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deuda['tipo']} • ${deuda['acreedor']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          fechaVenc != null
                              ? '${fechaVenc.day}/${fechaVenc.month}/${fechaVenc.year}'
                              : 'Sin fecha',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Monto y botón de acción
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-\$${FormatoNumeros.formatearParaMostrar(montoPendiente)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: esPagada ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  
                  // Botón de pagar o indicador de pagada
                  // Si la deuda está pagada o no hay monto pendiente, mostrar el indicador correspondiente
                  if (esPagada || montoPendiente <= 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          const Text(
                            'Pagada',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}