/// ITEM INDIVIDUAL
/// Define el diseño visual de cada tarjeta de cuenta dentro de la lista.
/// Muestra el banco, número oculto, tipo y saldo formateado.
import 'package:flutter/material.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_cuentas.dart';

class TarjetaCuenta extends StatelessWidget {
  final String id;
  final Map<String, dynamic> cuenta;
  final int index;
  final VoidCallback onTap;

  const TarjetaCuenta({
    super.key,
    required this.id,
    required this.cuenta,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tipoCuenta = cuenta['tipo'] ?? 'ahorros';
    final saldo = (cuenta['saldo'] ?? 0.0).toDouble();
    final numeroCuenta = cuenta['numeroCuenta'] ?? '****';
    final banco = cuenta['banco'] ?? 'Banco';

    return Container(
      margin: EdgeInsets.only(
        bottom: 16,
        top: index == 0 ? 8 : 0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: UtilsCuentas.obtenerColorTipoCuenta(tipoCuenta).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        UtilsCuentas.obtenerIconoTipoCuenta(tipoCuenta),
                        color: UtilsCuentas.obtenerColorTipoCuenta(tipoCuenta),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banco,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D29),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            numeroCuenta,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D29),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: UtilsCuentas.obtenerColorTipoCuenta(tipoCuenta).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        UtilsCuentas.obtenerNombreTipoCuenta(tipoCuenta),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: UtilsCuentas.obtenerColorTipoCuenta(tipoCuenta),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo disponible',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${FormatoNumeros.formatearParaMostrar(saldo)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1D29),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}