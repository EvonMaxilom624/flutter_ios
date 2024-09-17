
import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_admin.dart';
import 'package:flutter_ios/user_admin/new_organization.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationList extends StatefulWidget {
  const OrganizationList({super.key});

  @override
  State<OrganizationList> createState() => OrganizationListPageState();
}

class OrganizationListPageState extends State<OrganizationList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Organization>> _getOrganizations() {
    return _firestore
        .collection('users')
        .where('user_level', isEqualTo: 'organization_user')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Organization.fromFirestore(doc)).toList());
  }

  Future<void> _deleteOrganization(String docId) async {
    try {

      // Delete documents from Firestore
      await _firestore.collection('users').doc(docId).delete();
      await _firestore.collection('organizations').doc(docId).delete();
      //TODO add DELETE function for firebase authentication account

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting organization or user account: $e')),
      );
    }
  }


  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this organization?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _deleteOrganization(docId); // Call the delete function
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Organization List',
      ),
      drawer: const CollapsibleSidebarAdmin(),
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
                          builder: (context) => const OrganizationSignupScreen(),
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
                            AssetImage(organizations[index].logoImagePath),
                          ),
                          title: Text(organizations[index].name),
                          subtitle: Text(organizations[index].description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                tooltip: "Edit",
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // TODO: Implement edit functionality
                                },
                              ),
                              IconButton(
                                tooltip: "Delete",
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _confirmDelete(
                                      context, organizations[index].docId);
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
          ],
        ),
      ),
    );
  }
}

class Organization {
  final String name;
  final String logoImagePath;
  final String description;
  final String docId;

  Organization({
    required this.name,
    required this.logoImagePath,
    required this.description,
    required this.docId,
  });

  factory Organization.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Organization(
      name: data['name'] ?? 'No Name',
      logoImagePath: 'assets/default_logo.jpg', // Default logo path
      description: data['program'] ?? 'No Description',
      docId: doc.id, // Add document ID for deletion
    );
  }
}
