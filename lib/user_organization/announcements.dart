import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/database_service.dart';
import 'package:flutter_ios/sidebar/sidebar_org.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => AnnouncementPageState();
}

class AnnouncementPageState extends State<AnnouncementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance of Firestore to interact with the database
  final DatabaseService _databaseService = DatabaseService(); // Instance of a custom database service
  String? _organizationId; // Store organization ID
  bool _isLoading = true; // Track loading state to display a loading indicator

  @override
  void initState() {
    super.initState();
    developer.log('Initializing AnnouncementPage', name: 'AnnouncementPage'); // Log for debugging
    _fetchOrganizationId(); // Fetch the organization ID when the widget is initialized
  }

  // Method to fetch the organization ID associated with the current user
  Future<void> _fetchOrganizationId() async {
    final userId = AuthService().currentUser?.uid; // Get current user ID from authentication service
    developer.log('Fetching organization ID for user: $userId', name: 'AnnouncementPage');
    if (userId != null) { // Ensure user ID is not null
      try {
        // Fetch user document from Firestore using user ID
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) { // Check if the document exists
          setState(() {
            _organizationId = userDoc.id; // Use the document ID as the organization ID
            developer.log('Organization ID fetched: $_organizationId', name: 'AnnouncementPage'); // Log the fetched organization ID
          });
        } else {
          developer.log('User document does not exist', name: 'AnnouncementPage'); // Log if user document is not found
        }
      } catch (e) {
        developer.log('Error fetching organization ID: ${e.toString()}', name: 'AnnouncementPage'); // Log any errors during fetching
      }
    } else {
      developer.log('User ID is null', name: 'AnnouncementPage'); // Log if user ID is null
    }
    setState(() {
      _isLoading = false; // Set loading state to false after fetching is complete
    });
  }

  // Method to show a dialog for adding a new announcement
  void _addAnnouncement() {
    if (_organizationId == null) { // Check if organization ID is available
      developer.log('Organization ID is not available.', name: 'AnnouncementPage'); // Log if organization ID is missing
      return;
    }

    // Show dialog to enter the announcement title and content
    showDialog(
      context: context,
      builder: (context) {
        String title = ''; // Initialize title
        String content = ''; // Initialize content
        return AlertDialog(
          title: const Text('Add Announcement'), // Dialog title
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Title'), // Input field for title
                onChanged: (value) {
                  title = value; // Update title value
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Content'), // Input field for content
                onChanged: (value) {
                  content = value; // Update content value
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog on 'Cancel' button press
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && content.isNotEmpty) { // Check if title and content are not empty
                  developer.log('Adding announcement with title: $title', name: 'AnnouncementPage'); // Log announcement addition
                  _databaseService.createAnnouncement(title, content, _organizationId!); // Call database service to create announcement
                } else {
                  developer.log('Title or content is empty', name: 'AnnouncementPage'); // Log if fields are empty
                }
                Navigator.pop(context); // Close the dialog after adding
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) { // Show loading indicator while fetching organization ID
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_organizationId == null) { // Display message if organization ID is not available
      return const Scaffold(
        appBar: CustomAppBar(title: 'Announcements'),
        body: Center(child: Text('Unable to fetch organization details.')),
      );
    }

    // Main UI for displaying and managing announcements
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Announcements',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAnnouncement, // Trigger the add announcement dialog
          ),
        ],
      ),
      drawer: const CollapsibleSidebarOrganization(), // Sidebar for navigation
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: StreamBuilder<QuerySnapshot>(
            // Stream to fetch announcements from Firestore, filtered by organization ID
            stream: _firestore
                .collection('announcements')
                .where('organizationId', isEqualTo: _organizationId) // Filter by organization ID
                .orderBy('timestamp', descending: true) // Order announcements by timestamp, most recent first
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) { // Show loading indicator while fetching data
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) { // Handle any errors during fetching
                developer.log('Err: ${snapshot.error}', name: 'AP');
                return const Center(child: Text('Error loading announcements'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { // Check if there are no announcements
                return const Center(child: Text('No announcements found'));
              }

              var announcements = snapshot.data!.docs; // Get the list of announcements

              // Build a list of announcements
              return ListView.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  var announcement = announcements[index];
                  String announcementId = announcement.id; // Get announcement ID
                  String title = announcement['title']; // Get announcement title
                  String content = announcement['content']; // Get announcement content

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(title), // Display title
                      subtitle: Text(content), // Display content
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                            onPressed: () {
                              developer.log('Editing announcement ID: $announcementId', name: 'AnnouncementPage'); // Log editing action
                              _databaseService.updateAnnouncement(announcementId, title, content); // Call service to update the announcement
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () {
                              developer.log('Deleting announcement ID: $announcementId', name: 'AnnouncementPage'); // Log deletion action
                              _databaseService.deleteAnnouncement(announcementId); // Call service to delete the announcement
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
