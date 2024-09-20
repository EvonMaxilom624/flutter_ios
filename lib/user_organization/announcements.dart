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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();
  String? _organizationId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    developer.log('Initializing AnnouncementPage', name: 'AnnouncementPage');
    _fetchOrganizationId();
  }

  Future<void> _fetchOrganizationId() async {
    final userId = AuthService().currentUser?.uid;
    developer.log('Fetching organization ID for user: $userId',
        name: 'AnnouncementPage');
    if (userId != null) {
      try {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          setState(() {
            _organizationId = userDoc.id;
            developer.log('Organization ID fetched: $_organizationId',
                name: 'AnnouncementPage');
          });
        } else {
          developer.log('User document does not exist',
              name: 'AnnouncementPage');
        }
      } catch (e) {
        developer.log('Error fetching organization ID: ${e.toString()}',
            name: 'AnnouncementPage');
      }
    } else {
      developer.log('User ID is null', name: 'AnnouncementPage');
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _addAnnouncement() {
    if (_organizationId == null) {
      developer.log('Organization ID is not available.',
          name: 'AnnouncementPage');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String content = '';
        return AlertDialog(
          title: const Text('Add Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Content'),
                onChanged: (value) {
                  content = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && content.isNotEmpty) {
                  developer.log('Adding announcement with title: $title',
                      name: 'AnnouncementPage');
                  _databaseService.createAnnouncement(
                      title, content, _organizationId!);
                } else {
                  developer.log('Title or content is empty',
                      name: 'AnnouncementPage');
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Function to show the edit announcement dialog
  void _showEditAnnouncementDialog(
      String announcementId, String initialTitle, String initialContent) {
    String title = initialTitle;
    String content = initialContent;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: title),
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: content),
                decoration: const InputDecoration(labelText: 'Content'),
                onChanged: (value) {
                  content = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && content.isNotEmpty) {
                  developer.log('Updating announcement with title: $title',
                      name: 'AnnouncementPage');
                  _databaseService.updateAnnouncement(
                      announcementId, title, content);
                } else {
                  developer.log('Title or content is empty',
                      name: 'AnnouncementPage');
                }
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_organizationId == null) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'Announcements'),
        body: Center(child: Text('Unable to fetch organization details.')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Announcements',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAnnouncement,
          ),
        ],
      ),
      drawer: const CollapsibleSidebarOrganization(),
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('announcements')
                .where('organizationId', isEqualTo: _organizationId)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                developer.log('Err: ${snapshot.error}', name: 'AP');
                return const Center(child: Text('Error loading announcements'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No announcements found'));
              }

              var announcements = snapshot.data!.docs;

              return ListView.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  var announcement = announcements[index];
                  String announcementId = announcement.id;
                  String title = announcement['title'];
                  String content = announcement['content'];

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(title),
                      subtitle: Text(content),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                            onPressed: () {
                              developer.log(
                                  'Editing announcement ID: $announcementId',
                                  name: 'AnnouncementPage');
                              _showEditAnnouncementDialog(
                                  announcementId, title, content);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () {
                              // Show confirmation dialog before deleting
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirm Delete"),
                                    content: const Text(
                                        "Are you sure you want to delete this announcement?"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                      TextButton(
                                        child: const Text("Delete"),
                                        onPressed: () {
                                          developer.log(
                                              'Deleting announcement ID: $announcementId',
                                              name: 'AnnouncementPage');
                                          _databaseService
                                              .deleteAnnouncement(announcementId);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
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