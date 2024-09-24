import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/sidebar/sidebar_admin.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';


class ForApprovalPage extends StatefulWidget {
  const ForApprovalPage({super.key});

  @override
  State<ForApprovalPage> createState() => _ForApprovalPageState();
}

class _ForApprovalPageState extends State<ForApprovalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'For Approval'),
      drawer: const CollapsibleSidebarAdmin(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Events')
            .where('status', isEqualTo: '_forApproval')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No events for approval.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final event = snapshot.data!.docs[index].data()
              as Map<String, dynamic>;
              final eventId = snapshot.data!.docs[index].id;
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(event['requesterId']).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return const Text('Error loading organization name');
                  }

                  final organizationName = userSnapshot.data!['name'];

                  return EventApprovalCard(
                    event: event,
                    eventId: eventId,
                    organizationName: organizationName,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class EventApprovalCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final String eventId;
  final String organizationName;

  const EventApprovalCard({
    super.key,
    required this.event,
    required this.eventId,
    required this.organizationName,
  });

  @override
  State<EventApprovalCard> createState() => _EventApprovalCardState();
}

class _EventApprovalCardState extends State<EventApprovalCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final startDate = (widget.event['startDate'] as Timestamp).toDate();
    final endDate = (widget.event['endDate'] as Timestamp).toDate();
    final formattedStartDate = DateFormat('MMM dd, yyyy').format(startDate);
    final formattedEndDate = DateFormat('MMM dd, yyyy').format(endDate);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile( // Use ExpansionTile for collapsible card
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Organization: ${widget.organizationName}'),
            Text('Event Name: ${widget.event['eventName']}'),
            Text('Date: $formattedStartDate - $formattedEndDate'),
          ],
        ),
        children: [ // Details to show when expanded
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event ID: ${widget.event['eventId']}'),
                  Text('Venue: ${widget.event['venue']}'),
                  Text('Participants: ${widget.event['participants']}'),
                  Text(
                      'Budget: ${widget.event['budgetSource']} - ${widget
                          .event['budgetAmount']}'),
                  Text('Description: ${widget.event['description']}'),


                  _buildFileLink('SARF', widget.event['sarfFileUrl'],),
                  _buildFileLink(
                      'Request Letter', widget.event['requestLetterFileUrl']),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('Events')
                                .doc(widget.eventId)
                                .update({'status': 'approved'});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Event approved successfully!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error approving event: $e')),
                            );
                          }
                        },
                        child: const Text('Approve'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('Events')
                                .doc(widget.eventId)
                                .update({'status': 'denied'});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Event denied.')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error denying event: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Deny'),
                      ),
                    ],
                  ),
                ],
              ),
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

  Widget _buildFileLink(String label, String? url) {
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    String displayedUrl = url.length > 40 ? '${url.substring(0, 35)}...' : url;

    return SizedBox( // Add SizedBox to constrain height
      height: 40, // Set a suitable height for the InkWell
      child: InkWell(
        onTap: () async {
          if (await canLaunchUrlString(url)) {
            // Instead of launching the URL directly, prompt the user to download
            showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: const Text('View File'),
                    content: Text('Do you want to view the $label?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await launchUrlString(url,
                              mode: LaunchMode.externalApplication);
                          // Use LaunchMode.externalApplication to open the URL in the browser or an external app
                        },
                        child: const Text('View'),
                      ),
                    ],
                  ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open file.')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              const Icon(Icons.attach_file),
              const SizedBox(width: 8.0),
              Text(
                '$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(displayedUrl),
            ],
          ),
        ),
      ),
    );
  }
}