import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[300],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
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
              height: 140,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(25),
              child: Text(
                "SignApp",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                )
                )
            )
          ),
          SizedBox(height: 50),
          Align(
            alignment: Alignment.topCenter,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
  
                minimumSize: const Size(200, 60),
                backgroundColor: Colors.white, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), 
                ),
              ),
              child: Text(
                "START",
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, 'recordingpage');
              },
            ),
          )
        ]
      ),
    );
  }
}