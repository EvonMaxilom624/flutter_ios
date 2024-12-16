import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/sidebar/sidebar_admin.dart'; // Changed sidebar import
import 'package:flutter_ios/user_admin/admin_profile_edit_page.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Keep this import for Firebase Storage


class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _uid = '';  // Changed to uid
  String _name = "Admin Name"; // Changed name
  bool _isLoading = true;
  String? _email = '';
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserId();  // Changed function name
  }

  Future<void> _fetchUserId() async {
    final userId = AuthService().currentUser?.uid;
    if (userId != null) {
      try {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          setState(() {
            _uid = userDoc['uid'];
            _loadUserDetails();
          });
        }
      } catch (e) {
        log('Error fetching user ID: $e');
      }
    }
  }

  Future<void> _loadUserDetails() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _name = data['name'];
          _email = data['email'];
          _imageUrl = data['imageUrl'];
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error loading user details: $e');
    }
  }


  void _navigateToEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProfileEditPage(
          uid: _uid,
          name: _name,
          email: _email,
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
        title: 'Admin Profile', // Changed title
      ),
      drawer: const CollapsibleSidebarAdmin(), // Changed drawer
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
                      : null,
                  child: _imageUrl == null || _imageUrl!.isEmpty
                      ? const Icon(
                    Icons.person,
                    size: 70,
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                _name,
                style: const TextStyle(fontSize: 19.0),
              ),
              const SizedBox(height: 5.0),
              Text(
                _email ?? 'No Email',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 5.0),
              const Divider(),
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