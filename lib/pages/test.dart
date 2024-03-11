// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:audio_recorder/audio_recorder.dart';
// import 'package:path_provider/path_provider.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: VoiceToTextScreen(),
//     );
//   }
// }

// class VoiceToTextScreen extends StatefulWidget {
//   @override
//   _VoiceToTextScreenState createState() => _VoiceToTextScreenState();
// }

// class _VoiceToTextScreenState extends State<VoiceToTextScreen> {
//   stt.SpeechToText _speechToText = stt.SpeechToText();
//   bool _isListening = false;
//   String _text = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Voice to Text'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(_text),
//             ElevatedButton(
//               onPressed: _toggleRecording,
//               child: _isListening ? Text('Stop Recording') : Text('Start Recording'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _toggleRecording() async {
//     if (!_isListening) {
//       if (await AudioRecorder.hasPermissions) {
//         Directory appDocDirectory = await getApplicationDocumentsDirectory();
//         String filePath = '${appDocDirectory.path}/recording.wav';

//         await AudioRecorder.start(
//           path: filePath,
//           audioOutputFormat: AudioOutputFormat.WAV,
//         );

//         if (await AudioRecorder.isRecording) {
//           setState(() {
//             _isListening = true;
//           });

//           _speechToText.listen(
//             onResult: (result) {
//               setState(() {
//                 _text = result.recognizedWords;
//               });
//             },
//             listenFor: Duration(seconds: 30),
//             localeId: 'en_US',
//           );
//         }
//       } else {
//         print('Permissions not granted');
//       }
//     } else {
//       setState(() {
//         _isListening = false;
//         _speechToText.stop();
//         AudioRecorder.stop();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _speechToText.stop();
//     super.dispose();
//   }
// }
