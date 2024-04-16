import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:neuro_task/constant/my_text.dart';
import 'package:neuro_task/pages/authentication/login.dart';
import 'package:neuro_task/pages/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: prefer_typing_uninitialized_variables
var email;
class SpalshScreen extends StatefulWidget {
  const SpalshScreen({super.key});

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {

   @override
  void initState() {
    getValidation().whenComplete((){
      Timer(const Duration(seconds: 2), () { 
        (email == null) ? Get.to(const Login()) : Get.to(const HomePage());
      });
    });
    super.initState();
  }

  Future getValidation() async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var getEmail = sharedPreferences.getString('email');
    email = getEmail;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: double.maxFinite.h,
          width: double.maxFinite.w,
          color: Colors.blue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(text: "Neuro Task", size: 80.sp, overflow: false, bold: true, color: Colors.white),
              SizedBox(height: 50.h),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      )
    );
  }
}