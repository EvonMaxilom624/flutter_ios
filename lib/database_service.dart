import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/auth/signup_screen.dart';
import 'package:flutter_ios/dev/create_admin.dart';
import 'package:flutter_ios/user_admin/new_organization.dart';

class DatabaseService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  // Create for general user
  Future<void> create(AppUser user) async {
    final String? userId = AuthService().currentUser?.uid;

    if (userId != null) {
      await _fire.collection('users').doc(userId).set(user.toMap());
    // } catch (e) {
    //   developer.log('Error creating user: ${e.toString()}');
    //
      }

  }

  // Create for admin user
  Future<void> admincreate( AdminUser user) async {
    final String? userId = AuthService().currentUser?.uid;

    if (userId != null) {
      await _fire.collection('users').doc(userId).set(user.toMap());
    }

  }

  // Create for organization user
  Future<void> createOrg(Map<String, dynamic> orgData, OrgUser user) async {
    final String? userId = AuthService().currentUser?.uid;

    if (userId != null) {
      // Save organization data to the 'organizations' collection
      await _fire.collection('organizations').doc(userId).set(orgData);
      // Save user data to the 'users' collection
      await _fire.collection('users').doc(userId).set(user.toMap());
    }
  }

  //TODO complete CRUD
  // CRUD operations for users
  Future<void> read() async {
    try {
      final data = await _fire.collection("users").get();
      final user = data.docs[0];
      developer.log(user["name"]);
      developer.log(user["age"].toString());
    } catch (e) {
      developer.log(e.toString());
    }
  }

  Future<void> update() async {
    try {
      await _fire
          .collection("users")
          .doc("LV7gBzWJwnthK470RJjS")
          .update({"name": "Tested", "age": 30, "address": "Claveria"});
    } catch (e) {
      developer.log(e.toString());
    }
  }

  Future<void> delete() async {
    try {
      await _fire.collection("users").doc("LV7gBzWJwnthK470RJjS").delete();
    } catch (e) {
      developer.log(e.toString());
    }
  }

  // Methods for announcements
  Future<void> createAnnouncement(String title, String content, String organizationId) async {
    try {
      await _fire.collection('announcements').add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'organizationId': organizationId,
      });
      developer.log('Announcement created for organization: $organizationId');
    } catch (e) {
      developer.log('Error creating announcement: ${e.toString()}');
    }
  }

  Future<void> updateAnnouncement(String announcementId, String title, String content) async {
    try {
      await _fire.collection('announcements').doc(announcementId).update({
        'title': title,
        'content': content,
      });
      developer.log('Announcement updated with ID: $announcementId');
    } catch (e) {
      developer.log('Error updating announcement: ${e.toString()}');
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _fire.collection('announcements').doc(announcementId).delete();
      developer.log('Announcement deleted with ID: $announcementId');
    } catch (e) {
      developer.log('Error deleting announcement: ${e.toString()}');
    }
  }
}
