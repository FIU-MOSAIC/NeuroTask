import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:neuro_task/providers/memory_game_functions.dart';
import 'package:neuro_task/pages/homepage.dart';
import 'package:flip_card/flip_card.dart';
import 'package:neuro_task/services/memory_game_service.dart';
import 'package:neuro_task/ui/game/memory_game_start_message.dart';
import 'package:path_provider/path_provider.dart';


class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {

  String front = "assets/images/flower.png";
  //Yellow Circle
  GlobalKey<FlipCardState> element1Card = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> element2Card = GlobalKey<FlipCardState>();
  //Two Rectangle
  GlobalKey<FlipCardState> element3Card = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> element4Card = GlobalKey<FlipCardState>();
  //Triangle
  GlobalKey<FlipCardState> element5Card = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> element6Card = GlobalKey<FlipCardState>();
  //Polygon
  GlobalKey<FlipCardState> element7Card = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> element8Card = GlobalKey<FlipCardState>();
  //Rectangle
  GlobalKey<FlipCardState> element9Card = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> element10Card = GlobalKey<FlipCardState>();
  //Circle Blue
  GlobalKey<FlipCardState> element11Card = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> element12Card = GlobalKey<FlipCardState>();

  int cardCount=0;
  List<int> cardValue = [];
  List<GlobalKey<FlipCardState>> cards = [];
  List<bool> item = [false,false,false,false,false,false,false,false,false,false,false,false];
  int success = 0;
  
  late CameraController _cameraController;
  bool _isLoading = true;
  bool _isRecording = false;

  _initCamera() async {
  final cameras = await availableCameras();
  final front = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
  _cameraController = CameraController(front, ResolutionPreset.max);
  await _cameraController.initialize();
  setState(() => _isLoading = false);
  _startRecord();
 }

 _stopRecord() async {
  if (_isRecording) {
    final file = await _cameraController.stopVideoRecording();
    setState(() => _isRecording = false);

    final downloadDirectory = await getExternalStorageDirectory();
    if (downloadDirectory == null) {
      return;
    }
    final downloadFolder = Directory('${downloadDirectory.path}/video');
    if (!await downloadFolder.exists()) {
      await downloadFolder.create(recursive: true);
    }

    // Generate a unique filename for the video
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = 'video_$currentTime.mp4';

    // Create the destination path in the "Download" folder
    final String destinationPath = '${downloadFolder.path}/$fileName';

    // Copy the video file to the "Download" folder
    final videoFile = File(file.path);
    await videoFile.copy(destinationPath);
    // ignore: avoid_print
    print(destinationPath);
    
    //Get.to(VideoPage(filePath: file.path));
  } 
}

_startRecord() async{
    await _cameraController.prepareForVideoRecording();
    await _cameraController.startVideoRecording();
    setState(() => _isRecording = true);
    // ignore: avoid_print
    print('starting..');
}
  
  
  @override
  void initState() {
    _initCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MemoryGameStartMessage.startMessage(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap:(){
            MemoryGameFunctions.findTime();
            MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success, MemoryGameFunctions.screenPosition, 0, 0);
          },
          onTapDown: (TapDownDetails details){
            MemoryGameFunctions.screenPositionValue(details, context);
          },
          child: Container(
            height: double.maxFinite.h,
            width: double.maxFinite.w,
            color: Colors.white,
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: (){
                          Get.to(const HomePage());
                       },
                       child: const Text("Back",
                       style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(166, 207, 207, 11),
                         ),
                       )
                       ),
                       Container(
                      height: 100.h,
                      width: 200.w,
                      color: Colors.white,
                      child: (_isLoading) ? const Center(
                        child: CircularProgressIndicator(),
                      ) : CameraPreview(
                        _cameraController,
                      ),
                     ),
                     Container(
                      height: 80.h,
                      width: 80.w,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle
                      ),
                      child: Center(
                        child: (_isRecording)?const Icon(Icons.stop,color: Colors.white,) : const Icon(Icons.fiber_manual_record,color: Colors.white),
                      ),
                     ),
                       TextButton(
                        onPressed: (){
                          _stopRecord();
                          Get.to(const HomePage());
                       },
                       child: const Text("Submit",
                       style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(166, 207, 207, 11),
                            ),
                       )
                       ),
                    ],
                  ),
                //Flip Card
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTapUp: (TapUpDetails details) {
                           MemoryGameFunctions.cardPositionValue(details);
                           MemoryGameFunctions.findTime();
                          },
                          onTap: (){ 
                            if(element3Card.currentState!.isFront == true && cardCount!=2 && item[0]==false){
                              cardCount++;
                              element3Card.currentState!.toggleCard();
                              cardValue.add(1);
                              cards.add(element3Card);
                              item[0]=true;
                              if(cardCount==2){
                                successCard();
                              }
                              MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success,MemoryGameFunctions.screenPosition, 1, MemoryGameFunctions.cardPosition);
                            }
                          },
                          child: FlipCard( 
                            key: element3Card,
                            flipOnTouch: false,
                            onFlip: (){
                              
                            },
                            front: customCard(front), 
                            back: customCard('assets/images/TwoRectangle.png'),
                          ),
                        ),
                      GestureDetector(
                        onTapUp: (TapUpDetails details) {
                            MemoryGameFunctions.cardPositionValue(details);
                            MemoryGameFunctions.findTime();
                          },
                          onTap: (){
                            if(element1Card.currentState!.isFront == true && cardCount!=2 && item[1]==false){
                              cardCount++;
                              element1Card.currentState!.toggleCard();
                              cardValue.add(2);
                              cards.add(element1Card);
                              item[1]=true;
                              if(cardCount==2){
                              successCard();
                              }
                              MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success, MemoryGameFunctions.screenPosition, 2, MemoryGameFunctions.cardPosition);
                            }
                          },
                        child: FlipCard(
                          key: element1Card,
                          flipOnTouch: false,
                          onFlip: (){
                            
                          },
                          front: customCard(front), 
                          back: customCard('assets/images/CircleYellow.png'),
                        ),
                      ),
                      GestureDetector(
                        onTapUp: (TapUpDetails details) {
                            MemoryGameFunctions.cardPositionValue(details);
                            MemoryGameFunctions.findTime();
                          },
                          onTap: (){
                            
                            if(element2Card.currentState!.isFront == true && cardCount!=2 && item[2]==false){
                              cardCount++;
                              element2Card.currentState!.toggleCard();
                              cardValue.add(102);
                              cards.add(element2Card);
                              item[2]=true;
                              if(cardCount==2){
                               successCard();
                              }
                              MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success, MemoryGameFunctions.screenPosition, 3, MemoryGameFunctions.cardPosition); 
                            }
                          },
                        child: FlipCard(
                          key: element2Card,
                          flipOnTouch: false,
                          onFlip: (){
                            
                          },
                          front: customCard(front), 
                          back: customCard('assets/images/CircleYellow.png'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTapUp: (TapUpDetails details) {
                            MemoryGameFunctions.cardPositionValue(details);
                            MemoryGameFunctions.findTime();
                          },
                          onTap: (){
                            if(element5Card.currentState!.isFront == true && cardCount!=2 && item[3]==false){
                              cardCount++;
                              element5Card.currentState!.toggleCard();
                              cardValue.add(3);
                              cards.add(element5Card);
                              item[3]=true;
                              if(cardCount==2){
                              successCard();
                              }
                              MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success, MemoryGameFunctions.screenPosition, 4, MemoryGameFunctions.cardPosition);
                            }
                          },
                        child: FlipCard(
                          key: element5Card,
                          flipOnTouch: false,
                          onFlip: (){
                            
                          },
                          front: customCard(front), 
                          back: customCard('assets/images/Triangle.png'),
                        ),
                      ),
                      GestureDetector(
                        onTapUp: (TapUpDetails details) {
                            MemoryGameFunctions.cardPositionValue(details);
                            MemoryGameFunctions.findTime();
                          },
                          onTap: (){
                            if(element7Card.currentState!.isFront == true && cardCount!=2 && item[4]==false){
                              cardCount++;
                              element7Card.currentState!.toggleCard();
                              cardValue.add(4);
                              cards.add(element7Card);
                              item[4]=true;
                              if(cardCount==2){
                              successCard();
                              }
                              MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success, MemoryGameFunctions.screenPosition, 5, MemoryGameFunctions.cardPosition);
                            }
                          },
                        child: FlipCard(
                          key: element7Card,
                          flipOnTouch: false,
                          onFlip: (){
                            
                          },
                          front: customCard(front), 
                          back: customCard('assets/images/Polygon.png'),
                        ),
                      ),
                      GestureDetector(
                        onTapUp: (TapUpDetails details) {
                            MemoryGameFunctions.cardPositionValue(details);
                            MemoryGameFunctions.findTime();
                          },
                          onTap: (){
                            if(element9Card.currentState!.isFront == true && cardCount!=2 && item[5]==false){
                              cardCount++;
                              element9Card.currentState!.toggleCard();
                              cardValue.add(5);
                              cards.add(element9Card);
                              item[5]=true;
                              if(cardCount==2){
                              successCard();
                              }
                              MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success, MemoryGameFunctions.screenPosition, 6, MemoryGameFunctions.cardPosition);
                            }
                          },
                        child: FlipCard(
                          key: element9Card,
                          flipOnTouch: false,
                          onFlip: (){
                            
                          },
                          front: customCard(front), 
                          back: customCard('assets/images/Rectangle.png'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTapUp: (TapUpDetails details) {
                            MemoryGameFunctions.cardPositionValue(details);
                            MemoryGameFunctions.findTime();
                          },
                          onTap: (){
                            if(element4Card.currentState!.isFront == true && cardCount!=2 && item[6]==false){
                              cardCount++;
                              element4Card.currentState!.toggleCard();
                              cardValue.add(101);
                              cards.add(element4Card);
                              item[6]=true;
                              if(cardCount==2){
                              successCard();
                             }
                             MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success, MemoryGameFunctions.screenPosition, 7, MemoryGameFunctions.cardPosition);
                            }
                          },
                        child: FlipCard(
                          key: element4Card,
                          flipOnTouch: false,
                          onFlip: (){
                            
                          },
                          front: customCard(front), 
                          back: customCard('assets/images/TwoRectangle.png'),
                        ),
                      ),
                      GestureDetector(
                        onTapUp: (TapUpDetails details) {
                            MemoryGameFunctions.cardPositionValue(details);
                            MemoryGameFunctions.findTime();
                          },
                          onTap: (){
                            if(element6Card.currentState!.isFront == true && cardCount!=2 && item[7]==false){
                              cardCount++;
                              element6Card.currentState!.toggleCard();
                              cardValue.add(103);
                              cards.add(element6Card);
                              item[7]=true;
                              if(cardCount==2){
                              successCard();
                              }
                              MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success, MemoryGameFunctions.screenPosition, 8, MemoryGameFunctions.cardPosition);
                            }
                          },
                        child: FlipCard(
                          key: element6Card,
                          flipOnTouch: false,
                          onFlip: (){
                            
                          },
                          front: customCard(front), 
                          back: customCard('assets/images/Triangle.png'),
                        ),
                      ),
                      GestureDetector(
                        onTapUp: (TapUpDetails details) {
                          MemoryGameFunctions.cardPositionValue(details);
                          MemoryGameFunctions.findTime();
                        },
                        onTap: (){
                          if(element11Card.currentState!.isFront == true && cardCount!=2 && item[8]==false){
                              cardCount++;
                              element11Card.currentState!.toggleCard();
                              cardValue.add(6);
                              cards.add(element11Card);
                              item[8]=true;
                              if(cardCount==2){
                              successCard();
                              }
                              MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success, MemoryGameFunctions.screenPosition, 9, MemoryGameFunctions.cardPosition);
                            }  
                        },
                        child: FlipCard(
                          key: element11Card,
                          flipOnTouch: false,
                          onFlip: (){
                           
                          },
                          front: customCard(front), 
                          back: customCard('assets/images/CircleBlue.png'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTapUp: (TapUpDetails details) {
                            MemoryGameFunctions.cardPositionValue(details);
                            MemoryGameFunctions.findTime();
                          },
                          onTap: (){
                           if(element10Card.currentState!.isFront == true && cardCount!=2 && item[9]==false){
                              cardCount++;
                              element10Card.currentState!.toggleCard();
                              cardValue.add(105);
                              cards.add(element10Card);
                              item[9]=true;
                              if(cardCount==2){
                              successCard();
                              }
                              MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success, MemoryGameFunctions.screenPosition, 10, MemoryGameFunctions.cardPosition);
                            }
                          },
                        child: FlipCard(
                          key: element10Card,
                          flipOnTouch: false,
                          onFlip: (){
                            
                          },
                          front: customCard(front), 
                          back: customCard('assets/images/Rectangle.png'),
                        ),
                      ),
                      GestureDetector(
                        onTapUp: (TapUpDetails details) {
                            MemoryGameFunctions.cardPositionValue(details);
                            MemoryGameFunctions.findTime();
                          },
                          onTap: (){
                           if(element12Card.currentState!.isFront == true && cardCount!=2 && item[10]==false){
                              cardCount++;
                              element12Card.currentState!.toggleCard();
                              cardValue.add(106);
                              cards.add(element12Card);
                              item[10]=true;
                              if(cardCount==2){
                              successCard();
                              }
                              MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success, MemoryGameFunctions.screenPosition, 11, MemoryGameFunctions.cardPosition);
                            }
                          },
                        child: FlipCard(
                          key: element12Card,
                          flipOnTouch: false,
                          onFlip: (){
                           
                          },
                          front: customCard(front), 
                          back: customCard('assets/images/CircleBlue.png'),
                        ),
                      ),
                      GestureDetector(
                        onTapUp: (TapUpDetails details) {
                            MemoryGameFunctions.cardPositionValue(details);
                            MemoryGameFunctions.findTime();
                          },
                          onTap: (){
                            if(element8Card.currentState!.isFront == true && cardCount!=2 && item[11]==false){
                              cardCount++;
                              element8Card.currentState!.toggleCard();
                              cardValue.add(104);
                              cards.add(element8Card);
                              item[11]=true;
                              if(cardCount==2){
                              successCard();
                              }
                              MemoryGameService.memoyGameData('1001',patientId, MemoryGameFunctions.formattedTime, success, MemoryGameFunctions.screenPosition, 12, MemoryGameFunctions.cardPosition);
                            }
                          },
                        child: FlipCard(
                          key: element8Card,
                          flipOnTouch: false,
                          onFlip: (){
                            
                          },
                          front: customCard(front), 
                          back: customCard('assets/images/Polygon.png'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      )
    );
  }

  void successCard(){
    if((cardValue[0]-cardValue[1]).abs()!=100){
      try{
        Timer(const Duration(seconds: 1), () { 
        cards[0].currentState!.toggleCard();
        cards[1].currentState!.toggleCard();
        cards.clear();
        cardValue.clear();
        cardCount=0;
        for(int i=0;i<12;i++){
          item[i]=false;
        }
      });
      }
      catch(e){
        // ignore: avoid_print
        print(e);
      }
    }
    else{
      try{
        success++;
        setState(() {
          
        });
        cards.clear();
        cardValue.clear();
        cardCount=0;
      }
      catch(e){
        // ignore: avoid_print
        print(e);
      }
    }
  }
   Widget customCard(String path){
    return Container(
        margin: EdgeInsets.only(top:40.h),
        height: 450.h,
        width: 300.w,  
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(30.sp)),
          border: Border.all(
            width: 5.sp,
          )
        ),
        child: Image(
          height: 350.h,
          width: 350.w,
          image: AssetImage(path)
        ),
    );
  }
}