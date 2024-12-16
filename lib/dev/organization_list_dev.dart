import 'package:flutter/material.dart';
import 'package:flutter_ios/dev/new_organization_dev.dart';
import 'package:flutter_ios/sidebar/sidebar_developer.dart';
import 'package:flutter_ios/user_admin/new_organization.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer'; // For logging

class DeveloperOrganizationList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get organizations from Firestore
  Stream<List<Organization>> _getOrganizations() {
    return _firestore
        .collection('organizations')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Organization.fromFirestore(doc))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Developer Organization List',
      ),
      drawer: const CollapsibleSidebarDeveloper(),  // Developer-specific drawer
      body: CustomBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrganizationSignupScreenDev(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_box_outlined),
                    label: const Text("Register new Organization"),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<List<Organization>>(
                stream: _getOrganizations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No organizations found'));
                  }
                  final organizations = snapshot.data!;
                  return ListView.builder(
                    itemCount: organizations.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                            NetworkImage(organizations[index].imageUrl),
                          ),
                          title: Text(organizations[index].name),
                          subtitle: Text(organizations[index].program),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Organization {
  final String name;
  final String imageUrl;
  final String program;
  final String docId;

  Organization({
    required this.name,
    required this.imageUrl,
    required this.program,
    required this.docId,
  });

  factory Organization.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Organization(
      name: data['name'] ?? 'No Name',
      imageUrl: data['imageUrl'] ?? '', // Default logo path
      program: data['program'] ?? 'No program',
      docId: doc.id,
    );
  }
}
