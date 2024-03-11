import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neuro_task/constant/my_text.dart';
import 'package:neuro_task/constant/narration_text.dart';
import 'package:neuro_task/constant/responsive.dart';
import 'package:neuro_task/pages/homepage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:neuro_task/services/narration_services.dart';
import 'package:neuro_task/ui/game/narration_start_message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:noise_meter/noise_meter.dart';


class NarrationRecording extends StatefulWidget {
  const NarrationRecording({super.key});

  @override
  State<NarrationRecording> createState() => _NarrationRecordingState();
}

class _NarrationRecordingState extends State<NarrationRecording> {

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
      return const Icon(
        CupertinoIcons.waveform,
        //size: 150.sp,
        color: Colors.white,
      );
    }
    else if(_latestReading!.maxDecibel>= 56 && _latestReading!.maxDecibel>= 70){
      return const Icon(
        CupertinoIcons.speaker_1_fill,
        size: 150,
        color: Colors.green,
      );
    }
    else if(_latestReading!.maxDecibel> 70 && _latestReading!.maxDecibel>= 89){
      return const Icon(
        CupertinoIcons.speaker_2_fill,
        size: 150,
        color: Colors.green,
      );
    }
    else if(_latestReading!.maxDecibel>= 90){
      return const Icon(
        CupertinoIcons.volume_up,
        size: 150,
        color: Colors.green,
      );
    }
    else{
      return const Icon(
        CupertinoIcons.volume_off,
        size: 150,
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
  double screenHeight = 0.0,screenWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    double height = Responsive.screenHeight(context);
    double width = Responsive.screenWidth(context);
    screenHeight = height;
    screenWidth = width;
    return Container(
      height: height * 1,
      width: width * 1,
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
                  child: Text("Back",
                    style: TextStyle(
                      fontSize: (width / Responsive.designWidth) * 30,
                      color: const Color.fromARGB(166, 207, 207, 11),
                    ),
                  )
                ),
                InkWell(
                onTap: (){
                  NarrationStartMessage.startMessage(context);
                },
                  child: Container(
                  height: height * 0.05,
                  width: width * 0.1,
                  color: Colors.transparent,
                  child: const FittedBox(
                    child: Icon(CupertinoIcons.info,color: Color.fromARGB(166, 207, 207, 11),),
                  ),
                  ),
                ),
                TextButton(
                  onPressed: (){
                    _stopPlaying();
                    if(_filePath != null && _filePath!.isNotEmpty){
                      NarrationServices.sendAudioToDatabase(_filePath!);
                    }
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
            SizedBox(height: height * 0.05),
            const MyText(text: "Narration", size: 20, bold: true, color: Colors.white,height: 0.05,width: 1),
            SizedBox(height: height * 0.02),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     Column(
            //       children: [
            //         Icon(
            //           Icons.info_outline,
            //           size: 150.sp,
            //           color: Colors.white,
            //         ),
            //         SizedBox(height: 50.h),
            //         MyText(text: "Info", size: 70.sp, overflow: false, bold: true, color: Colors.white),
            //       ],
            //     ),
            //     Column(
            //       children: [
            //         voiceIcon(),
            //         SizedBox(height: 50.h),
            //         MyText(text: 'Voice Level', size: 70.sp, overflow: true, bold: true, color: Colors.white),
            //       ],
            //     ),
            //     Column(
            //       children: [
            //         Icon(
            //           CupertinoIcons.clock,
            //           size: 150.sp,
            //           color: Colors.white,
            //         ),
            //         SizedBox(height: 50.h),
            //         MyText(text: second.toString(), size: 70.sp, overflow: false, bold: true, color: Colors.white),
            //       ],
            //     ),
            //   ],
            // ),
            (recordState) ? Container(
              height: height * 0.9,
              width: width * 1,
              color: Colors.transparent,
              child: Column(
                children: [
                  SizedBox(height: height * 0.1),
                  Container(
                    height:height * 0.4,
                    width: width * 1,
                    color: Colors.transparent,
                    margin: EdgeInsets.symmetric(horizontal: width * 0.03),
                    child: Text(NarrationText.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (width/Responsive.designWidth) * 30,
                      ),
                    )
                  ),
                  SizedBox(height: height * 0.06),
                  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        _stopRecording();
                        recordState = false;
                        recorded = true;
                        second = 0;
                        //stop();
                        //stopNoise();
                      });
                      setState(() {
                        
                      });
                    },
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.pink),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.015,horizontal: width * 0.05),
                      child: const MyText(text: "Stop recording", size: 20, bold: true, color: Colors.white,height: 0.05,width: 0.4,)
                    ),
                  ),
                ],
              ),
            )
            : Container(
              height: height * 0.8,
              width: width * 1,
              color: Colors.transparent,
              child: Column(
                children: [
                  SizedBox(height: height * 0.2),
                  (recorded && (_filePath != null && _filePath!.isNotEmpty))? Container(
                    height: height * 0.07,
                    width: width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius:BorderRadius.all(Radius.circular((width/Responsive.designWidth) * 50)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: width * 0.03),
                        GestureDetector(
                          onTap: (){
                            _isPlaying ? _stopPlaying() : _playRecordedAudio();
                            setState(() {
                              
                            });
                          },
                          child: Icon(
                            (_isPlaying)? Icons.stop : Icons.play_arrow,
                            size: (width/Responsive.designWidth) * 40,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        MyText(text: (_isPlaying ? "Playing...." : "Play audio"), size: 30,bold: false, color: Colors.black,height: 0.04,width: 0.3,),
                      ],
                    ),
                  ) : Container(
                    height: height * 0.1,
                    width: width * 0.7,
                    color: Colors.transparent,
                  ),
                  SizedBox(height: height * 0.03),
                  const MyText(text: "Record Audio", size: 30,bold: true, color: Colors.white,height: 0.05,width: 1),
                  SizedBox(height: height * 0.07),
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
                      height: height * 0.2,
                      width: width * 0.2,
                      decoration: const BoxDecoration(
                        color: Colors.pink,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: (width/Responsive.designWidth) * 50,
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