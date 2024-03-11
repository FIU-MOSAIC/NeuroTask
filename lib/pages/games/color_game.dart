import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:neuro_task/constant/my_text.dart';
import 'package:neuro_task/constant/responsive.dart';
import 'package:neuro_task/pages/homepage.dart';
import 'package:neuro_task/services/color_game_services.dart';
import 'package:neuro_task/ui/game/game_start_message.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ColorGame extends StatefulWidget {
  const ColorGame({super.key});

  @override
  State<ColorGame> createState() => _ColorGameState();
}

class _ColorGameState extends State<ColorGame> {

  startMessage(){
    return showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const MyText(text: "Color Game", size: 20, bold: true, color: Colors.black,height: 0.05,width: 1),
          actions: [
            const MyText(text: "Read the text loudly.", size: 15, bold: false, color: Colors.black,height: 0.05,width: 1),
            TextButton(
              onPressed: (){
                startListening();
                deviceTime = DateTime.now();
                startTimer();
                Navigator.pop(context);
              }, 
              child: const MyText(text: "OK", size: 20, bold: false, color: Colors.deepPurple,height: 0.05,width: 0.05,),
            ),
          ],
        );
      },
    ).then((value){
      // startListening();
      // _startRecording();
    });
  }
  
  Map<String,Color> colorMap = {
    "Red" : Colors.yellow,
    "Green" : Colors.blue,
    "Blue" : Colors.brown,
    "Yellow" : Colors.green,
    "Orange" : Colors.red,
    "Pink" : Colors.orange,
    "Purple" : Colors.purple,
    "Brown" : Colors.black,
    "Black" : Colors.pink,
  };

  List<String> textColors = [
    "Yellow",
    "Blue",
    "Brown",
    "Green",
    "Red",
    "Orange",
    "Purple",
    "Black",
    "Pink",
    "Yellow",
  ];

  double positionX = 0.0;
  double positionY= 0.0;
  Random random = Random();
  
  void getRandomPosition(){
    positionX = (0 + random.nextDouble() * (0.7 - 0));
    positionY = (0.1 + random.nextDouble() * (0.8 - 0.1));
  }

  int secondCount = 0;
  int index = 0;
  int currentIndex = 0;
  int intervalTime = 3;
  DateTime? deviceTime;
  DateTime? disapearTime;
  double screenHeight = 0.0,screenWidth = 0.0;

  void startTimer(){
    Timer.periodic(const Duration(seconds: 1), (timer) { 
      secondCount++;

      if(secondCount % intervalTime == 0){
        disapearTime = DateTime.now();
        currentIndex = -1;
        if(index < colorMap.length){
          index++;
          stopSpeechRecord();
          ColorGameServices.colorGameDataToFirebase(deviceTime!,disapearTime!,(positionX*screenWidth),(positionY*screenHeight),colorMap.keys.elementAt(index-1),textColors[index-1],voiceToText,intervalTime);
        }
        else{
          timer.cancel();
        }
        setState(() {});
        Future.delayed(const Duration(seconds: 1),(){
          voiceToText = "Skipped";
          secondCount--;

          if(index<colorMap.length){
            currentIndex = index;
            getRandomPosition();
            startListening();
            deviceTime = DateTime.now();
            setState(() {});
          }
        });
      }
    });
  }


  //Speech To Text
  SpeechToText speechToText = SpeechToText();
  FlutterSoundRecorder? _recorder;
  String voiceToText = "Skipped";
  bool isEnabled = false;

  Future<void> speechToTextInitialization() async{
    isEnabled = await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen( onResult: startSpeechRecord);
    setState(() {});
  }

  Future<void> startSpeechRecord(result) async{
    setState(() {
      voiceToText = "${result.recognizedWords}";
    });
  }

  Future<void> stopSpeechRecord() async{
    await speechToText.stop();
    setState(() {});
  }

 //Voice record
//  String? _filePath;
//  bool isRecording = false;

//  Future<void> _initialize() async {
//     _recorder = FlutterSoundRecorder();
//     await Permission.microphone.request();
//     await Permission.storage.request();
//     await _recorder!.openRecorder();
//   }

//   Future<void> _startRecording() async {
//     if(!isRecording){
//       final externalDir = await getExternalStorageDirectory();
//       _filePath = '${externalDir!.path}/recording.aac';
//       await _recorder!.startRecorder(toFile: _filePath, codec: Codec.aacMP4,);
//       setState(() {
//         isRecording = true;
//       });
//     }
//   }

//   Future<void> _stopRecording() async {
//     await _recorder!.stopRecorder();
//     // ignore: avoid_print
//     print('Recording saved to: $_filePath');
//     setState(() {});
//   }

  @override
  void initState() {
    speechToTextInitialization();
    getRandomPosition();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startMessage();
    });
    super.initState();
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = Responsive.screenHeight(context);
    double width = Responsive.screenWidth(context);
    screenHeight = height;
    screenWidth = width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: height * 0.1,
            width: width * 1,
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: (){
                    Get.to(const HomePage());
                  },
                  child: Text("Back",
                  style: TextStyle(
                    fontSize: (width / Responsive.designWidth) * 30,
                    color: const Color.fromARGB(166, 207, 207, 11),
                    ),
                  )
                  ),
                InkWell(
                onTap: (){
                  GameStartMessage.startMessage(context,"Color Game","Read the loudly");
                },
                  child: Container(
                  height: height * 0.05,
                  width: width * 0.1,
                  margin: EdgeInsets.only(bottom: height * 0.005),
                  color: Colors.transparent,
                  child: const FittedBox(
                    child: Icon(CupertinoIcons.info,color: Color.fromARGB(166, 207, 207, 11),),
                  ),
                  ),
                ),
                TextButton(
                  onPressed: (){
                    stopSpeechRecord();
                    // _stopRecording();
                    //  if(_filePath != null && _filePath!.isNotEmpty){
                    //   ColorGameServices.sendAudioToDatabase(_filePath!);
                    // }
                    Get.to(const HomePage());
                  },
                  child: Text("Submit",
                  style: TextStyle(
                      fontSize: (width/Responsive.designWidth) * 30,
                      color: const Color.fromARGB(166, 207, 207, 11),
                      ),
                  )
                ),
              ],
            ),
          ),
          //Text(voiceToText),
          (currentIndex!=-1)? Padding(
            padding: EdgeInsets.only(left: (width * positionX),top: height * positionY),
            child: Text(colorMap.keys.elementAt(currentIndex),
              style: TextStyle(
                color: colorMap.values.elementAt(currentIndex),
                fontSize: (width/Responsive.designWidth) * 50,
              ),
            ),
          ): const Text(""),
        ],
      )
    );
  }
}