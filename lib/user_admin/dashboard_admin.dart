import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_admin.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:ui';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
      ),
      drawer: const CollapsibleSidebarAdmin(),
      body: const CustomBackground(
        child: AdminContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Admin control logic here
        },
        child: const Icon(Icons.admin_panel_settings),
      ),
    );
  }
}

class AdminContent extends StatelessWidget {
  const AdminContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: CarouselSlider(
            options: CarouselOptions(
              height: 250.0,
              autoPlay: true,
              enlargeCenterPage: true,
            ),
            items: const [
              // TODO: Replace hardcoded content with dynamic content
              CarouselItem(image: AssetImage('assets/ioslogo.jpg')),
              CarouselItem(image: AssetImage('assets/socitechlogo.jpg')),
              CarouselItem(image: AssetImage('assets/entreple.jpg')),
              CarouselItem(image: AssetImage('assets/psabe.jpg')),
              CarouselItem(image: AssetImage('assets/pitching.jpg')),
              CarouselItem(image: AssetImage('assets/osa.jpg')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Center(child: Text('Admin Content')),
        const SizedBox(height: 20),
        const AnnouncementsView(),

      ],
    );
  }
}

class CarouselItem extends StatelessWidget {
  final ImageProvider image;

  const CarouselItem({
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: image,
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            Center(
              child: Image(
                image: image,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementsView extends StatelessWidget {
  const AnnouncementsView({super.key});

  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    await Firebase.initializeApp(); // Initialize Firebase
    final CollectionReference announcements =
    FirebaseFirestore.instance.collection('announcements');
    final QuerySnapshot snapshot = await announcements.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching announcements'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No announcements available'));
        } else {
          final announcements = snapshot.data!;
          return Container(
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Center(
                  child: Text(
                    'Announcements',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                for (var announcement in announcements)
                  AnnouncementItem(
                    title: announcement['title'],
                    content: announcement['content'],
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}

class AnnouncementItem extends StatelessWidget {
  final String title;
  final String content;

  const AnnouncementItem({
    required this.title,
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(content),
        ],
      ),
    );
  }
}
