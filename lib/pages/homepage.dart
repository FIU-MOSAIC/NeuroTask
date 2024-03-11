//import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neuro_task/constant/responsive.dart';
//import 'package:neuro_task/constant/ip.dart';
import 'package:neuro_task/pages/authentication/login.dart';
import 'package:neuro_task/pages/games/color_game.dart';
import 'package:neuro_task/pages/games/grandfather_passage.dart';
import 'package:neuro_task/pages/games/memory_game.dart';
//import 'package:http/http.dart' as http;
import 'package:neuro_task/pages/games/narration.dart';
import 'package:neuro_task/pages/games/picture_test.dart';
import 'package:neuro_task/pages/games/target_game.dart';
import 'package:neuro_task/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: prefer_typing_uninitialized_variables
var patientId;
// ignore: prefer_typing_uninitialized_variables
var email;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  

  // var ip = IP.ip;
  // Future getPatientId() async{
  //   var url ='http://$ip/Neuro_Task/patient_id.php';
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   email = sharedPreferences.getString('email');
  //   // ignore: unused_local_variable
  //   var response = await http.post(Uri.parse(url),body: {
  //     'email' : email.toString(),
  //   });
  //   var jsonString = response.body.substring(response.body.indexOf('['));
  //   var data = json.decode(jsonString);
  //   setState(() {
      
  //   });
  //   return data;
  // }
  // ignore: prefer_typing_uninitialized_variables
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  @override
  Widget build(BuildContext context) {
    double height = Responsive.screenHeight(context);
    double width = Responsive.screenWidth(context);
    screenHeight = height;
    screenWidth= width;
    return SafeArea(
      child: Scaffold(
        body: Container(
            height: height * 1,
            width: width * 1,
            color: Colors.white,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection(patientemail).snapshots(), 
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }
                else if(snapshot.hasData){
                  List<dynamic> patientList = snapshot.data!.docs.map((e) => e.data()).toList();
                  return ListView.builder(
                    itemCount: patientList.length,
                    itemBuilder: (context, index) {
                    Map<dynamic,dynamic> patientMap = patientList[index] as Map<dynamic,dynamic>;
                    patientId = patientMap['Patient Id'];
                      return Container(
                        height: height * 1,
                        width: width * 1,
                        color: Colors.transparent,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(patientemail),
                               GestureDetector(
                                onTap: (){
                                  Get.to(const GrandFatherPassage());
                                },
                                child: customCard("Grandfather Passage","Read the passage with voice","assets/images/grandfather.jpg"),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Get.to(const MemoryGame());
                                },
                                child: customCard("Memory Test","Flip the card to find all matching pairs of images","assets/images/card.png"),
                              ),
                              // GestureDetector(
                              //   onTap: (){
                              //     //Get.to(const TraceShape());
                              //   },
                              //   child: customCard("Trace Shape","Draw the shape with hand","assets/images/trace-shape.png"),
                              // ),
                              GestureDetector(
                                onTap: (){
                                  Get.to(const Narration());
                                },
                                child: customCard("Narration Reading","Read The Single Line Loudly","assets/images/narration.png"),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Get.to(const TargetGame());
                                },
                                child: customCard("Target Game","Press on the target","assets/images/target.png"),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Get.to(const ColorGame());
                                },
                                child: customCard("Color Test","Read the color","assets/images/color_game.jpg"),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Get.to(const PictureTest());
                                },
                                child: customCard("Picture Test","Say the word that best corresponds to the picture shown.","assets/images/umbrella.png"),
                              ),
                              TextButton(
                                onPressed: () async{
                                  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                  sharedPreferences.remove('email');
                                  Get.to(const Login());
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        )
                      );
                    },
                  );
                }
                else{
                  return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

   customCard(String str,String str2,String path){
    return  Padding(
      padding: EdgeInsets.only(left:((screenWidth/Responsive.designWidth) * 10),right: ((screenWidth/Responsive.designWidth) * 10)),
      child: Card(
        color: Colors.white,
        child: ListTile(
          leading: Container(
            height: screenHeight * 0.2,
            width: screenWidth * 0.15,
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage(path),
                fit: BoxFit.contain,
              ),
            ),
          ),
          title: Text(str),
          subtitle: Text(str2),
        ),
      ),
    );
  }
}