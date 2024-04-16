import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:neuro_task/constant/my_text.dart';
import 'package:neuro_task/constant/passage.dart';
import 'package:neuro_task/pages/homepage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:noise_meter/noise_meter.dart';


class GrandFatherRecording extends StatefulWidget {
  const GrandFatherRecording({super.key});

  @override
  State<GrandFatherRecording> createState() => _GrandFatherRecordingState();
}

class _GrandFatherRecordingState extends State<GrandFatherRecording> {

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _noiseMeter = NoiseMeter(onError);
    _initialize();
  }
  
  //Noise Level
  bool _isRecording = false;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;

  void onData(NoiseReading noiseReading) {
    setState(() {
      _latestReading = noiseReading;
      if (!_isRecording) _isRecording = true;
    });
  }

  void onError(Object error) {
    // ignore: avoid_print
    print(error);
    _isRecording = false;
  }

  void startNoise() {
    try {
      _noiseSubscription = _noiseMeter?.noise.listen(onData);
    } catch (err) {
      // ignore: avoid_print
      print(err);
    }
  }

  void stopNoise() {
    try {
      _noiseSubscription?.cancel();
      setState(() {
        _isRecording = false;
      });
    } catch (err) {
      // ignore: avoid_print
      print(err);
    }
  }

  Widget voiceIcon(){
    if(!_isRecording){
      return Icon(
        CupertinoIcons.waveform,
        size: 150.sp,
        color: Colors.white,
      );
    }
    else if(_latestReading!.maxDecibel>= 56 && _latestReading!.maxDecibel>= 70){
      return Icon(
        CupertinoIcons.speaker_1_fill,
        size: 150.sp,
        color: Colors.green,
      );
    }
    else if(_latestReading!.maxDecibel> 70 && _latestReading!.maxDecibel>= 89){
      return Icon(
        CupertinoIcons.speaker_2_fill,
        size: 150.sp,
        color: Colors.green,
      );
    }
    else if(_latestReading!.maxDecibel>= 90){
      return Icon(
        CupertinoIcons.volume_up,
        size: 150.sp,
        color: Colors.green,
      );
    }
    else{
      return Icon(
        CupertinoIcons.volume_off,
        size: 150.sp,
        color: Colors.red,
      );
    }
  }

  //Timer
  bool recordState = false;
  bool recorded = false;
  int second = 0;
  Timer? timer;

  Future<void> startTimer() async{
    timer = Timer.periodic(const Duration(seconds: 1), (timer) { 
      second++;
      setState(() {
        
      });
    });
  }

  void stop(){
    timer!.cancel();
  }

  //Audio record
  FlutterSoundRecorder? _recorder;
  String? _filePath;
  bool _isPlaying = false;

  Future<void> _initialize() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await _recorder!.openRecorder();
  }

  Future<void> _startRecording() async {
    final externalDir = await getExternalStorageDirectory();
    _filePath = '${externalDir!.path}/recording.aac';

    await _recorder!.startRecorder(toFile: _filePath);
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    // ignore: avoid_print
    print('Recording saved to: $_filePath');
    setState(() {});
  }

//Audio Player
AudioPlayer audioPlayer = AudioPlayer();
Future<void> _playRecordedAudio() async {
    if (_filePath != null && _filePath!.isNotEmpty) {
      await audioPlayer.setFilePath(_filePath!);
      await audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
      audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } else {
      // ignore: avoid_print
      print('File path is null or empty.');
    }
  }

  void _stopPlaying() async {
  if (audioPlayer.playing) {
    await audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }
}
  void _releaseAudioPlayer() {
     audioPlayer.dispose();
  }


  @override
  void dispose() {
    audioPlayer.dispose();
    _recorder!.closeRecorder();
    _releaseAudioPlayer();
    startTimer();
    _noiseSubscription?.cancel();
    super.dispose();
  }

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite.h,
      width: double.maxFinite.w,
      color: Colors.transparent,
      child: SingleChildScrollView(
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
                TextButton(
                  onPressed: (){
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
            SizedBox(height: 50.h),
            MyText(text: "Grandfather Passage", size: 80.sp, overflow: false, bold: true, color: Colors.white),
            SizedBox(height: 50.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 150.sp,
                      color: Colors.white,
                    ),
                    SizedBox(height: 50.h),
                    MyText(text: "Info", size: 70.sp, overflow: false, bold: true, color: Colors.white),
                  ],
                ),
                Column(
                  children: [
                    voiceIcon(),
                    SizedBox(height: 50.h),
                    MyText(text: 'Voice Level', size: 70.sp, overflow: true, bold: true, color: Colors.white),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 150.sp,
                      color: Colors.white,
                    ),
                    SizedBox(height: 50.h),
                    MyText(text: second.toString(), size: 70.sp, overflow: false, bold: true, color: Colors.white),
                  ],
                ),
              ],
            ),
            (recordState) ? Container(
              height: 1550.h,
              width: double.maxFinite.w,
              color: Colors.transparent,
              child: Column(
                children: [
                  SizedBox(height: 100.h),
                  Container(
                    height: 1000.h,
                    width: double.maxFinite.w,
                    color: Colors.transparent,
                    margin: EdgeInsets.symmetric(horizontal: 30.w),
                    child: MyText(text: Passage.myText, size: 60.sp, overflow: false, bold: false, color: Colors.white),
                  ),
                  SizedBox(height: 80.h),
                  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        _stopRecording();
                        recordState = false;
                        recorded = true;
                        second = 0;
                        stop();
                        stopNoise();
                      });
                      setState(() {
                        
                      });
                    },
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.pink),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.h,horizontal: 100.w),
                      child: MyText(text: "Stop recording", size: 50.sp, overflow: false, bold: true, color: Colors.white)
                    ),
                  ),
                ],
              ),
            )
            : Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  SizedBox(height: 200.h),
                  (recorded && (_filePath != null && _filePath!.isNotEmpty))? Container(
                    height: 120.h,
                    width: 900.w,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(Radius.circular(50.sp)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 30.w),
                        GestureDetector(
                          onTap: (){
                            _isPlaying ? _stopPlaying() : _playRecordedAudio();
                            setState(() {
                              
                            });
                          },
                          child: Icon(
                            (_isPlaying)? Icons.stop : Icons.play_arrow,
                            size: 110.sp,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(width: 30.w),
                        MyText(text: (_isPlaying ? "Playing...." : "Play audio"), size: 60.sp, overflow: false, bold: false, color: Colors.black),
                      ],
                    ),
                  ) : Container(
                    height: 200.h,
                    width: 800.w,
                    color: Colors.transparent,
                  ),
                  SizedBox(height: 300.h),
                  MyText(text: "Record Audio", size: 70.sp, overflow: false, bold: true, color: Colors.white),
                  SizedBox(height: 70.h),
                  GestureDetector(
                    onTap: (){
                      recordState = true;
                      startTimer();
                      _startRecording();
                      startNoise();
                      recorded = false;
                      setState(() {});
                    },
                    child: Container(
                      height: 250.h,
                      width: 250.w,
                      decoration: const BoxDecoration(
                        color: Colors.pink,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 120.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}