import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_admin.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class EventApprovalPage extends StatefulWidget {
  const EventApprovalPage({super.key});

  @override
  State<EventApprovalPage> createState() => EventApprovalPageState();
}

class EventApprovalPageState extends State<EventApprovalPage> {
  final List<EventRequest> _eventRequests = [
    EventRequest(
      id: '1',
      eventName: 'Tech Conference 2024',
      eventDate: '2024-07-20',
      eventLocation: 'Auditorium',
      organizer: 'Tech Club',
    ),
    EventRequest(
      id: '2',
      eventName: 'Art Workshop',
      eventDate: '2024-08-15',
      eventLocation: 'Art Room',
      organizer: 'Art Club',
    ),
    // Add more event requests as needed
  ];

  void _approveEvent(String eventId) {
    setState(() {
      final index = _eventRequests.indexWhere((event) => event.id == eventId);
      if (index != -1) {
        _eventRequests[index].isApproved = true;
        // Implement notification logic here
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Event Approval"),
      drawer: const CollapsibleSidebarAdmin(),
      body: CustomBackground(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: _eventRequests.map((event) {
                  return Card(
                    elevation: 4,
                    child: ExpansionTile(
                      title: Text(event.eventName),
                      subtitle: Text('Organizer: ${event.organizer}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${event.eventDate}'),
                              Text('Location: ${event.eventLocation}'),
                              Text('Organizer: ${event.organizer}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Checkbox(
                                    value: event.isApproved,
                                    onChanged: (bool? value) {
                                      if (value != null && value) {
                                        _approveEvent(event.id);
                                      }
                                    },
                                  ),
                                  const Text('Approve'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: EventApprovalPage(),
  ));
}

class EventRequest {
  final String id;
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String organizer;
  bool isApproved;

  EventRequest({
    required this.id,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.organizer,
    this.isApproved = false,
  });
}

/*void _approveEvent(String eventId) {
  setState(() {
    final index = _eventRequests.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      _eventRequests[index].isApproved = true;

      // Implement notification logic here
      // For example, using Firebase Cloud Messaging to notify the organizer
      sendApprovalNotification(_eventRequests[index]);
    }
  });
}*/

void sendApprovalNotification(EventRequest event) {
  // Example notification logic
  // FirebaseMessaging.instance.sendMessage(
  //   to: event.organizerToken,
  //   data: {
  //     'title': 'Event Approved',
  //     'body': 'Your event "${event.eventName}" has been approved.',
  //   },
  // );
}
