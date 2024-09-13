import 'package:flutter/material.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class FAQsPage extends StatelessWidget {
  final Widget sidebar;
  const FAQsPage({super.key, required this.sidebar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'FAQ',
      ),
      drawer: sidebar,
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildFAQ('How do I register as a user?',
                  'To register as a user, go to the "Register New User" page and follow the instructions.'),
              _buildFAQ('How do I login as an admin?',
                  'To login as an admin, go to the "Admin Login" page and enter your credentials.'),
              _buildFAQ('How can I schedule an event?',
                  'To schedule an event, login as an admin and navigate to the "Schedule Event" page.'),
              _buildFAQ('Can I edit or delete an event after scheduling it?',
                  'Yes but only admins can edit or delete events after scheduling them. Simply navigate to the "Manage Events" page.'),
              _buildFAQ('Is the app available on both iOS and Android?',
                  'Yes, the app is cross-platform and available for both iOS and Android devices. You can also access this in the webpage.'),
              _buildFAQ('How can I contact support if I encounter issues?',
                  'You can contact support by emailing ios.support@gmail.com or calling 09123456789.'),
              _buildFAQ('Are there any fees associated with using the app?',
                  'No, the app is free to use for all users and organizations.'),
              _buildFAQ('Is my personal information secure on the app?',
                  'Yes, we take privacy and security seriously. Your personal information is encrypted and protected.'),
              _buildFAQ('Can I join multiple organizations on the app?',
                  'Yes, you can join multiple organizations and participate in their events. Please refer to the student handbook about the school organizations'),
              _buildFAQ('How often is the app updated with new features?',
                  'We strive to update the app regularly with new features and improvements. Updates are typically released every few months.'),
              // Add more FAQs as needed
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      color: Colors.white.withOpacity(0.8), // Opaque white color
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}
