import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/database_service.dart';
import 'package:flutter_ios/widgets/background.dart';
import 'package:flutter_ios/widgets/button.dart';
import 'package:flutter_ios/widgets/textfield.dart';

class OrganizationSignupScreen extends StatefulWidget {
  const OrganizationSignupScreen({super.key});

  @override
  State<OrganizationSignupScreen> createState() => _OrganizationSignupScreenState();
}

class _OrganizationSignupScreenState extends State<OrganizationSignupScreen> {
  final AuthService _auth = AuthService();
  final DatabaseService _dbService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _orgName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  String? _selectedProgram;
  List<String> _programList = [];

  @override
  void initState() {
    super.initState();
    _fetchPrograms();
  }

  Future<void> _fetchPrograms() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('degree_programs').get();
      List<String> programs = querySnapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        _programList = programs;
      });
    } catch (e) {
      debugPrint("Error fetching programs: $e");
    }
  }

  @override
  void dispose() {
    _orgName.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                "Organization Signup",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 50),
              CustomTextField(
                hint: "Enter Organization Name",
                label: "Organization Name",
                controller: _orgName,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hint: "Enter Email",
                label: "Email",
                controller: _email,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hint: "Enter Phone Number",
                label: "Phone Number",
                controller: _phone,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hint: "Enter Password",
                label: "Password",
                isPassword: true,
                controller: _password,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedProgram,
                hint: const Text("Select Program"),
                items: _programList.map((String program) {
                  return DropdownMenuItem<String>(
                    value: program,
                    child: Text(program),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProgram = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Program",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                label: "Signup",
                onPressed: _handleSignup,
              ),
              const Spacer()
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignup() async {
    if (_orgName.text.isEmpty || _email.text.isEmpty || _phone.text.isEmpty || _password.text.isEmpty || _selectedProgram == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Please fill out all fields."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    try {
      // Create the user in Firebase Authentication
      await _signup();

      // Get the current user's UID from Firebase Auth
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception("Failed to retrieve user ID after signup.");
      }

      // Use the user's UID as the organization ID
      String organizationId = userId;

      // Organization data to be saved in Firestore
      final orgData = {
        'name': _orgName.text,
        'program': _selectedProgram,
        'organizationId': organizationId, // Save the UID as organizationId
      };

      // Organization user data
      final user = OrgUser(
        name: _orgName.text,
        email: _email.text,
        phone: _phone.text,
        program: _selectedProgram!,
        userLevel: "organization_user",
        organizationId: organizationId, // Assign the same UID as organizationId
      );

      // Save the organization and user details in Firestore
      await _dbService.createOrg(orgData, user);

      // Save the organizationId to the user's document in Firestore
      await _firestore.collection('users').doc(userId).set({
        'organizationId': organizationId,
        'name': _orgName.text,
        'email': _email.text,
        'phone': _phone.text,
      });

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Signup failed: $e");
    }

    // Send email verification after sign-up
    await _auth.sendEmailVerificationLink();
  }


  Future<void> _signup() async {
    await _auth.createUserWithEmailAndPassword(_email.text, _password.text);
  }
}

class OrgUser {
  final String name;
  final String email;
  final String phone;
  final String program;
  final String userLevel;
  final String organizationId; // Add organizationId to the OrgUser class

  OrgUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.program,
    required this.userLevel,
    required this.organizationId,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'program': program,
    'user_level': userLevel,
    'organizationId': organizationId,
  };
}
