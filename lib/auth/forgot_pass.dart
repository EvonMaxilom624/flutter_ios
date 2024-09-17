import 'package:flutter/material.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';
import 'package:flutter_ios/widgets/button.dart';
import 'package:flutter_ios/widgets/textfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _auth = AuthService();
  final _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Forgot Password',
      ),
      body: CustomBackground(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Enter email to send you a password reset email"),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                    controller: _email, hint: "Enter email", label: "Email"),
                const SizedBox(
                  height: 20,
                ),
                CustomButton(
                  label: "Send Email",
                  onPressed: () async {
                    await _auth.sendPasswordresetLink(_email.text);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "An email for password reset has been sent to your email")));
                    Navigator.pop(context);
                  },
                )
              ],
            )),
      ),
    );
  }
}
