import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


class CustomBackground extends StatefulWidget {
  final Widget child;
  final String backgroundImage;

  const CustomBackground({
    super.key,
    required this.child,
    this.backgroundImage = 'newbg.jpg',
  });

  @override
  State<CustomBackground> createState() => _CustomBackgroundState();
}

class _CustomBackgroundState extends State<CustomBackground> {
  ImageProvider? _backgroundImageProvider;

  @override
  void initState() {
    super.initState();
    _fetchBackgroundImage();
  }

  Future<void> _fetchBackgroundImage() async {
    try {
      final storageRef =
      FirebaseStorage.instance.ref().child(widget.backgroundImage);
      final downloadUrl = await storageRef.getDownloadURL();
      log('Download URL: $downloadUrl');

      setState(() {
        _backgroundImageProvider = NetworkImage(downloadUrl);
      });
    } catch (e) {
      log('Error fetching image: $e');
      // In case of error, use the default image
      setState(() {
        _backgroundImageProvider = const AssetImage('assets/newbg.jpg');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _backgroundImageProvider ??
              const AssetImage(
                  'assets/newbg.jpg'), // Default placeholder image
          fit: BoxFit.cover,
        ),
      ),
      child: widget.child,
    );
  }
}