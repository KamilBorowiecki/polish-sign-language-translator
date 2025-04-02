import 'package:flutter/material.dart';
import 'package:signapp/pages/home_page.dart';
import 'package:signapp/pages/recording_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,      
      home: const HomePage(),
      routes: {
        'homepage': (context) => const HomePage(),
        'recordingpage': (context) => const RecordingPage(),
      },
    );
  }
}