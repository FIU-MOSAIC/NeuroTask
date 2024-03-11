import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neuro_task/constant/my_text.dart';
import 'package:neuro_task/constant/responsive.dart';
import 'package:neuro_task/pages/authentication/login.dart';
import 'package:neuro_task/pages/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: prefer_typing_uninitialized_variables
var patientemail;
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

   @override
  void initState() {
    getValidation().whenComplete((){
      Timer(const Duration(seconds: 2), () { 
        (patientemail == null) ? Get.to(const Login()) : Get.to(const HomePage());
      });
    });
    super.initState();
  }

  Future getValidation() async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var getEmail = sharedPreferences.getString('email');
    patientemail = getEmail;
  }

  @override
  Widget build(BuildContext context) {
    double height = Responsive.screenHeight(context);
    double width = Responsive.screenWidth(context);
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: height * 1,
          width: width * 1,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splash_screen.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: height* 0.6),
              const MyText(text: "Neuro Task", size: 20,height: 0.05,width: 1, bold: true, color: Colors.white),
              SizedBox(height: height * 0.02),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      )
    );
  }
}