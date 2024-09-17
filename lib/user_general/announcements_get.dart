import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_general.dart';
import 'package:flutter_ios/widgets/appbar.dart';

class AnnouncementGeneralPage extends StatefulWidget {
  const AnnouncementGeneralPage({super.key});

  @override
  State<AnnouncementGeneralPage> createState() => AnnouncementGeneralPageState();
}

class AnnouncementGeneralPageState extends State<AnnouncementGeneralPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Announcements',
      ),
      drawer: const CollapsibleSidebarGeneral(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('announcements').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading announcements'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No announcements found'));
          }

          var announcements = snapshot.data!.docs;

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              var announcement = announcements[index];
              String title = announcement['title'];
              String content = announcement['content'];

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(content),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AnnouncementGeneralPage(),
  ));
}
