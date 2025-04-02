import 'package:flutter/material.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override 
  State<RecordingPage> createState() => _RecordingPage();
}   

class _RecordingPage extends State<RecordingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[300],
      appBar: AppBar(
        backgroundColor: Colors.teal[500],
        centerTitle: true,
        title: const Text("H O M E   P A G E",
        style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
          )
        )
      ),
      body: Column(
        children: [
          SizedBox(height: 50),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(25),
              child: Text(
                "CAM",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.teal[500],
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                )
                )
            )
          )
          // tekst dodawny w formie konwersacji
        ]
      )
    );
  }
}   