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
  final _auth = AuthService();
  final _dbService = DatabaseService();
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
                onPressed: (){
                  if (_name.text.isEmpty || _email.text.isEmpty || _phone.text.isEmpty) {
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
                    return; // Stop execution if fields are empty
                  }

                  final user = AppUser(
                    name: _name.text,
                    email: _email.text,
                    phone: _phone.text,
                    userLevel: "general_user",
                  );
                  _dbService.create(user);
                  _signup();
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

  _signup() async {
    await _auth.createUserWithEmailAndPassword(
      _email.text,
      _password.text,
    );
    Navigator.pop(context);
  }
}

class AppUser {
  final String name;
  final String email;
  final String phone;
  final String userLevel;

  AppUser(
      {required this.name,
        required this.email,
        required this.phone,
        required this.userLevel});

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'user_level': userLevel,
  };
}
