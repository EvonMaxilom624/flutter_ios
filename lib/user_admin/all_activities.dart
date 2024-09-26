import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/sidebar/sidebar_admin.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({Key? key}) : super(key: key);

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedStatus = 'all'; // Default to showing all events

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'All Events'),
      drawer: const CollapsibleSidebarAdmin(),
      body: Column(
        children: [
          _buildStatusFilter(), // Add the filter section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getSelectedEventsStream(),
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
                    final eventId = snapshot.data!.docs[index].id;
                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('users')
                          .doc(event['requesterId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (userSnapshot.hasError || !userSnapshot.hasData) {
                          return const Text('Error loading organization name');
                        }

                        final organizationName = userSnapshot.data!['name'];

                        return AllEventsCard(
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
          ),
        ],
      ),
    );
  }

  // Build the status filter section
  Widget _buildStatusFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFilterButton('All', 'all'),
          _buildFilterButton('For Approval', '_forApproval'),
          _buildFilterButton('Approved', 'approved'),
          _buildFilterButton('Denied', 'denied'),
        ],
      ),
    );
  }

  // Build individual filter buttons
  Widget _buildFilterButton(String label, String status) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedStatus == status
            ? Colors.blue
            : Colors.grey[300],
      ),
      child: Text(label),
    );
  }

  // Get the Firestore stream based on selected status
  Stream<QuerySnapshot> _getSelectedEventsStream() {
    if (_selectedStatus == 'all') {
      return _firestore.collection('Events').snapshots();
    } else {
      return _firestore
          .collection('Events')
          .where('status', isEqualTo: _selectedStatus)
          .snapshots();
    }
  }
}

class AllEventsCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final String eventId;
  final String organizationName;

  const AllEventsCard({
    super.key,
    required this.event,
    required this.eventId,
    required this.organizationName,
  });

  @override
  State<AllEventsCard> createState() => _AllEventsCardState();
}

class _AllEventsCardState extends State<AllEventsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final startDate = (widget.event['startDate'] as Timestamp).toDate();
    final endDate = (widget.event['endDate'] as Timestamp).toDate();
    final formattedStartDate = DateFormat('MMM dd, yyyy').format(startDate);
    final formattedEndDate = DateFormat('MMM dd, yyyy').format(endDate);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Organization: ${widget.organizationName}'),
            Text('Event Name: ${widget.event['eventName']}'),
            Text('Date: $formattedStartDate - $formattedEndDate'),
            Align(
              alignment: Alignment.bottomRight,
              child: Chip(
                label: Text(widget.event['status']),
                backgroundColor: _getStatusColor(widget.event['status']),
              ),
            ),
          ],
        ),
        children: [
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
                  _buildFileLink('SARF', widget.event['sarfFileUrl']),
                  _buildFileLink(
                      'Request Letter', widget.event['requestLetterFileUrl']),
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

  // Function to get the background color for the status chip
  Color _getStatusColor(String status) {
    switch (status) {
      case '_forApproval':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'denied':
        return Colors.red;
      default:
        return Colors.grey; // Default color if status is unknown
    }
  }

  Widget _buildFileLink(String label, String? url) {
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    String displayedUrl =
    url.length > 40 ? '${url.substring(0, 35)}...' : url;

    return SizedBox(
      // Add SizedBox to constrain height
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