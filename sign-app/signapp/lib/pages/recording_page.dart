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
  final List<String> entries1 = <String>["hello", "how are you", "helloas"];

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
        if (details.primaryVelocity! < 0) {
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
              padding: EdgeInsets.all(30),
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
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildMessageList(),
              ),
          ),
        ]
      )
      )
    );
  }

  Widget _buildMessageList() {
    return ListView.separated(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 80), 
      itemCount: entries1.length,
      reverse: true,
      itemBuilder: (BuildContext context, int index) {
        return _buildMessageItem(entries1[index]);
      },
      separatorBuilder: (BuildContext context, int index) => SizedBox(height: 25),
    );
  }

  Widget _buildMessageItem(String sentence) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double sentenceLength(String text){
          var count = 0.0;
          for(var letter in text.split('')){
            if(letter == ' '){
              count += 5;
            }
            else{
              count += 15;
            }
          }
          return count;
        }
        double rightPadding = maxWidth - sentenceLength(sentence);

        return Padding(
          padding: EdgeInsets.only( 
            right: rightPadding,  
          ),
          child: Container(
            alignment: Alignment.centerLeft,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(15),
            child: Text(
              sentence,
              style: const TextStyle(
                fontSize: 18,
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