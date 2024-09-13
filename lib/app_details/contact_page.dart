import 'package:flutter/material.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class ContactPage extends StatelessWidget {
  final Widget sidebar;
  const ContactPage({super.key, required this.sidebar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Contact',
      ),
      drawer: sidebar,
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              color: Colors.white.withOpacity(0.8),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20.0),
                    const CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage('evon.jpg'),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Evon Q. Maxilom',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 10.0),
                    _buildContactDetail(
                        'Course: Bachelor of Science in Information Technology'),
                    // Replace with developer's course
                    _buildContactDetail(
                        'Organization: Society of Information Technologists'),
                    // Replace with developer's organization
                    _buildContactDetail(
                        'Address: Purok 2, Poblacion, Claveria, 9004 Misamis Oriental, Philippines'),
                    // Replace with developer's address
                    _buildContactDetail('Contact Number: 09365760056'),
                    // Replace with developer's contact number
                    _buildContactDetail('Contact Number: 09127889950'),
                    // Replace with developer's contact number
                    _buildContactDetail('Email: maxilom.evon02@gmail.com'),
                    // Replace with developer's email
                    // Add more details as needed
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactDetail(String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        detail,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14.0,
        ),
      ),
    );
  }
}
