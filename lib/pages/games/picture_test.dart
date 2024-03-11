import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neuro_task/constant/responsive.dart';
import 'package:neuro_task/pages/homepage.dart';
import 'package:neuro_task/ui/message/start_message.dart';

class PictureTest extends StatefulWidget {
  const PictureTest({super.key});

  @override
  State<PictureTest> createState() => _PictureTestState();
}

class _PictureTestState extends State<PictureTest> {

  showMyDialog(){
    return showGeneralDialog(
      transitionDuration: const Duration(milliseconds: 500),
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).dialogLabel,
      context: context, 
      pageBuilder: (context, animation, secondaryAnimation) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.55,
              color: Colors.white,
              child: Card(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text("Picture Test",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (width/Responsive.designWidth) * 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.02),
                      child: Text("Instruction",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: (width/Responsive.designWidth) * 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.02,vertical: height * 0.02),
                      child: Text("Say aloud the single word that best corresponds to the picture shown. Tap continue to start and submit when you are done.",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: (width/Responsive.designWidth) * 30,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    TextButton(
                      onPressed: (){
                        startTimer();
                        Navigator.pop(context);
                      }, 
                      child: Text("Continue",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (width/Responsive.designWidth) * 40,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(166, 207, 207, 11),
                      ),
                    ),
                    ),
                    // SizedBox(height: height * 0.01),
                    // InkWell(
                    //   onTap:(){
                        
                    //   },
                    //   child: Icon(Icons.keyboard_arrow_up,
                    //     size: (width/Responsive.designWidth) * 50,
                    //   ),
                    // ),
                  ],
                ),
              )
            ),
          ],
        );
      },
    );
  }

  List<String> pictureList = [
    "assets/images/banana.jpg",
    "assets/images/piano.jpg",
    "assets/images/giraffe.jpg",
    "assets/images/flamingo.jpg",
    "assets/images/strawbery.jpg",
    "assets/images/tricycle.jpg",
    "assets/images/umbrella2.jpg",
    "assets/images/diamond.jpg",
    "assets/images/tomato.png",
    "assets/images/elephant.jpg",
    "assets/images/pinaple.png",
    "assets/images/calculator.jpg",
    "assets/images/cangaroo.jpg",
  ];

  int secondCount = 0;
  int index = 0;
  int currentIndex = 0;
  int intervalTime = 3;
  DateTime? deviceTime;
  DateTime? disapearTime;
  double screenHeight = 0.0,screenWidth = 0.0;
  int second = 51;

  void startTimer(){
    Timer.periodic(const Duration(seconds: 1), (timer) { 
      secondCount++;
      setState(() {
        second--;
      });

      if(secondCount % intervalTime == 0){
        disapearTime = DateTime.now();
        currentIndex = -1;
        if(index < pictureList.length){
          index++;
          //stopSpeechRecord();
          //ColorGameServices.colorGameDataToFirebase(deviceTime!,disapearTime!,(positionX*screenWidth),(positionY*screenHeight),colorMap.keys.elementAt(index-1),textColors[index-1],voiceToText,intervalTime);
        }
        else{
          timer.cancel();
        }
        setState(() {});
        Future.delayed(const Duration(seconds: 1),(){
          //voiceToText = "Skipped";
          secondCount--;

          if(index<pictureList.length){
            currentIndex = index;
            getRandomPosition();
            //startListening();
            deviceTime = DateTime.now();
            setState(() {});
          }
        });
      }
    });
  }

  double positionX = 0.0;
  double positionY= 0.0;
  Random random = Random();
  void getRandomPosition(){
    positionX = (0 + random.nextDouble() * (0.6 - 0));
    positionY = (0.1 + random.nextDouble() * (0.6 - 0.1));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showMyDialog();
    });
    getRandomPosition();
  }

  double height = 0.0, width = 0.0;

  @override
  Widget build(BuildContext context) {
    height = Responsive.screenHeight(context);
    width = Responsive.screenWidth(context);
    return Scaffold(
      body: Container(
        height: height * 1,
        width: width * 1,
        color: Colors.white,
        child: Column(
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
                  const StartMessage(gameName: 'Picture Test',
                  description: "Say aloud the single word that best corresponds to the picture shown. Tap continue to start and submit when you are done."),
                  TextButton(
                    onPressed: (){
                      //timer!.cancel();
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
            Center(
              child: (second>=0) ? Text(second.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (width/Responsive.designWidth) * 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ) : Text("0",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (width/Responsive.designWidth) * 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
            ),
            (second>=0 && (currentIndex!=-1)) ? Container(
              height: height * 0.2,
              width: width * 0.4,
              margin: EdgeInsets.only(left: (width * positionX),top: height * positionY),
              decoration: BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: AssetImage(pictureList[currentIndex]),
                  fit: BoxFit.contain,
                ),
              ),
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}