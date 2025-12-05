// Diálogos y alertas de confirmación para acciones sobre deudas.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/CuentaService/cuentas_servicio.dart';
import '../../../utilidades/formato_numeros.dart';

class DialogoConfirmarEliminarDeuda extends StatelessWidget {
  final String tituloDeuda;
  final VoidCallback onConfirmar;

  const DialogoConfirmarEliminarDeuda({
    super.key,
    required this.tituloDeuda,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning, color: Colors.red),
          ),
          const SizedBox(width: 12),
          const Text('Eliminar Deuda'),
        ],
      ),
      content: Text(
        '¿Estás seguro de que deseas eliminar la deuda "$tituloDeuda"?\n\nEsta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirmar();
          },
          child: const Text(
            'Eliminar',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}

/// Diálogo para registrar un pago de deuda
class DialogoPagoDeuda extends StatefulWidget {
  final Map<String, dynamic> deuda;
  final VoidCallback onPagoRegistrado;

  const DialogoPagoDeuda({
    super.key,
    required this.deuda,
    required this.onPagoRegistrado,
  });

  @override
  State<DialogoPagoDeuda> createState() => _DialogoPagoDeudaState();
}

class _DialogoPagoDeudaState extends State<DialogoPagoDeuda> {
  final TextEditingController _montoCtrl = TextEditingController();
  final CuentasServicio _cuentasServicio = CuentasServicio();
  String _cuentaSeleccionada = 'ninguna';

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con gradiente
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.payment,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Registrar pago',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saldo pendiente destacado
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFFF97316),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saldo pendiente',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                FormatoNumeros.formatearParaMostrar(widget.deuda['montoPendiente']),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF97316),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Selector de cuentas
                  StreamBuilder<QuerySnapshot>(
                    stream: _cuentasServicio.obtenerCuentas(),
                    builder: (context, snapshot) {
                      final items = <DropdownMenuItem<String>>[];
                      items.add(const DropdownMenuItem(
                        value: 'ninguna',
                        child: Text('Selecciona una cuenta'),
                      ));
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (data['activa'] == true) {
                            final label = data['tipo'] == 'dinero_en_mano'
                                ? 'Dinero en mano'
                                : '${data['banco'] ?? ''} - ${data['numeroCuenta'] ?? ''}';
                            items.add(DropdownMenuItem(
                              value: doc.id,
                              child: Text(label),
                            ));
                          }
                        }
                      }

                      // mostrar saldo disponible de la cuenta seleccionada
                      String? saldoCuentaTexto;
                      if (snapshot.hasData && _cuentaSeleccionada != 'ninguna') {
                        try {
                          final doc = snapshot.data!.docs.firstWhere(
                            (d) => d.id == _cuentaSeleccionada,
                          );
                          final data = doc.data() as Map<String, dynamic>;
                          saldoCuentaTexto = FormatoNumeros.formatearParaMostrar(
                            (data['saldo'] ?? 0).toDouble(),
                          );
                        } catch (_) {
                          saldoCuentaTexto = null;
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cuenta desde la que pagar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _cuentaSeleccionada,
                              items: items,
                              onChanged: (v) {
                                setState(() {
                                  _cuentaSeleccionada = v ?? 'ninguna';
                                });
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              icon: const Icon(Icons.arrow_drop_down),
                            ),
                          ),
                          if (saldoCuentaTexto != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Saldo disponible: $saldoCuentaTexto',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Campo de monto
                  const Text(
                    'Monto a pagar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _montoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFF97316)),
                      hintText: '0.00',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFF97316),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final raw = _montoCtrl.text.replaceAll(',', '.').replaceAll('\$', '').trim();
                            final pago = double.tryParse(raw) ?? 0.0;
                            if (pago <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ingresa un monto válido')),
                              );
                              return;
                            }
                            if (_cuentaSeleccionada == 'ninguna') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Selecciona una cuenta')),
                              );
                              return;
                            }

                            Navigator.of(context).pop({
                              'monto': pago,
                              'cuentaId': _cuentaSeleccionada,
                            });
                          },
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text(
                            'Confirmar Pago',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}