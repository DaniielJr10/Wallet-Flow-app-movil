/// GRILLA DEL CALENDARIO
/// Implementa el widget `TableCalendar`. Configura los estilos de las celdas,
/// los días seleccionados, el día de hoy y los días fuera del mes.
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'utils_calendario.dart';

class GrillaCalendario extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final Function(CalendarFormat) onFormatChanged;

  const GrillaCalendario({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: TableCalendar(
        firstDay: DateTime.utc(2010, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: focusedDay,
        calendarFormat: calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        headerVisible: false, // Usamos nuestro HeaderMes personalizado
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
        
        // Estilos
        calendarStyle: CalendarStyle(
          outsideTextStyle: TextStyle(color: Colors.grey.shade400),
          weekendTextStyle: const TextStyle(color: UtilsCalendario.colorPrincipal, fontWeight: FontWeight.w700),
          todayDecoration: BoxDecoration(
            color: UtilsCalendario.colorFondoHoy,
            borderRadius: BorderRadius.circular(8),
          ),
          selectedDecoration: BoxDecoration(
            color: UtilsCalendario.colorPrincipal,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          cellMargin: const EdgeInsets.all(6),
          cellPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        
        // Builders personalizados
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            const labels = ['DOM','LUN','MAR','MIÉ','JUE','VIE','SÁB'];
            final idx = day.weekday % 7;
            return Center(
              child: Text(
                labels[idx],
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
              ),
            );
          },
          defaultBuilder: (context, day, focusedDay) {
            final isOutside = day.month != this.focusedDay.month;
            return Center(
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isOutside ? const Color(0xFFF7FAF7) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: UtilsCalendario.colorBorde,
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isOutside ? Colors.grey.shade400 : const Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            return Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.14), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: UtilsCalendario.colorSombra,
                      blurRadius: 8,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: UtilsCalendario.colorPrincipal, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            return Center(
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: UtilsCalendario.colorPrincipal,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}