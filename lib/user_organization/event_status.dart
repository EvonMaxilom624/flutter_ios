import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/sidebar/sidebar_org.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class EventStatusPage extends StatefulWidget {
  const EventStatusPage({super.key});

  @override
  State<EventStatusPage> createState() => _EventStatusPageState();
}

class _EventStatusPageState extends State<EventStatusPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = AuthService().currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Event Status'),
      drawer: const CollapsibleSidebarOrganization(),
      body: _userId == null
          ? const Center(child: Text('User not logged in.'))
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Events')
            .where('requesterId', isEqualTo: _userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No events found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final event = snapshot.data!.docs[index].data()
              as Map<String, dynamic>;
              return EventStatusCard(event: event);
            },
          );
        },
      ),
    );
  }
}

class EventStatusCard extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventStatusCard({super.key, required this.event});

  @override
  State<EventStatusCard> createState() => _EventStatusCardState();
}

class _EventStatusCardState extends State<EventStatusCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final startDate = (widget.event['startDate'] as Timestamp).toDate();
    final endDate = (widget.event['endDate'] as Timestamp).toDate();
    final formattedStartDate = DateFormat('MMM dd, yyyy').format(startDate);
    final formattedEndDate = DateFormat('MMM dd, yyyy').format(endDate);

    return Card(
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.event['eventName']),
                Text('$formattedStartDate - $formattedEndDate'),
              ],
            ),
            Chip(
              label: Text(widget.event['status']),
              backgroundColor: widget.event['status'] == '_forApproval'
                  ? Colors.orange
                  : widget.event['status'] == 'approved'
                  ? Colors.green
                  : Colors.red, // Customize colors as needed
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Venue: ${widget.event['venue']}'),
                Text('Participants: ${widget.event['participants']}'),
                Text(
                    'Budget: ${widget.event['budgetSource']} - ${widget.event['budgetAmount']}'),
                Text('Description: ${widget.event['description']}'),
                // Add more details as needed (e.g., links to uploaded files)
              ],
            ),
          ),
        ],
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
      ),
    );
  }
}