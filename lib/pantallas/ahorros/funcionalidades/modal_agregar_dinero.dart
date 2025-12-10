/// MODAL AGREGAR DINERO AL AHORRO
/// Modal simple             content: Text('¡\$${FormatoNumeros.formatearNumero(monto)} agregado exitosamente!'),ara que el usuario ingrese la cantidad de dinero a agregar a un ahorro existente

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utilidades/formato_numeros.dart';
import '../../../firebase/servicios/AhorroService/ahorros_servicio.dart';
import 'utils_ahorros.dart';

class ModalAgregarDinero extends StatefulWidget {
  final String ahorroId;
  final Map<String, dynamic> ahorro;
  final Function() onSuccess;

  const ModalAgregarDinero({
    super.key,
    required this.ahorroId,
    required this.ahorro,
    required this.onSuccess,
  });

  @override
  State<ModalAgregarDinero> createState() => _ModalAgregarDineroState();
}

class _ModalAgregarDineroState extends State<ModalAgregarDinero> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _agregarDinero() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final monto = double.parse(_montoController.text.replaceAll(',', ''));
      
      await AhorrosServicio().agregarMontoMeta(
        metaId: widget.ahorroId, 
        montoAgregar: monto,
      );
      
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡\$${FormatoNumeros.formatearNumero(monto)} agregado exitosamente!'),
            backgroundColor: UtilsAhorros.colorPrincipal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar dinero: $e'),
            backgroundColor: UtilsAhorros.colorPrincipal,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final montoActual = (widget.ahorro['montoActual'] ?? 0).toDouble();
    final metaMonto = (widget.ahorro['montoObjetivo'] ?? widget.ahorro['metaMonto'] ?? 0).toDouble();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8570FA), 
                        const Color(0xFF8570FA).withOpacity(0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.savings, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Agregar dinero al ahorro',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.ahorro['nombre'] ?? 'Ahorro',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // Estado actual
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    '\$${FormatoNumeros.formatearNumero(montoActual)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8570FA),
                    ),
                  ),
                  Text(
                    'de \$${FormatoNumeros.formatearNumero(metaMonto)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Campo de monto
            TextFormField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  final number = int.tryParse(newValue.text);
                  if (number == null) return oldValue;
                  final formatted = number.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  );
                  return TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }),
              ],
              decoration: InputDecoration(
                labelText: 'Monto a agregar',
                prefixText: '\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa el monto a agregar';
                }
                final monto = double.tryParse(value.replaceAll(',', ''));
                if (monto == null || monto <= 0) {
                  return 'Ingresa un monto válido';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Botón agregar
            ElevatedButton(
              onPressed: _isLoading ? null : _agregarDinero,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8570FA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Agregar Dinero',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
