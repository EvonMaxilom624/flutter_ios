import 'package:flutter/material.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final Widget sidebar;
  const CalendarPage({super.key, required this.sidebar});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  late Map<DateTime, List<dynamic>> _events;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = generateEvents(); // Generate events dynamically
  }

  Map<DateTime, List<dynamic>> generateEvents() {
    Map<DateTime, List<dynamic>> events = {};

    final DateTime now = DateTime.now();
    final DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Loop through each day of the month
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      final DateTime day = DateTime(now.year, now.month, i);

      // Check if the day falls within the first 7 days
      if (i <= 7) {
        // Add an event for this day
        events.putIfAbsent(day, () => ['Event for first week']);
      }
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Calendar',
      ),
      drawer: widget.sidebar,
      body: CustomBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2021, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  eventLoader: (day) {
                    final events = _events[day];
                    return events ?? [];
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      if (date.day <= 7) {
                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      } else {
                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        );
                      }
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 3,
                  child: ListTile(
                    title: const Text('Exam Prep'),
                    subtitle: const Text('Week before the examination.'),
                    onTap: () {
                      // Handle tap event
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
