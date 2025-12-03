/// SISTEMA DE FRECUENCIAS PARA GASTOS
/// Maneja las opciones de frecuencia para crear gastos automáticamente
/// según el período seleccionado por el usuario.
import 'package:flutter/material.dart';

/// Enum que define los tipos de frecuencia disponibles
enum TipoFrecuencia {
  ninguna,
  semanal,
  quincenal,
  mensual,
}

/// Clase utilitaria para manejar frecuencias
class FrecuenciaUtils {
  /// Nombres legibles para cada tipo de frecuencia
  static const Map<TipoFrecuencia, String> _nombres = {
    TipoFrecuencia.ninguna: 'Sin frecuencia',
    TipoFrecuencia.semanal: 'Semanal',
    TipoFrecuencia.quincenal: 'Quincenal', 
    TipoFrecuencia.mensual: 'Mensual',
  };

  /// Iconos para cada tipo de frecuencia
  static const Map<TipoFrecuencia, IconData> _iconos = {
    TipoFrecuencia.ninguna: Icons.calendar_today,
    TipoFrecuencia.semanal: Icons.view_week,
    TipoFrecuencia.quincenal: Icons.calendar_view_week,
    TipoFrecuencia.mensual: Icons.calendar_month,
  };

  /// Obtiene el nombre legible de una frecuencia
  static String obtenerNombre(TipoFrecuencia frecuencia) {
    return _nombres[frecuencia] ?? 'Desconocida';
  }

  /// Obtiene el icono de una frecuencia
  static IconData obtenerIcono(TipoFrecuencia frecuencia) {
    return _iconos[frecuencia] ?? Icons.help;
  }

  /// Convierte string a enum
  static TipoFrecuencia? desdeString(String? valor) {
    if (valor == null) return TipoFrecuencia.ninguna;
    try {
      return TipoFrecuencia.values.firstWhere(
        (e) => e.toString().split('.').last == valor,
      );
    } catch (e) {
      return TipoFrecuencia.ninguna;
    }
  }

  /// Convierte enum a string para guardar en base de datos
  static String? aString(TipoFrecuencia frecuencia) {
    if (frecuencia == TipoFrecuencia.ninguna) return null;
    return frecuencia.toString().split('.').last;
  }

  /// Calcula la próxima fecha basada en la frecuencia
  static DateTime calcularProximaFecha(
    DateTime fechaBase,
    TipoFrecuencia frecuencia,
  ) {
    switch (frecuencia) {
      case TipoFrecuencia.semanal:
        return fechaBase.add(const Duration(days: 7));
      case TipoFrecuencia.quincenal:
        return fechaBase.add(const Duration(days: 15));
      case TipoFrecuencia.mensual:
        return _agregarMeses(fechaBase, 1);
      default:
        return fechaBase;
    }
  }

  /// Agrega meses a una fecha manejando casos especiales
  static DateTime _agregarMeses(DateTime fecha, int meses) {
    int nuevoMes = fecha.month + meses;
    int nuevoAno = fecha.year;
    
    while (nuevoMes > 12) {
      nuevoMes -= 12;
      nuevoAno++;
    }
    
    // Manejar casos como 31 de enero -> 28/29 de febrero
    int ultimoDiaDelMes = DateTime(nuevoAno, nuevoMes + 1, 0).day;
    int dia = fecha.day > ultimoDiaDelMes ? ultimoDiaDelMes : fecha.day;
    
    return DateTime(nuevoAno, nuevoMes, dia);
  }

  /// Lista de frecuencias disponibles (excluyendo 'ninguna')
  static List<TipoFrecuencia> get frecuenciasDisponibles {
    return TipoFrecuencia.values
        .where((f) => f != TipoFrecuencia.ninguna)
        .toList();
  }
}

/// Widget selector de frecuencia para el formulario
class SelectorFrecuencia extends StatelessWidget {
  final TipoFrecuencia frecuenciaActual;
  final Function(TipoFrecuencia) onCambio;

  const SelectorFrecuencia({
    super.key,
    required this.frecuenciaActual,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.repeat,
              color: Colors.red.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Frecuencia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.shade600, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TipoFrecuencia>(
              value: frecuenciaActual,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.red.shade600,
              ),
              items: TipoFrecuencia.values.map((frecuencia) {
                return DropdownMenuItem(
                  value: frecuencia,
                  child: Row(
                    children: [
                      Icon(
                        FrecuenciaUtils.obtenerIcono(frecuencia),
                        size: 18,
                        color: frecuencia == TipoFrecuencia.ninguna
                            ? Colors.grey.shade600
                            : Colors.red.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(FrecuenciaUtils.obtenerNombre(frecuencia)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (TipoFrecuencia? nueva) {
                if (nueva != null) {
                  onCambio(nueva);
                }
              },
            ),
          ),
        ),
        if (frecuenciaActual != TipoFrecuencia.ninguna) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.red.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _obtenerTextoInformativo(frecuenciaActual),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _obtenerTextoInformativo(TipoFrecuencia frecuencia) {
    switch (frecuencia) {
      case TipoFrecuencia.semanal:
        return 'Se creará automáticamente cada semana en la misma fecha';
      case TipoFrecuencia.quincenal:
        return 'Se creará automáticamente cada 15 días';
      case TipoFrecuencia.mensual:
        return 'Se creará automáticamente cada mes en el mismo día';
      default:
        return '';
    }
  }
}
