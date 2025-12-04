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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              UtilsNotas.colorInputBg,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: UtilsNotas.colorPrincipal.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: UtilsNotas.colorBorde, width: 2),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: tag pill + delete
            Row(
              children: [
                if (tags.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          UtilsNotas.colorPrincipal.withOpacity(0.1),
                          UtilsNotas.colorSecundario.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: UtilsNotas.colorPrincipal.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.label_rounded, size: 14, color: UtilsNotas.colorPrincipal),
                        const SizedBox(width: 6),
                        Text(
                          '#${tags.first}',
                          style: TextStyle(
                            color: UtilsNotas.colorAccento,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: UtilsNotas.colorDelete.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_rounded,
                      color: UtilsNotas.colorDelete,
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Note Content
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: UtilsNotas.colorTextoOscuro,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            // Date Footer with icon
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: UtilsNotas.colorTextoGris,
                ),
                const SizedBox(width: 6),
                Text(
                  UtilsNotas.formatDate(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: UtilsNotas.colorTextoGris,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}