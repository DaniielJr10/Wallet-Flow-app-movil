/// VISUALIZADOR DE DETALLES
/// Modal que muestra la información completa de un ingreso.
/// Incluye la carga asíncrona del nombre de la cuenta asociada y
/// los botones para disparar la edición o eliminación.
import 'package:flutter/material.dart';
import '../../../firebase/servicios/CuentaService/cuentas_servicio.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_ingresos.dart';
import 'frecuencia.dart';

class DetalleIngreso extends StatelessWidget {
  final Map<String, dynamic> ingreso;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final CuentasServicio _cuentasServicio = CuentasServicio();

  DetalleIngreso({
    super.key,
    required this.ingreso,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [UtilsIngresos.colorPrincipal, UtilsIngresos.colorSecundario],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(UtilsIngresos.obtenerIconoCategoria(ingreso['categoria']), color: Colors.white, size: 24),
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
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
                ),
              ],
            ),
          ),
          // Info
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: UtilsIngresos.colorPrincipal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: UtilsIngresos.colorPrincipal, width: 2),
                      ),
                      child: Text(
                        '\$${FormatoNumeros.formatearParaMostrar(ingreso['monto'])}',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: UtilsIngresos.colorPrincipal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildDetalleItem('Descripción', ingreso['descripcion'], Icons.description_outlined),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Categoría', UtilsIngresos.capitalizar(ingreso['categoria']), Icons.category_outlined),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Método de Pago', UtilsIngresos.capitalizar(ingreso['metodoPago']), Icons.payment_outlined),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Fecha', '${ingreso['fecha'].day} de ${UtilsIngresos.getNombreMes(ingreso['fecha'].month)} de ${ingreso['fecha'].year}', Icons.calendar_today_outlined),
                  const SizedBox(height: 20),
                  _buildCuentaAsociada(),
                  const SizedBox(height: 20),
                  _buildFrecuenciaInfo(),
                ],
              ),
            ),
          ),
          // Botones
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
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

  Widget _buildDetalleItem(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: UtilsIngresos.colorPrincipal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icono, color: UtilsIngresos.colorPrincipal, size: 20),
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
    if (ingreso['cuentaAsociada'] == null || ingreso['cuentaAsociada'] == 'ninguna') {
      return _buildDetalleItem('Cuenta Asociada', 'Ninguna cuenta asociada', Icons.account_balance_outlined);
    }
    return FutureBuilder(
      future: _cuentasServicio.obtenerCuentaPorId(ingreso['cuentaAsociada']),
      builder: (context, snapshot) {
        String texto = 'Cargando...';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          texto = '${data['banco']} - ${data['numeroCuenta']}';
        } else if (snapshot.connectionState == ConnectionState.done) {
          texto = 'No se encontró la cuenta';
        }
        return _buildDetalleItem('Cuenta Asociada', texto, Icons.account_balance_outlined);
      },
    );
  }

  Widget _buildFrecuenciaInfo() {
    // Verificar si el ingreso tiene frecuencia configurada
    if (!ingreso.containsKey('tieneRepeticion') || 
        ingreso['tieneRepeticion'] != true ||
        ingreso['frecuencia'] == null) {
      return _buildDetalleItem(
        'Frecuencia', 
        'Ingreso único', 
        Icons.event_outlined
      );
    }

    // Si tiene frecuencia, mostrar la información
    final frecuencia = FrecuenciaUtils.desdeString(ingreso['frecuencia']);
    String textoFrecuencia = FrecuenciaUtils.obtenerNombre(frecuencia ?? TipoFrecuencia.ninguna);
    
    // Información adicional sobre la próxima creación
    if (ingreso.containsKey('proximaCreacion')) {
      final proximaFecha = ingreso['proximaCreacion'] is DateTime 
          ? ingreso['proximaCreacion'] as DateTime
          : (ingreso['proximaCreacion']).toDate();
      
      textoFrecuencia += ' - Próximo: ${proximaFecha.day}/${proximaFecha.month}/${proximaFecha.year}';
    }

    return _buildDetalleItem(
      'Frecuencia',
      textoFrecuencia,
      Icons.repeat
    );
  }
}