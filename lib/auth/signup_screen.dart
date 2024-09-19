import 'package:flutter/material.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/auth/login_screen.dart';
import 'package:flutter_ios/database_service.dart';
import 'package:flutter_ios/widgets/background.dart';
import 'package:flutter_ios/widgets/button.dart';
import 'package:flutter_ios/widgets/textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _auth = AuthService(); // Create AuthService instance
  final DatabaseService _dbService = DatabaseService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
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
              const Text("Signup",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
              const SizedBox(
                height: 50,
              ),
              CustomTextField(
                hint: "Enter Name",
                label: "Name",
                controller: _name,
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
              const SizedBox(height: 30),
              CustomButton(
                label: "Signup",
                onPressed: () async {
                  if (_name.text.isEmpty ||
                      _email.text.isEmpty ||
                      _phone.text.isEmpty ||
                      _password.text.isEmpty) {
                    // Show error if any field is empty
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
                    // 1. Create user with Firebase Auth
                    await _auth.createUserWithEmailAndPassword(
                      _email.text,
                      _password.text,
                    );

                    // 2. Get the UID of the newly created user
                    String? uid = _auth.currentUser!.uid;

                    // 3. Create user document in Firestore
                    final user = AppUser(
                      uid: uid, // Add UID to the AppUser
                      name: _name.text,
                      email: _email.text,
                      phone: _phone.text,
                      userLevel: "general_user",
                    );

                    await _dbService.create(user); // Use your _dbService to save data
                    // After successful signup, navigate back
                    Navigator.pop(context);
                                    } catch (e) {
                    debugPrint("Signup failed: $e");
                    // Handle signup errors, perhaps show a user-friendly message
                  }
                },
              ),

              const SizedBox(height: 5),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("Already have an account? "),
                InkWell(
                  onTap: () => goToLogin(context),
                  child:
                  const Text("Login", style: TextStyle(color: Colors.red)),
                )
              ]),
              const Spacer()
            ],
          ),
        ),
      ),
    );
  }

  goToLogin(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );

}

class AppUser {
  final String uid; // Add the UID here
  final String name;
  final String email;
  final String phone;
  final String userLevel;

  AppUser(
      {required this.uid, // Required in the constructor
        required this.name,
        required this.email,
        required this.phone,
        required this.userLevel});

  Map<String, dynamic> toMap() => {
    'uid': uid, // Make sure to include the UID in the map
    'name': name,
    'email': email,
    'phone': phone,
    'user_level': userLevel,
  };
}