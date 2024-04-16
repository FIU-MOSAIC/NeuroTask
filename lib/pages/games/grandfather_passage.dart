import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_task/constant/my_text.dart';
import 'package:neuro_task/ui/game/grandfather_recording.dart';

class GrandFatherPassage extends StatefulWidget {
  const GrandFatherPassage({super.key});

  @override
  State<GrandFatherPassage> createState() => _GrandFatherPassageState();
}

class _GrandFatherPassageState extends State<GrandFatherPassage> {

  bool isStart = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: double.maxFinite.h,
          width: double.maxFinite.w,
          color: const  Color.fromARGB(255, 43, 43, 43),
          child: (isStart) ? const GrandFatherRecording()
           : Center(
            child: Container(
              height: 1000.h,
              width: 700.w,
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyText(text: "Instruction", size: 80.sp, overflow: false, bold: true, color: Colors.white),
                      Icon(
                        CupertinoIcons.speaker_2_fill,
                        size: 100.sp,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 100.h),
                  MyText(text: "Read the passage loudly", size: 60.sp, overflow: false, bold: false, color: Colors.white),
                  SizedBox(height: 100.h),
                  ElevatedButton(
                    onPressed: (){
                      isStart = true;
                      setState(() {});
                    },
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.pink),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.h,horizontal: 70.w),
                      child: MyText(text: "Begin Test", size: 50.sp, overflow: false, bold: true, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),  
      )
    );
  }
}