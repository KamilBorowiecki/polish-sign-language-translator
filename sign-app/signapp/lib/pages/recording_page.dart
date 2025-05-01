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
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:logger/logger.dart';
import 'package:image/image.dart' as img;



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
  String? output;

  @override
void initState() {
  super.initState();
  initializeEverything();
}

Future<void> initializeEverything() async {
  await _initializeCamera(); 
  try {
    socket = socket_io.io(
      'http://192.168.68.108:5000',
      // 'http://192.168.0.105:5000',
      // 'http://172.20.10.2:5000',
      socket_io.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build()
    );
    socket?.connect();
  } catch (e) {
    Logger().e('Socket init error: $e');
  }
  setupListeners();
  startImageStream(); 
}


  void setupListeners(){
    socket?.on('connect', (_) => Logger().i('Connected'));
    socket?.on('response_back', (stringData){
      Logger().i('respnse back dziala');
      setState(() {
        entries1[0] = stringData;
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
  if (_cameraController != null && _cameraController!.value.isRecordingVideo && !isCapturing) {
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

Future<Uint8List?> convertCameraImageToJpeg(CameraImage cameraImage) async {
  try {
    if (cameraImage.format.group != ImageFormatGroup.yuv420) {
      return null;
    }

    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final imgData = cameraImage.planes;
    final yPlane = imgData[0].bytes;
    final uPlane = imgData[1].bytes;
    final vPlane = imgData[2].bytes;

    final img.Image convertedImage = img.Image(width: width, height: height);

    int uvRowStride = imgData[1].bytesPerRow;
    int uvPixelStride = imgData[1].bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
        final int index = y * width + x;

        final yp = yPlane[index];
        final up = uPlane[uvIndex];
        final vp = vPlane[uvIndex];

        int r = (yp + (1.370705 * (vp - 128))).round();
        int g = (yp - (0.698001 * (vp - 128)) - (0.337633 * (up - 128))).round();
        int b = (yp + (1.732446 * (up - 128))).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        convertedImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    final jpeg = img.encodeJpg(convertedImage, quality: 85);
    return Uint8List.fromList(jpeg);
  } catch (e) {
    Logger().e('Error converting image: $e');
    return null;
  }
}

Future<void> startImageStream() async {
  if (_cameraController == null) {
    Logger().i('camera controller is null');
    return;
  }
  Logger().i("start image stream");
  if (_cameraController!.value.isStreamingImages) {
       Logger().i('The camera is already streaming images.');
  }

  try {
    Logger().i("przed start image stream");
    bool isSending = false;
    await _cameraController!.startImageStream((CameraImage image) async {
      if (isSending) return;
      isSending = true;
      final bytes = await convertCameraImageToJpeg(image);
      if (bytes != null) {
        final img64 = base64Encode(bytes);
        socket?.emit('image', img64);
      }
      await Future.delayed(Duration(milliseconds: 66)); 
      isSending = false;
    });
  } on CameraException catch (e) {
    Logger().e('Stream error: ${e.description}');
  }
}



  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![1], 
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
              child: _cameraController != null && _cameraController!.value.isInitialized
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