
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// Nota: este archivo mejora la pantalla de calendario con un estilo
// profesional acorde al diseño de Wallet Flow (colores verdes, card centrada,
// controles de navegación).

// Una pantalla de calendario moderna y profesional para la aplicación Wallet Flow.
class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  // El día actualmente seleccionado en el calendario.
  DateTime _selectedDay = DateTime.now();
  // El día que tiene el foco en el calendario.
  DateTime _focusedDay = DateTime.now();
  // El formato actual del calendario (mes, dos semanas, semana).
  CalendarFormat _calendarFormat = CalendarFormat.month;


  // Nombres de meses en español (para el encabezado)
  static const List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Encabezado general con flecha de retroceso, icono y subtítulo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  // Botón de retroceso
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF10B981)),
                    tooltip: 'Volver',
                  ),

                  // Título centrado
                  Expanded(
                    child: Column(
                      children: const [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month_rounded, color: Color(0xFF10B981), size: 34),
                            SizedBox(width: 8),
                            Text(
                              'CALENDARIO',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Organiza y planifica tus fechas importantes',
                          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),

                  // Espacio para equilibrar el layout (misma anchura que el botón)
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Card central con el calendario (centrado y con ancho máximo)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE6F4EA), width: 1.5),
                    ),
                    child: Column(
                  children: [
                    // Header personalizado (botones y mes)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Row(
                            children: [
                              // Prev Year (icon)
                              _navIconButton(
                                tooltip: 'Año anterior',
                                icon: Icons.fast_rewind_rounded,
                                onTap: () {
                                  setState(() {
                                    _focusedDay = DateTime(_focusedDay.year - 1, _focusedDay.month, 1);
                                  });
                                },
                              ),
                              const SizedBox(width: 6),
                              // Prev Month (icon)
                              _navIconButton(
                                tooltip: 'Mes anterior',
                                icon: Icons.chevron_left_rounded,
                                onTap: () {
                                  setState(() {
                                    final prev = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                                    _focusedDay = prev;
                                  });
                                },
                              ),
                              const Spacer(),
                              // Title
                              Column(
                                children: [
                                  Text(
                                    '${_meses[_focusedDay.month - 1]}',
                                    style: const TextStyle(
                                      color: Color(0xFF059669),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${_focusedDay.year}',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Next Month (icon)
                              _navIconButton(
                                tooltip: 'Mes siguiente',
                                icon: Icons.chevron_right_rounded,
                                onTap: () {
                                  setState(() {
                                    final next = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                                    _focusedDay = next;
                                  });
                                },
                              ),
                              const SizedBox(width: 6),
                              // Next Year (icon)
                              _navIconButton(
                                tooltip: 'Año siguiente',
                                icon: Icons.fast_forward_rounded,
                                onTap: () {
                                  setState(() {
                                    _focusedDay = DateTime(_focusedDay.year + 1, _focusedDay.month, 1);
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // (TableCalendar will render the days-of-week row; we use a custom
                    // dowBuilder below to show Spanish abbreviations)

                    // Calendar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2010, 1, 1),
                        lastDay: DateTime.utc(2035, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        startingDayOfWeek: StartingDayOfWeek.sunday,
                        headerVisible: false,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          if (_calendarFormat != format) {
                            setState(() => _calendarFormat = format);
                          }
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarStyle: CalendarStyle(
                          outsideTextStyle: TextStyle(color: Colors.grey.shade400),
                          weekendTextStyle: const TextStyle(color: Color(0xFF10B981)),
                          todayDecoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          selectedDecoration: BoxDecoration(
                            color: const Color(0xFF10B981),
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
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700),
                          weekendStyle: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700),
                        ),
                        calendarBuilders: CalendarBuilders(
                          dowBuilder: (context, day) {
                            const labels = ['DOM','LUN','MAR','MIÉ','JUE','VIE','SÁB'];
                            final idx = day.weekday % 7; // Sunday -> 0
                            return Center(
                              child: Text(
                                labels[idx],
                                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
                              ),
                            );
                          },
                          defaultBuilder: (context, day, focusedDay) {
                            final isOutside = day.month != _focusedDay.month;
                            return Center(
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isOutside ? const Color(0xFFF7FAF7) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE6F4EA),
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
                                      color: Colors.green.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800),
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
                                  color: const Color(0xFF10B981),
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
                    ),

                    const SizedBox(height: 8),
                  ], // end Column children
                ), // end Column
              ), // end Container
            ), // end ConstrainedBox
          ), // end Center
        ), // end Padding (card)

        const SizedBox(height: 24),
      ], // end top Column children
    ), // end Column
  ), // end SafeArea
); // end Scaffold
  }

  // Botón pequeño con estilo pill para navegación rápida
  Widget _navPillButton(String text, VoidCallback onTap, {bool compact = false}) {
    final bgColor = compact ? Colors.white : const Color(0xFF10B981);
    final textColor = compact ? const Color(0xFF10B981) : Colors.white;
    final border = compact ? Border.all(color: const Color(0xFF10B981).withOpacity(0.14), width: 1.2) : null;
    final padding = compact ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6) : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    final fontSize = compact ? 12.0 : 13.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: border,
            boxShadow: compact
                ? null
                : [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: fontSize),
          ),
        ),
      ),
    );
  }

  // Botón iconográfico compacto para navegación (prev/next)
  Widget _navIconButton({required String tooltip, required IconData icon, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 40,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.14)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF10B981), size: 20),
          ),
        ),
      ),
    );
  }

}

