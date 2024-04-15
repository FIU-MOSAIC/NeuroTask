import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:neuro_task/constant/ip.dart';
import 'package:neuro_task/pages/games/grandfather_passage.dart';
import 'package:neuro_task/pages/games/memory_game.dart';
import 'package:http/http.dart' as http;
import 'package:neuro_task/pages/games/narration.dart';
import 'package:neuro_task/pages/games/trace_shape.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'games/MotorFunctionShape.dart';

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
  

  var ip = IP.ip;
  Future getPatientId() async{
    var url ='http://$ip/Neuro_Task/patient_id.php';
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    email = sharedPreferences.getString('email');
    // ignore: unused_local_variable
    var response = await http.post(Uri.parse(url),body: {
      'email' : email.toString(),
    });
    var jsonString = response.body.substring(response.body.indexOf('['));
    var data = json.decode(jsonString);
    setState(() {
      
    });
    return data;
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
            height: double.maxFinite.h,
            width: double.maxFinite.w,
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder(
                    future: getPatientId(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        return Container(
                          height: 0.h,
                          width: double.maxFinite.w,
                          color: Colors.white,
                          child: ListView.builder(
                            itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                var mydata = snapshot.data[index];
                                patientId = mydata['p_id'];
                                return Text(mydata['p_id']);
                              },
                          ),
                        );
                      }
                      else{
                        return Container(
                          height: 100.h,
                          width: double.maxFinite.w,
                          color: Colors.white,
                          child: const Center(child: Text("Server Loading ❗")));
                      }
                    },
                  ),
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
                    child: customCard("Memory Test","Flip the card to find all matching pairs of images","assets/images/card.jpg"),
                  ),
                  GestureDetector(
                    onTap: (){
                      Get.to(const TraceShape());
                    },
                    child: customCard("Trace Shape","Draw the shape with hand","assets/images/trace-shape.png"),
                  ),
                  GestureDetector(
                    onTap: (){
                      Get.to(const Narration());
                    },
                    child: customCard("Narration Reading","Read The Single Line Loudly","assets/images/narration.png"),
                  ),
                  //Added by JB for Motor Function game - March 30, 2024
                  GestureDetector(
                    onTap: (){
                      Get.to(const MotorFunctionShape());
                    },
                    child: customCard("Motor Function","Draw the shape with hand motion", "assets/images/trace-shape.png"),
                  )


                ],
              ),
            ),
        ),
      ),
    );
  }

   customCard(String str,String str2,String path){
    return  Padding(
      padding: EdgeInsets.only(left:ScreenUtil().setSp(10),right: ScreenUtil().setSp(10),top:ScreenUtil().setSp(2)),
      child: Card(
        color: Colors.white,
        child: ListTile(
          leading: Container(
            height: 200.h,
            width: 150.w,
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage(path),
                fit: BoxFit.contain,
              ),
            ),
          ),
          title: Text(str),
          subtitle: Text(str2)
        ),
      ),
    );
  }
}