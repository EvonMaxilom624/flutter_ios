import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/auth/login_screen.dart';
import 'package:flutter_ios/auth/verification_screen.dart';
import 'package:flutter_ios/user_admin/dashboard_admin.dart';
import 'package:flutter_ios/user_general/dashboard_general.dart';
import 'package:flutter_ios/user_organization/dashboard_org.dart';
import 'package:flutter_ios/dev/developer_dashboard.dart';


import 'dart:developer';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  Future<String?> _getUserRole(String email) async {
    try {
      log('[3] [getUserRole] Fetching document for email: $email');
      QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDocs.docs.isNotEmpty) {
        String role = userDocs.docs.first.get('user_level');
        log('[4] [wrapper>getUserRole] User role: $role');
        return role;
      } else {
        log('(Wrapper) User document does not exist');
        return null;
      }
    } catch (e) {
      log('Error loading user role: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            log('Error in auth state change: ${snapshot.error}');
            return const Center(child: Text("Error"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            log('[1] User not logged in, navigating to LoginScreen');
            return const LoginScreen();
          } else {
            User user = snapshot.data!;
            log('[2] User logged in: ${user.email}, emailVerified: ${user.emailVerified}');
            return FutureBuilder<String?>(
              future: _getUserRole(user.email!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData) {
                  log('Error or no data in role fetching: ${snapshot.error}');
                  return const Center(child: Text("Error loading user role"));
                } else {
                  String? role = snapshot.data;

                  if (user.emailVerified) {
                    log('[5] Navigating to dashboard for role: $role');
                    switch (role) {
                      case 'admin':
                        log('[6] Navigating to AdminDashboard');
                        return const AdminDashboard();
                      case 'organization_user':
                        log('[6] Navigating to OrganizationUserDashboard');
                        return const OrganizationUserDashboard();
                      case 'general_user':
                        log('[6] Navigating to GeneralUserDashboard');
                        return const GeneralUserDashboard();
                      case 'developer':
                        log('[6] Welcome Developer!');
                        return const DevBoard();
                        default:
                        log('[6] Navigating to default GeneralUserDashboard');
                        return const GeneralUserDashboard();
                    }
                  } else {
                    log('Email not verified, navigating to VerificationScreen');
                    return VerificationScreen(userType: role ?? 'general_user');
                  }
                }
              },
            );
          }
        },
      ),
    );
  }
}
