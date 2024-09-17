import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyA457lhLkCXcmRaF9u4Oo8jfCWlvwLgtBM",
            authDomain: "flutter-ios-a07fd.firebaseapp.com",
            projectId: "flutter-ios-a07fd",
            storageBucket: "flutter-ios-a07fd.appspot.com",
            messagingSenderId: "822790381402",
            appId: "1:822790381402:web:945697de7c15a734269d63"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: Wrapper());
  }
}

//Login
//Sign-up
//Forgot Password
//Email Verification
//Keep User Logged-in
//Firebase Connection/Authentication
