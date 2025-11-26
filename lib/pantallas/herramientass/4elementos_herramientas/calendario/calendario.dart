/// ORQUESTADOR DE CALENDARIO
/// Gestiona el estado de la fecha seleccionada y el formato del calendario.
/// Ensambla el AppBar, el contenedor principal y los componentes internos.
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// Importaciones modularizadas
import 'funcionalidades/utils_calendario.dart';
import 'funcionalidades/app_bar_calendario.dart';
import 'funcionalidades/header_mes.dart';
import 'funcionalidades/grilla_calendario.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtilsCalendario.colorFondo,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppBarCalendario(),
                const SizedBox(height: 18),
                
                // Card central del calendario
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
                          border: Border.all(color: UtilsCalendario.colorBorde, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            HeaderMes(
                              focusedDay: _focusedDay,
                              onPrevYear: () => setState(() => _focusedDay = DateTime(_focusedDay.year - 1, _focusedDay.month, 1)),
                              onPrevMonth: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1)),
                              onNextMonth: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1)),
                              onNextYear: () => setState(() => _focusedDay = DateTime(_focusedDay.year + 1, _focusedDay.month, 1)),
                            ),
                            
                            GrillaCalendario(
                              focusedDay: _focusedDay,
                              selectedDay: _selectedDay,
                              calendarFormat: _calendarFormat,
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
                            ),
                            
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}