import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_admin.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarPageAdmin extends StatefulWidget {
  const CalendarPageAdmin({super.key});

  @override
  State<CalendarPageAdmin> createState() => _CalendarPageAdminState();
}

class _CalendarPageAdminState extends State<CalendarPageAdmin> {
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
    log('[1] Fetching events from Firestore...');
    final querySnapshot = await _firestore.collection('Events').get();
    log('[6] Fetched ${querySnapshot.docs.length} event documents');

    setState(() {
      _events = {};
      log('[7] Events cleared'); // Clear existing events
      for (var doc in querySnapshot.docs) {
        final event = doc.data();
        final startDate = (event['startDate'] as Timestamp).toDate();
        log('[8] Adding event to _events map: ${event['eventName']} (startDate: $startDate)');

        if (_events[startDate] == null) {
          _events[startDate] = [];
        }
        _events[startDate]!.add(event.cast<String, dynamic>());
        // log('Retrieved startDate: $startDate');
        // log('Retrieved endDate: $endDate');
      }
      log('[9] Events Map: $_events');
    });
  }

  @override
  Widget build(BuildContext context) {
    log('[2] Building CalendarPageOrg widget...');
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
                log('[5] Building markers for date: $date');
                if (events.isNotEmpty) {
                  log('Events: $events');
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
                log('Building event tile at index: $index');
                final event = _getEventsForDay(_selectedDay!)[index];
                log("expanded");
                return _buildEventTile(event);
              },
            )
                : const Center(child: Text('Select a date to view events')),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    log('[3] Getting events for day: $day');
    if (isSameDay(day, _selectedDay)) {

    }
    final events = _events.entries
        .where((entry) => isSameDay(entry.key, day))
        .map((entry) => entry.value)
        .expand((eventList) => eventList)
        .toList();
    log('[4] Found ${events.length} events');
    return events;
  }

  Widget _buildEventMarkers(List<Map<String, dynamic>> events) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: events.map((event) {
        final status = event['status'];
        Color color;
        switch (status) {
          case '_forApproval':
            color = Colors.orange;
            break;
          case 'approved':
            color = Colors.green;
            break;
          case 'denied':
            color = Colors.red;
            break;
          default:
            color = Colors.grey;
        }
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
    log('Building event tile: ${event['eventName']}');
    return ListTile(
      title: Text(event['eventName']),
      subtitle: Text(DateFormat('MMM dd, yyyy')
          .format((event['startDate'] as Timestamp).toDate())),
      trailing: Chip(
        label: Text(event['status']),
        backgroundColor: _getStatusColor(event['status']),
      ),
      onTap: () {
        // Navigate to Event Details Page
        log('Navigating to Event Details Page for: ${event['eventName']}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsPage(event: event),
          ),
        );
      }, // Add onTap for user interaction
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

// Event Details Page (You'll need to create this)
class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event['eventName'])),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Event Name: ${event['eventName']}'),
            Text('Start Date: ${DateFormat('MMM dd, yyyy').format((event['startDate'] as Timestamp).toDate())}'),
            Text('End Date: ${DateFormat('MMM dd, yyyy').format((event['endDate'] as Timestamp).toDate())}'),
            Text('Venue: ${event['venue']}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}