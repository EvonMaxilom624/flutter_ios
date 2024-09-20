import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/sidebar/sidebar_org.dart';
import 'package:flutter_ios/user_organization/profile_edit.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class OrgProfilePage extends StatefulWidget {
  const OrgProfilePage({super.key});

  @override
  State<OrgProfilePage> createState() => _OrgProfilePageState();
}

class _OrgProfilePageState extends State<OrgProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _organizationId = '';
  String _name = "Organization Name";
  bool _isLoading = true;
  List<Map<String, dynamic>> _positions = [];
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchOrganizationId();
  }

  Future<void> _fetchOrganizationId() async {
    final userId = AuthService().currentUser?.uid;
    if (userId != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('organizations').doc(userId).get();
        if (userDoc.exists) {
          setState(() {
            _organizationId = userDoc['organizationId'];
            _loadOrganizationDetails();
          });
        }
      } catch (e) {
        log('Error fetching organization ID: $e');
      }
    }
  }

  Future<void> _loadOrganizationDetails() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('organizations')
          .doc(_organizationId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _name = data['name'];
          _imageUrl = data['imageUrl'];
          _positions = data['positions'] != null
              ? List<Map<String, dynamic>>.from(data['positions'])
                  .map((position) => {
                        'position': position['position'],
                        'assignedPerson': position['assignedPerson'],
                        'rank': position['rank'],
                      })
                  .toList()
              : [];

// Then sort by rank:
          _positions.sort((a, b) => a['rank'].compareTo(b['rank']));
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error loading organization details: $e');
    }
  }

  void _navigateToEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrgProfileEditPage(
          organizationId: _organizationId,
          name: _name,
          positions: _positions,
          imageUrl: _imageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Organization Profile',
      ),
      drawer: const CollapsibleSidebarOrganization(),
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: _imageUrl != null && _imageUrl!.isNotEmpty
                      ? NetworkImage(_imageUrl!)
                      : null, // No image, so it will fall back to the child widget
                  child: _imageUrl == null || _imageUrl!.isEmpty
                      ? const Icon(
                    Icons.person, // Default icon for profile
                    size: 70,
                  )
                      : null, // If there is an image, don't show the icon
                ),
              ),

              const SizedBox(height: 8.0),
              Text(
                _name,
                style: const TextStyle(fontSize: 19.0),
              ),
              const SizedBox(height: 5.0),
              const Divider(),
              const Text(
                "Officers",
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              ..._positions.map((position) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${position['position']}:"),
                      Text(position['assignedPerson']),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _navigateToEditPage,
                child: const Text("Edit Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
