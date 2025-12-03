/// MANEJO DE FRECUENCIAS
/// Gestiona las opciones de recurrencia para ingresos automáticos.
/// Define tipos de frecuencia y calcula próximas fechas de ejecución.
import 'package:flutter/material.dart';

enum TipoFrecuencia {
  ninguna,
  diaria,
  semanal,
  quincenal,
  mensual,
  bimestral,
  trimestral,
  semestral,
  anual,
}

class FrecuenciaUtils {
  static const Map<TipoFrecuencia, String> _nombres = {
    TipoFrecuencia.ninguna: 'No recurrente',
    TipoFrecuencia.diaria: 'Diario',
    TipoFrecuencia.semanal: 'Semanal',
    TipoFrecuencia.quincenal: 'Quincenal',
    TipoFrecuencia.mensual: 'Mensual',
    TipoFrecuencia.bimestral: 'Cada 2 meses',
    TipoFrecuencia.trimestral: 'Cada 3 meses',
    TipoFrecuencia.semestral: 'Cada 6 meses',
    TipoFrecuencia.anual: 'Anual',
  };

  static const Map<TipoFrecuencia, IconData> _iconos = {
    TipoFrecuencia.ninguna: Icons.block,
    TipoFrecuencia.diaria: Icons.today,
    TipoFrecuencia.semanal: Icons.view_week,
    TipoFrecuencia.quincenal: Icons.calendar_view_week,
    TipoFrecuencia.mensual: Icons.calendar_month,
    TipoFrecuencia.bimestral: Icons.date_range,
    TipoFrecuencia.trimestral: Icons.view_module,
    TipoFrecuencia.semestral: Icons.view_timeline,
    TipoFrecuencia.anual: Icons.event_repeat,
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
    if (valor == null) return null;
    try {
      return TipoFrecuencia.values.firstWhere(
        (e) => e.toString().split('.').last == valor,
      );
    } catch (e) {
      return null;
    }
  }

  /// Convierte enum a string para guardar en base de datos
  static String aString(TipoFrecuencia frecuencia) {
    return frecuencia.toString().split('.').last;
  }

  /// Calcula la próxima fecha basada en la frecuencia
  static DateTime calcularProximaFecha(
    DateTime fechaBase,
    TipoFrecuencia frecuencia,
  ) {
    switch (frecuencia) {
      case TipoFrecuencia.diaria:
        return fechaBase.add(const Duration(days: 1));
      case TipoFrecuencia.semanal:
        return fechaBase.add(const Duration(days: 7));
      case TipoFrecuencia.quincenal:
        return fechaBase.add(const Duration(days: 15));
      case TipoFrecuencia.mensual:
        return _agregarMeses(fechaBase, 1);
      case TipoFrecuencia.bimestral:
        return _agregarMeses(fechaBase, 2);
      case TipoFrecuencia.trimestral:
        return _agregarMeses(fechaBase, 3);
      case TipoFrecuencia.semestral:
        return _agregarMeses(fechaBase, 6);
      case TipoFrecuencia.anual:
        return _agregarMeses(fechaBase, 12);
      default:
        return fechaBase;
    }
  }

  /// Agrega meses a una fecha manejando casos como 31 de enero -> 28/29 de febrero
  static DateTime _agregarMeses(DateTime fecha, int meses) {
    final nuevaFecha = DateTime(fecha.year, fecha.month + meses, fecha.day);

    // Si el día no existe en el nuevo mes (ej: 31 de feb), usar el último día del mes
    if (nuevaFecha.month != (fecha.month + meses) % 12 &&
        nuevaFecha.month != fecha.month + meses) {
      return DateTime(fecha.year, fecha.month + meses + 1, 0);
    }

    return nuevaFecha;
  }

  /// Lista de frecuencias disponibles (excluyendo 'ninguna' para mostrar en UI)
  static List<TipoFrecuencia> get frecuenciasDisponibles {
    return TipoFrecuencia.values
        .where((f) => f != TipoFrecuencia.ninguna)
        .toList();
  }

  /// Verifica si es momento de generar un ingreso recurrente
  static bool debeGenerarIngreso(
    DateTime fechaUltimoIngreso,
    TipoFrecuencia frecuencia,
    DateTime fechaActual,
  ) {
    if (frecuencia == TipoFrecuencia.ninguna) return false;

    final proximaFecha = calcularProximaFecha(fechaUltimoIngreso, frecuencia);
    return fechaActual.isAfter(proximaFecha) ||
        (fechaActual.year == proximaFecha.year &&
            fechaActual.month == proximaFecha.month &&
            fechaActual.day == proximaFecha.day);
  }
}

/// Widget selector de frecuencia
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
            Icon(Icons.repeat, color: Colors.green.shade600, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Recurrencia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green.shade600, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TipoFrecuencia>(
              value: frecuenciaActual,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.green.shade600,
              ),
              items: [
                DropdownMenuItem(
                  value: TipoFrecuencia.ninguna,
                  child: Row(
                    children: [
                      Icon(
                        FrecuenciaUtils.obtenerIcono(TipoFrecuencia.ninguna),
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        FrecuenciaUtils.obtenerNombre(TipoFrecuencia.ninguna),
                      ),
                    ],
                  ),
                ),
                ...FrecuenciaUtils.frecuenciasDisponibles.map(
                  (frecuencia) => DropdownMenuItem(
                    value: frecuencia,
                    child: Row(
                      children: [
                        Icon(
                          FrecuenciaUtils.obtenerIcono(frecuencia),
                          size: 18,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(FrecuenciaUtils.obtenerNombre(frecuencia)),
                      ],
                    ),
                  ),
                ),
              ],
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
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Este ingreso se generará automáticamente cada ${FrecuenciaUtils.obtenerNombre(frecuenciaActual).toLowerCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
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
}
