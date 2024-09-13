import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/auth/login_screen.dart';
import 'package:flutter_ios/user_admin/organization_list.dart';
import 'package:flutter_ios/widgets/background.dart';
import 'package:flutter_ios/widgets/button.dart';
import 'package:flutter_ios/wrapper.dart';

class VerificationScreen extends StatefulWidget {
  final String userType;

  const VerificationScreen({super.key, required this.userType});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _auth = AuthService();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _auth.sendEmailVerificationLink();
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified == true) {
        timer.cancel();
        if (widget.userType == 'general_user') {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Wrapper(),
              ));
        } else if (widget.userType == 'organization_user') {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OrganizationList(),
              ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "We have sent an email for verification",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: "Resend Email",
                  onPressed: () async {
                    _auth.sendEmailVerificationLink();
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: "Go to Login",
                  onPressed: () async {
                    const LoginScreen();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
