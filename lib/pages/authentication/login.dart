import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:neuro_task/constant/my_icon.dart';
import 'package:neuro_task/constant/my_text.dart';
import 'package:neuro_task/pages/authentication/sign_up.dart';
import 'package:neuro_task/services/login_service.dart';
import 'package:neuro_task/ui/text_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          height: double.maxFinite.h,
          width: double.maxFinite.w,
          decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage("assets/images/login_image.jpg"),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height:700.h),
              MyText(text: "Welcome To Neuro Task", size: 80.sp, overflow: false, bold: true, color: Colors.white),
              SizedBox(height:300.h),
              MyTextField(width: 800, text: "Email", icon: Icons.mail, controller: email, check: false),
              SizedBox(height:50.h),
              MyTextField(width: 800, text: "Password", icon: Icons.key, controller: password, check: true),
              SizedBox(height:80.h),
              ElevatedButton(
                onPressed: (){
                  LoginService().login(email.text, password.text);
                }, 
                style:ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.sp)),
                   ),
                  ),
                  backgroundColor: const MaterialStatePropertyAll(Colors.lightBlue),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 280.w,vertical: 40.h),
                  child: MyText(text: "Login", size: 60.sp, overflow: false, bold: false, color: Colors.white)),
              ),
              SizedBox(height:20.h),
              TextButton(
                onPressed: (){
                  Get.to(const SignUp());
                }, 
                child: MyText(text: "Don't have any account? Signup", size: 55.sp, overflow: false, bold: false, color: Colors.deepPurple),
              ),
              SizedBox(height:70.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyIcon(icon: Icons.local_hospital, color: Colors.lightBlue, size: 90.sp),
                  MyIcon(icon: Icons.medical_information, color: Colors.lightBlue, size: 90.sp),
                  MyIcon(icon: Icons.mobile_screen_share, color: Colors.lightBlue, size: 90.sp),
                ],
              ),
              SizedBox(height:40.h),
              MyText(text: " Neuro Task - 2023  © copyright Mosaic Lab", size: 40.sp, overflow: false, bold: false, color: Colors.black),
              SizedBox(height:20.h),
            ],
          ),
        ),
      )
    );
  }
}