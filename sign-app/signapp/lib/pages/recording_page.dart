// import 'package:flutter/material.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:logger/logger.dart';

// class RecordingPage extends StatefulWidget {
//   const RecordingPage({super.key});

//   @override
//   State<RecordingPage> createState() => _RecordingPage();
// }

// class _RecordingPage extends State<RecordingPage> {
//   IO.Socket? socket;
//   final TextEditingController _controller = TextEditingController();
//   final logger = Logger();
//   final List<String> responses = []; // Lista odpowiedzi z serwera

//   @override
//   void initState() {
//     super.initState();
//     setupSocket();
//   }

//   // Inicjalizacja socketu
//   void setupSocket() {
//     socket = IO.io(
//       'http://172.20.10.2:5000', 
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .enableAutoConnect()
//           .build(),
//     );

//     // Połączono z serwerem
//     socket?.on('connect', (_) {
//       logger.i('Połączono z serwerem');
//     });

//     // Odebrano odpowiedź z serwera
//     socket?.on('response', (data) {
//       logger.i('Odpowiedź od serwera: ${data['message']}');
//       setState(() {
//         responses.insert(0, data['message']);
//       });
//     });

//     // Rozłączono
//     socket?.on('disconnect', (_) {
//       logger.w('Rozłączono z serwerem');
//     });

//     socket?.on('disconnect', (_) {
//     logger.w('Rozłączono z serwerem');
//   });

//     socket?.on('connect_error', (data) {
//       logger.e('Błąd połączenia: $data');
//     });

//     socket?.on('error', (error) {
//       logger.e('Błąd: $error');
//     });
//   }

//   // Wysyłanie wiadomości do serwera
//   void sendMessage() {
//     if (_controller.text.isNotEmpty) {
//       socket?.emit('message', {'message': _controller.text});
//       _controller.clear();
//     }
//   }

//   @override
//   void dispose() {
//     socket?.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sending Text to Python'),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 labelText: 'Enter message',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: sendMessage,
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               child: const Text('Send to Server'),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 reverse: true,
//                 itemCount: responses.length,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 5),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.green[100],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         responses[index],
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:logger/logger.dart';


class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override 
  State<RecordingPage> createState() => _RecordingPage();
}   

class _RecordingPage extends State<RecordingPage> {
  socket_io.Socket? socket;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  final List<String> entries1 = <String>["hello", "how are you", "helloas"];
  Timer? _timer;
  String? outputCamera;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    try {
    socket = socket_io.io(
      'http://192.168.68.112:5000',
      // 'http://172.20.10.2:5000',
      socket_io.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build()
    );
    setupListeners();
    socket?.connect();
  } catch (e) {
    Logger().e('Socket init error: $e');
  }

    setupListeners();

     _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      sendCameraFrame();
    });

  }

  void setupListeners(){
    socket?.on('connect', (_) => Logger().i('Connected'));
    socket?.on('response_back', (stringData){
      setState(() {
        outputCamera = stringData;
        Logger().i(stringData);
      });
    });
    socket?.on('disconnected', (_) => Logger().e('Disconnected'));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    socket?.close();
    _timer?.cancel();
    super.dispose();
  }

  bool isCapturing = false; 

Future<void> sendCameraFrame() async {
  if (_cameraController != null && _cameraController!.value.isInitialized && !isCapturing) {
    isCapturing = true;

    try {
      final XFile? picture = await _cameraController!.takePicture();

      final bytes = await picture!.readAsBytes();

      String img64 = base64Encode(bytes);

      if (img64.isNotEmpty) {
        socket?.emit('image', img64); 
      }
    } catch (e) {
      Logger().e("Błąd przy robieniu zdjęcia: $e");
    } finally {
      isCapturing = false;
    }
  }
}


  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0], 
        ResolutionPreset.high,
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
              child: outputCamera != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  base64Decode(outputCamera!.split(',').last),
                  fit: BoxFit.cover, 
                ),
              )
            : _cameraController != null && _cameraController!.value.isInitialized
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CameraPreview(_cameraController!),
                  )
                : CircularProgressIndicator(),  
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