
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // El widget del calendario.
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              // Usa `isSameDay` para comprobar si el día está seleccionado.
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // Actualiza el día enfocado también
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              // No es necesario llamar a `setState()` aquí.
              _focusedDay = focusedDay;
            },
            // Personalización de la UI del calendario.
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
          ),
          const SizedBox(height: 8.0),
          // Aquí se mostrarán los eventos para el día seleccionado.
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: const Center(
                child: Text(
                  'No hay eventos para este día.',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
