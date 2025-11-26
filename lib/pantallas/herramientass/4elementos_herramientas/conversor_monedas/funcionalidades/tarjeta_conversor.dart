/// FORMULARIO DE CONVERSIÓN
/// Contiene el input de cantidad, los selectores de moneda (Dropdowns),
/// el botón de intercambio (Swap) y el botón de acción (Convertir).
import 'package:flutter/material.dart';
import 'utils_conversor.dart';

class TarjetaConversor extends StatelessWidget {
  final TextEditingController amountController;
  final String fromCurrency;
  final String toCurrency;
  final bool isLoading;
  final Function(String?) onFromChanged;
  final Function(String?) onToChanged;
  final VoidCallback onSwap;
  final VoidCallback onConvert;

  const TarjetaConversor({
    super.key,
    required this.amountController,
    required this.fromCurrency,
    required this.toCurrency,
    required this.isLoading,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onSwap,
    required this.onConvert,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.green.shade400, width: 1.5),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Ingresa la cantidad',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: BorderSide(color: Colors.green.shade600, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('De', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    InputDecorator(
                      decoration: InputDecoration(
                        border: border,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: fromCurrency,
                          isExpanded: true,
                          items: UtilsConversor.currencies.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(UtilsConversor.getCurrencyLabel(c)),
                            );
                          }).toList(),
                          onChanged: onFromChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  InkWell(
                    onTap: onSwap,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: UtilsConversor.colorPrincipal,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('A', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    InputDecorator(
                      decoration: InputDecoration(
                        border: border,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: toCurrency,
                          isExpanded: true,
                          items: UtilsConversor.currencies.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(UtilsConversor.getCurrencyLabel(c)),
                            );
                          }).toList(),
                          onChanged: onToChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onConvert,
                  icon: const Icon(Icons.swap_vert, size: 20),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      isLoading ? 'Convirtiendo...' : 'Convertir',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UtilsConversor.colorPrincipal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}