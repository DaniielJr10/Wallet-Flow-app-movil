// DetalleGasto: Modal que muestra los detalles completos de un gasto.
import 'package:flutter/material.dart';
import '../../../firebase/servicios/cuentas_servicio.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_gastos.dart';

class DetalleGasto extends StatelessWidget {
  final Map<String, dynamic> gasto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final CuentasServicio _cuentasServicio = CuentasServicio();

  DetalleGasto({
    super.key,
    required this.gasto,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [UtilsGastos.colorPrincipal, UtilsGastos.colorSecundario],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(UtilsGastos.obtenerIconoCategoria(gasto['categoria']), color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Detalles del Gasto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text(gasto['descripcion'], style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: UtilsGastos.colorPrincipal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: UtilsGastos.colorPrincipal, width: 2),
                      ),
                      child: Text(
                        '-${FormatoNumeros.formatearParaMostrar(gasto['monto'])}',
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: UtilsGastos.colorPrincipal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _detalleItem('Descripción', gasto['descripcion'], Icons.description_outlined),
                  const SizedBox(height: 20),
                  _detalleItem('Categoría', UtilsGastos.capitalizar(gasto['categoria']), Icons.category_outlined),
                  const SizedBox(height: 20),
                  _detalleItem('Método de Pago', UtilsGastos.capitalizar(gasto['metodoPago']), Icons.payment_outlined),
                  const SizedBox(height: 20),
                  _detalleItem('Fecha', '${gasto['fecha'].day} de ${UtilsGastos.getNombreMes(gasto['fecha'].month)} de ${gasto['fecha'].year}', Icons.calendar_today_outlined),
                  const SizedBox(height: 20),
                  _buildCuentaAsociada(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); onEditar(); },
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); onEliminar(); },
                    icon: const Icon(Icons.delete_rounded, size: 20),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detalleItem(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: UtilsGastos.colorPrincipal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icono, color: UtilsGastos.colorPrincipal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuentaAsociada() {
    if (gasto['cuentaAsociada'] == null || gasto['cuentaAsociada'] == 'ninguna') {
      return _detalleItem('Cuenta Asociada', 'Ninguna cuenta asociada', Icons.account_balance_outlined);
    }
    return FutureBuilder(
      future: _cuentasServicio.obtenerCuentaPorId(gasto['cuentaAsociada']),
      builder: (context, snapshot) {
        String texto = 'Cargando...';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          texto = '${data['banco']} - ${data['numeroCuenta']}';
        } else if (snapshot.hasError || (snapshot.hasData && !snapshot.data!.exists)) {
          texto = 'Cuenta no encontrada';
        }
        return _detalleItem('Cuenta Asociada', texto, Icons.account_balance_outlined);
      },
    );
  }
}