import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/sidebar/sidebar_admin.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final querySnapshot = await _firestore.collection('Events').get();
    print('Fetched ${querySnapshot.docs.length} event documents'); // Log the number of events fetched

    setState(() {
      for (var doc in querySnapshot.docs) {
        final event = doc.data() as Map<String, dynamic>;
        final startDate = (event['startDate'] as Timestamp).toDate();
        final endDate = (event['endDate'] as Timestamp).toDate();

        print('Event: ${event['eventName']} - Start: $startDate, End: $endDate'); // Log event details

        // Add event to each day in the range
        for (var date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
          if (_events[date] == null) {
            _events[date] = [];
          }
          _events[date]!.add(event.cast<String, dynamic>());
        }
      }
      print('Events Map: $_events'); // Log the events map
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    print('Getting events for day: $day'); // Log the day for which events are being retrieved
    final events = _events[day] ?? [];
    print('Found ${events.length} events'); // Log the number of events found
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Event Calendar'),
      drawer: const CollapsibleSidebarAdmin(),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
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
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  print('Building markers for date: $date'); // Log the date for which markers are being built
                  print('Events: $events'); // Log the events being used for markers
                  return _buildEventMarkers(
                      events.cast<Map<String, dynamic>>());
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedDay != null
                ? ListView.builder(
              itemCount: _getEventsForDay(_selectedDay!).length,
              itemBuilder: (context, index) {
                final event = _getEventsForDay(_selectedDay!)[index];
                return _buildEventTile(event);
              },
            )
                : const Center(child: Text('Select a date to view events')),
          ),
        ],
      ),
    );
  }

  Widget _buildEventMarkers(List<Map<String, dynamic>> events) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: events.map((event) {
        final status = event['status'];
        final color = status == '_forApproval' ? Colors.orange : Colors.green;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEventTile(Map<String, dynamic> event) {
    return ListTile(
      title: Text(event['eventName']),
      subtitle: Text(DateFormat('MMM dd, yyyy')
          .format((event['startDate'] as Timestamp).toDate())),
      trailing: Chip(
        label: Text(event['status']),
        backgroundColor: _getStatusColor(event['status']),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '_forApproval':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'denied':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}