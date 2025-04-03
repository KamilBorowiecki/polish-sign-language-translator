import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override 
  State<RecordingPage> createState() => _RecordingPage();
}   

class _RecordingPage extends State<RecordingPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  List<String> messages = ["Hello!", "How are you?", "Goodbye!"];
  List<String> sentences = [];
  String outMessage = "";
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0], 
        ResolutionPreset.medium,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  } 

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Sprawdzamy, czy swipe odbył się w prawo
        if (details.primaryVelocity! < 0) {
          // Jeśli tak, przechodzimy do RecordingPage
          Navigator.pushNamed(context, 'homepage');
        }
      },
      child: Scaffold(
      backgroundColor: Colors.green[300],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        centerTitle: true,
        title: const Text("R E C O R D I N G   P A G E",
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
            // po nacisnieciu w kamere zaczyna nagrywac 
            // po ponowym nacisnieciu przestacje 
            // tekst w postaci dymkow 
            alignment: Alignment.center,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(25),
              child: _cameraController != null && _cameraController!.value.isInitialized
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CameraPreview(_cameraController!),
                  )
                : Center(
                    child: Text(
                      "CAM",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
            )
          ),
          Expanded(
            flex: 1,
            child: _buildMessageList()
            
            ),
        ]
      )
      )
    );
  }

  Widget _buildMessageList() {
    for (var message in messages) {
      if( message == " ") { 
        sentences.insert(0, outMessage);
        outMessage = "";
        // messages.remove(message);
        break;
      } 

      outMessage += message;
      outMessage += " ";
      // messages.remove(message);
    }

    outMessage = "";
    //sentences = [];
    return ListView.separated(
      reverse: true,
      itemCount: sentences.length,
      itemBuilder: (context, index) {
        return _buildMessageItem(sentences[index]);
      },
    separatorBuilder: (context, index) {
      return SizedBox(height: 25);  
    },  
    );
  }

  Widget _buildMessageItem(String sentence) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double maxWidth = constraints.maxWidth; 

      double rightPadding = (maxWidth * 0.4) - (sentence.length * 2.0);
      rightPadding = rightPadding.clamp(8.0, maxWidth * 0.5); 

      return Padding(
        padding: EdgeInsets.only(
          left: 8.0,  
          right: rightPadding,  
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(8),
          child: Text(
            sentence,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      );
    },
  );
}

}   