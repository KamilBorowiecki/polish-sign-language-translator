import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("H O M E P A G E")),
      body: Center(
        child: ElevatedButton(
          child: const Text("GO TO HOME"),
          onPressed: () {
            Navigator.pushNamed(context, 'recordingpage');
          },
        )
      ),
    );
  }
}