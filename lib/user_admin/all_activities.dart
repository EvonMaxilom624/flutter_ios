import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_admin.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class AllActivities extends StatelessWidget {
  const AllActivities({super.key});

  Widget _buildEventCard(String eventName, String date, String location) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(eventName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $date'),
            Text('Location: $location'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: children,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'All Activities',
      ),
      drawer: const CollapsibleSidebarAdmin(),
      body: CustomBackground(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSection(
                    'Events Conducted',
                    [
                      _buildEventCard(
                        'Tech Summit 2023',
                        '2023-01-15',
                        'USTP - Cagayan de Oro',
                      ),
                      _buildEventCard(
                        'Workshop on Flutter',
                        '2023-02-20',
                        'Online',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  _buildSection(
                    'Ongoing Events',
                    [
                      _buildEventCard(
                        'USTP - Claveria: 2nd Semester Midterm Preparation',
                        '2023-04-01/07',
                        'Claveria Campus',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  _buildSection(
                    'Upcoming Events',
                    [
                      _buildEventCard(
                        'Career Fair 2023',
                        '2023-04-10',
                        'USTP - Cagayan de Oro',
                      ),
                      _buildEventCard(
                        'Hackathon',
                        '2023-05-20',
                        'USTP - Cagayan de Oro',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AllActivities(),
  ));
}
