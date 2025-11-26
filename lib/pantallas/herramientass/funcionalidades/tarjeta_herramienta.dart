/// TARJETA DE HERRAMIENTA
/// Widget sofisticado que representa cada opción del menú.
/// Incluye:
/// - Borde superior de color (accent).
/// - Icono con fondo suave.
/// - Badge (etiqueta) de categoría.
/// - Lista de tags/etiquetas descriptivas.
import 'package:flutter/material.dart';
import 'modelo_herramienta.dart';
import 'utils_herramientas.dart';

class TarjetaHerramienta extends StatelessWidget {
  final ToolInfo info;
  
  const TarjetaHerramienta({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => info.destination),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: UtilsHerramientas.colorPrincipal.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          children: [
            // Borde superior de color
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: UtilsHerramientas.colorPrincipal,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
            ),
            
            // Contenido principal
            Flexible(
              fit: FlexFit.loose,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    // Icono, Título y Descripción
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Icono pequeño
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: info.color.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(info.icon, color: info.color, size: 22),
                              ),
                              const SizedBox(width: 12),
                              
                              // Título y Badge
                              Expanded(
                                child: Text(
                                  info.title,
                                  style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFFCF3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  info.badge,
                                  style: const TextStyle(
                                    color: UtilsHerramientas.colorPrincipal,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            info.description,
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          
                          // Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: info.tags
                                .map((t) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFFCF3),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        t,
                                        style: const TextStyle(
                                            color: UtilsHerramientas.colorPrincipal, fontSize: 12),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Barra inferior de acción
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Abrir herramienta',
                      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.green.shade700),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}