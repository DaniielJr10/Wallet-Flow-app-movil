/// DISEÑO DE NOTA INDIVIDUAL
/// Representa una nota en la grilla. Muestra el contenido truncado,
/// las etiquetas (tags), la fecha y el botón de eliminar.
import 'package:flutter/material.dart';
import 'utils_notas.dart';

class TarjetaNota extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TarjetaNota({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final text = (note['text'] as String?) ?? '';
    final tags = ((note['tags'] as List<dynamic>?) ?? []).cast<String>();
    final date = (note['date'] as String?) ?? DateTime.now().toIso8601String();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: UtilsNotas.colorCardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: UtilsNotas.colorSombra,
              blurRadius: 14,
              offset: const Offset(0, 8),
            )
          ],
          border: Border.all(color: UtilsNotas.colorBorde),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: tag pill + delete
            Row(
              children: [
                if (tags.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: UtilsNotas.colorTagBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: UtilsNotas.colorBorde),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.label, size: 14, color: UtilsNotas.colorPrincipal),
                        const SizedBox(width: 6),
                        Text(
                          '#${tags.first}',
                          style: const TextStyle(
                            color: UtilsNotas.colorPrincipal,
                            fontWeight: FontWeight.w700,
                            fontSize: 12, // Añadido fontSize para evitar error de layout
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(),
                const Spacer(),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: UtilsNotas.colorDelete,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Note Content
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: UtilsNotas.colorTextoOscuro,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 4, // Limitado para que no desborde
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            // Date Footer
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                UtilsNotas.formatDate(date),
                style: const TextStyle(
                  fontSize: 12,
                  color: UtilsNotas.colorTextoGris,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}