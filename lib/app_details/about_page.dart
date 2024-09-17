import 'package:flutter/material.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class AboutPage extends StatelessWidget {
  final Widget sidebar;
  const AboutPage({super.key, required this.sidebar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'About',
      ),
      drawer: sidebar,
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureCard(
                  title: 'About Us',
                  content:
                      "The USTP Integrated Organizations' System serves as a centralized hub that allows all USTP accredited student organizations and administrators to facilitate faster communication channels, ensuring that critical information is disseminated seamlessly. The application's primary focus is to empower student organizations to schedule events efficiently, enabling all parties involved to view and coordinate event dates effortlessly.",
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  title: 'Key Features',
                  content:
                      'Browsing Capacity: The application offers browsing capacity to all users, ensuring information reliability and legitimacy.\n\nEvent Scheduling: Accredited organizations and authorized administrators can efficiently schedule events, facilitating seamless coordination.\n\nOrganization Details: Each organization has a dedicated page to present its biography and details, enabling students to explore and participate in groups with shared interests and values.',
                ),
                const SizedBox(height: 16),
                _buildAbout(
                    'Statement of the Problem',
                    'The current issue is around unstructured scheduling systems inside educational institutions, specifically regarding diverse student organizations of USTP. There is currently a lack of an organized and consistent framework to manage and optimize the scheduling of these organizations\' events and activities. The lack of a specific platform leads to inefficiencies, overlaps, and scheduling challenges, impeding the proper operation of these organizations.',
                    'Furthermore, educational institutions face additional obstacles due to a lack of attention to technical improvements in the field of organizational management. The need for a solution that directly tackles unstructured scheduling patterns becomes clear, with the goal of increasing efficiency, reducing conflicts, and promoting a more united and collaborative environment.',
                    'There is currently no standard approach that tackles the unique issues connected with unstructured scheduling of diverse student organizations, particularly within the system of USTP. This study aims to develop a solution that goes beyond traditional database management and delves into the heart of scheduling complexities, providing a unified platform that enables seamless coordination, efficient planning, and improved communication among the USTP\'s diverse organizations. The study will look at the creation of a scheduling system, with an emphasis on unification and meeting the unique needs of USTP\'s organizational environment.'),
                _buildAbout(
                    'Scope and Limitation of the Application',
                    'This system intends to address a gap in the sector by offering an integrated approach centered on effective event scheduling, uniform organization profiles, and improved communication. The system\'s scope includes crucial elements such as a centralized calendar, organization profiles, user authentication and communication media.',
                    '',
                    ''),
                _buildAbout(
                    'Limitation',
                    'While the system pursues to provide a solution, certain limits must be acknowledged. Potential implementation constraints, reliance on internet access, an initial learning curve for users, and limited integration are among the limitations.',
                    '',
                    ''),
                _buildAbout(
                    'Significance of the Application',
                    'In the continually evolving environment of educational institutions, encouraging efficient communication, effective collaboration, and transparent management is essential. Recognizing this requirement, the researcher introduces the "USTP Integrated Organizations\' System," a monumental mobile application designed exclusively for the University of Science and Technology of the Philippines (USTP).',
                    'This new platform is projected to revolutionize the way student organizations function, communicate, and plan events, marking a huge step toward a more connected, transparent, and digitally advanced campus community.',
                    ''),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAbout(String question, String paragraph1, String paragraph2,
      String paragraph3) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      color: Colors.white.withOpacity(0.8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(paragraph1),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(paragraph2),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(paragraph3),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({required String title, required String content}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
