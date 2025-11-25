import 'package:flutter/material.dart';
import '../../../../utilidades/formato_numeros.dart';
import '../../../../firebase/servicios/cuentas_servicio.dart';
import 'utils_ingresos.dart';

class DetalleIngresoModal extends StatelessWidget {
  final Map<String, dynamic> ingreso;
  final Function(Map<String, dynamic>) onEditar;
  final Function(Map<String, dynamic>) onEliminar;

  DetalleIngresoModal({super.key, required this.ingreso, required this.onEditar, required this.onEliminar});

  final CuentasServicio _cuentasServicio = CuentasServicio();

  @override
  Widget build(BuildContext context) {
    // Usar Timestamp o DateTime segun venga de Firebase
    final fechaObj = ingreso['fecha'];
    final DateTime fecha = fechaObj is DateTime ? fechaObj : fechaObj.toDate();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2ecc71), Color(0xFF27ae60)],
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(UtilsIngresos.getIconoCategoria(ingreso['categoria']), color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Detalles del Ingreso', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text(ingreso['descripcion'], style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
                        color: const Color(0xFF2ecc71).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2ecc71), width: 2),
                      ),
                      child: Text(
                        '\$${FormatoNumeros.formatearParaMostrar(ingreso['monto'])}',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFF2ecc71)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildDetalleItem('Descripción', ingreso['descripcion'], Icons.description_outlined),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Categoría', '${ingreso['categoria'].toString().substring(0, 1).toUpperCase()}${ingreso['categoria'].toString().substring(1)}', Icons.category_outlined),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Método de Pago', '${ingreso['metodoPago'].toString().substring(0, 1).toUpperCase()}${ingreso['metodoPago'].toString().substring(1)}', Icons.payment_outlined),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Fecha', '${fecha.day} de ${UtilsIngresos.getNombreMes(fecha.month)} de ${fecha.year}', Icons.calendar_today_outlined),
                  const SizedBox(height: 20),
                  _buildCuentaAsociada(ingreso['cuentaAsociada']),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25))),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); onEditar(ingreso); },
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); onEliminar(ingreso); },
                    icon: const Icon(Icons.delete_rounded, size: 20),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleItem(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2ecc71).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icono, color: const Color(0xFF2ecc71), size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600, letterSpacing: 0.5)), const SizedBox(height: 4), Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)))])),
        ],
      ),
    );
  }

  Widget _buildCuentaAsociada(String? cuentaId) {
    if (cuentaId == null || cuentaId == 'ninguna') return _buildDetalleItem('Cuenta Asociada', 'Ninguna cuenta asociada', Icons.account_balance_outlined);
    return FutureBuilder(
      future: _cuentasServicio.obtenerCuentaPorId(cuentaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) return _buildDetalleItem('Cuenta Asociada', 'Cuenta no encontrada', Icons.account_balance_outlined);
        final cuenta = snapshot.data!.data() as Map<String, dynamic>;
        return _buildDetalleItem('Cuenta Asociada', '${cuenta['banco']} - ${cuenta['numeroCuenta']}', Icons.account_balance_outlined);
      },
    );
  }
}