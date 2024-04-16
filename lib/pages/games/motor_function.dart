import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:neuro_task/constant/my_text.dart';
import 'package:neuro_task/pages/homepage.dart';
import 'package:neuro_task/providers/memory_game_functions.dart';
import 'package:neuro_task/services/trace_shape_services.dart';
import 'package:neuro_task/ui/game/trace_shape_start_message.dart';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'flutter_sensors.dart';
import 'package:dart_numerics/dart_numerics.dart';

/*
The purpose of this file is to create the circle game.
The circle game allows the user to draw free-hand the outline of a circle
using the phone movement as the paint brush.
 */

/*
This call will call this program.
 */
class MotorFunction extends StatefulWidget {
  const MotorFunction ({super.key});

  //function will define the state of the Widget type Circle
  @override
  State<MotorFunction> createState() => _MotorFunctionState();
}

/*
Purpose of the class TakeScreenShotWindow is to condense the code for the Screenshot logic of the game.
By putting the logic inside a dedicated class, I am able to make the build code for the game
smaller.
User creates an object of TakeScreenShotWindow and the logic for the screenshot window will
be added.
 */
class TakeScreenShotWindow extends StatelessWidget{

  final String title;
  final Uint8List? capturedImageBytes;
  final Function()? onPressed;

  //define dimensions of the pop-up dialog box
  int DIALOG_HEIGHT = 900;
  int DIALOG_WIDTH = 500;
  int BORDER_WIDTH = 2;

  //define the dimensions of the screenshot picture
  double IMAGE_HEIGHT = 200;
  double IMAGE_WIDTH = 200;

  //constructor of the class, and required parameters
  TakeScreenShotWindow({
    Key? key,
    required this.title,
    @required this.capturedImageBytes,
    @required this.onPressed,
  }):assert( title!=null),
        assert(capturedImageBytes != null),
        assert(onPressed != null),
        super(key:key);

  /*
  override the build method to build the actual Widget that will appear on
  the screen for the user.
   */
  @override
  Widget build(BuildContext context)
  {

    return AlertDialog(
      title: Center(
        //MyText is a user-defined class
          child: MyText(
              text: this.title, size: 60.sp, overflow: false, bold: true, color: Colors.black)
      ),
      content: Container(
        height: DIALOG_HEIGHT.h,
        width: DIALOG_WIDTH.w,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: Colors.grey,
                width: BORDER_WIDTH.w
            )
        ),
        child: (capturedImageBytes!=null)? Image.memory(
            capturedImageBytes!, height: IMAGE_HEIGHT, width: IMAGE_WIDTH
        ) : const Center(
            child: CircularProgressIndicator()
        ),
      ),
      actions: [
        // this is a _Button custom class used to condense the logic of the Button
        // features for the game
        _Button(onPressed: onPressed, child: const Text("OK") )
      ],
    );
  }

}

/*
Humongous class to define the states for the game itself
 */
class _MotorFunctionState extends State<MotorFunction> {
  int start = 0, end = 0;

  //List<double> accelerometerValuesSample0 = <double>[];
  //List<double> accelerometerValuesSample1 = <double>[];
  //List<double> accelerometerValuesSample2 = <double>[];

  //List<double> velocitySample0 = <double>[0,0,0];
  //List<double> velocitySample1 = <double>[0,0,0];
  //List<double> positionSample0 = <double>[0,0,0];

  //int initAccMeasure = 0;

  //FlutterSensors has useful properties used for the on-board sensors on
  //the device
  static FlutterSensors temporary = FlutterSensors();

  //define properties of text that appear in the game
  final double FONT_SIZE = 20.0;
  final int ALPHA = 166;
  final int RED = 166;
  final int GREEN = 207;
  final int BLUE = 11;

  //used for sizing of containers
  //not sure how these numbers were derived
  final int DRAWING_CANVAS_WIDTH = 900;
  final int DRAWING_CANVAS_HEIGHT = 1400;
  final int DRAWING_CANVAS_INIT = 0;


  // Offset type is used to define points in cartesean plane.
  // Create an immediate list of Offset coordinates used to paint the image on
  // the screen.
  final List<Offset> _points = [];


  // List collection of Lists of Offsets.  Used to keep track of historical
  // points that are to appear on the screen.
  final List<List<Offset>> _pointsList = [];
  //final List<List<Offset>> _pointsList3= [];

  // Another list of Offsets.  Not sure why?
  final List<Offset> _points2 = [];


  //Another List collection of List of Offsets.  Not sure why?
  final List<List<Offset>> _pointsList2 = [];

  //used to determine if the user has extended the painting beyond the
  //boundaries of the canvas.
  bool isDrawingInsideBox = false;
  bool isEndingInsideBox = false;
  //bool _isDrawingInside = true;


  //CirclePainter is the user-defined class to create a Canvas and draw
  //the yellow circle
  final CirclePainter _painter = CirclePainter();

  String posX="";   //used to indicate x-axis on canvas
  String posY="";   //used to indicate y-axis on canvas
  String startTime="";  //?
  String endTime="";    //?
  String accuracy="";   //?

  Offset offsetOutside = Offset.zero;

  // used to take screenshot of the game
  final _screenshotController = ScreenshotController();
  Uint8List? _capturedImageBytes;

  void _captureScreenshot() async {
    final imageBytes = await _screenshotController.capture();
    setState(() {
      _capturedImageBytes = imageBytes;
    });
    _showScreenShot();
  }

  // used to define the dialog box for taking the screenshot of the game
  Future<dynamic> _showScreenShot(){
    return showDialog(
        context: context,
        builder: (context) {
          //Implemented class TakeScreenShotWindow
          return TakeScreenShotWindow(
            title: "ScreenShot",
            capturedImageBytes: _capturedImageBytes,
            onPressed: (){
              Navigator.pop(context);
              Get.to(const HomePage());
            },
          );
        }
    );
  }

  //?? not sure what this is for
  //doesn't return anything; modifies external variables posX, posY
  void screenXYCoordinate(details){
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    final double x = localOffset.dx;
    final double y = localOffset.dy;

    posX = x.toString();
    posY = y.toString();

    ///added these three lines
    print("posX = $posX}");
    print("posY = $posY");

  }

  //?? not sure what this is for
  final VelocityTracker velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);
  Offset offset = Offset.zero;
  Offset lastPosition = Offset.zero;

  //?? not sure what this is for
  // not sure what this does.  Only modifies local variables and doesn't
  // return anything
  void screenXYCoordinateEnd(Offset localPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset globalPosition = box.localToGlobal(localPosition);
    final double x = globalPosition.dx;
    final double y = globalPosition.dy;
    setState(() {
      posX = x.toString();
      posY = y.toString();
      print("PosX = $posX, PosY = $posY");
    });
  }


//  List<double> accelerometerValues = <double>[];

  //defines state of the circle game in flutter
  //this method updates regularly automatically by Flutter
  @override
  void initState() {

    //TraceShapeStartMessage defines the dialog box that appears when the circle
    //app starts on the device.
    WidgetsBinding.instance.addPostFrameCallback( (_) {
      TraceShapeStartMessage.startMessage(context);
    });
    super.initState();

    //starts the sensor engine and listens to AccelerometerEvent from the
    //onboard accelerometer of the device.
    //AccelerometerEvent includes the typical g acceleration (9.8m/s^2)
    //is used to derive the pitch and roll of the phone.
    FlutterSensors.startAccelerometerListening((AccelerometerEvent event) {

      setState(() {

        //x is negated because when I move the phone to right, the cursor moves
        //to the left, and vice versa => needed to correct this effect.
      accelerometerDir[0] = -1*event.x;
      accelerometerDir[1] = event.y;
      accelerometerDir[2] = event.z;

    });
    });

    //starts the sensor engine and listens to UserAccelerometerEvent from the
    //onboard accelerometer of the device.
    //UserAccelerometerEvent EXCLUDES the typical g acceleration (9.8m/s^2)
    //is used to derive the relative movement of the phone
    FlutterSensors.startUserAccelerometerListening((UserAccelerometerEvent event) {

      setState(() {

        accelerometer[0] = -1*event.x;
        accelerometer[1] = -1*event.y;
        accelerometer[2] = event.z;

        setPosition();
      });

    });

    //starts the sensor engine and listens to Magnetomer from the device.
    //Used to detect magnetic field strength surroudning the phone.
    //Used to determine when the phone is not in movement (which means that the
    //magnetic field doesn't change)
    FlutterSensors.startMagnetometerListening((MagnetometerEvent event2) {setState(() {

      magnet[0] = event2.x;
      magnet[1] = event2.y;
      magnet[2] = event2.z;

    });
    });

  }

  List<List<double>> mvAvg = [];  //used to take moving average
  int sampleSize = 10;  //moving average size is 10 samples

  List<double> accelerometer = [0,0,0];  //holds AccelerometerEvent reading
  List<double> accelerometerDir = [0,0,0]; //holds UserAccelerometerEvent reading
  List<double> magnet = [0,0,0]; //holds Magnetomer reading

  int sample = -1;  //used to determine location in state machine defined in
                    //setPosition() function

  List<double> sample0 = [0,0,0];   //moving average of the accelerometer
  List<double> sample1 = [0,0,0];   //moving average of the accelerometer
  //List<double> sample2 = [0,0,0];
  //List<double> init = [0,0,0];
  List<double> velocity0 = [0,0,0];  //velocity value
  List<double> velocity1 = [0,0,0];  //velocity value
  List<double> position = [0,0,0];   //position estimation
  List<double> position1 = [0,0,0];

  double xAxis = 0.0; //x-axis on Flutter canvas
  double yAxis = 0.0; //y-axis on Flutter canvas

  List<double> magnetSample0 = [0,0,0]; //sample Magnetometer value
  List<double> magnetSample1 = [0,0,0]; //sample Magnetometer value


  //int zerosCount = 0;

  //bool begin = false;
  //bool positive = false;
  List<double> initAcc = [0,0,0];  //initially calculated accelerometer moving avg


  //int index = 0;
  //List<List<double>> acc = [];

  /*
  Adding two vector values.
  Returns a vector of the results
   */
  List<double> add(List<double> v1, List<double> v2)
  {
    List<double> resultant = [0,0,0];

    resultant[0] = v1[0] + v2[0];
    resultant[1] = v1[1] + v2[1];
    resultant[2] = v1[2] + v2[2];

    return resultant;

  }

  /*
  Subtracts two vector values.
  Returns a vector of the results.
  */
  List<double> subtract(List<double> v1, List<double> v2)
  {
    List<double> resultant = [0,0,0];

    resultant[0] = v1[0] - v2[0];
    resultant[1] = v1[1] - v2[1];
    resultant[2] = v1[2] - v2[2];

    return resultant;

  }

  /*
  Multiply a vector by a scalar value.
  Returns a vector with the results.
   */
  List<double> scalarMultiply(double scalar, List<double> v1)
  {
    List<double> resultant = [0,0,0];
    resultant[0] = scalar*v1[0];
    resultant[1] = scalar*v1[1];
    resultant[2] = scalar*v1[2];

    return resultant;
  }

  /*
  Calculates a moving average of accelerometer values.
  The purpose is to smooth out the accelerometer data and suppress better abrupt
    changes in acceleration.
  Specify the number of samples (size).
  Returns the resulting average vector.
   */
  List<double> MovingAvg(List< List<double> > v1, int size)
  {
    List<double> resultant = [0,0,0];

    //add the acceleration vectors
    if(v1.length == size) {
      v1.forEach((temp) {
        resultant = add(resultant, temp);
      });

      //divide by the number of samples (size)
      resultant = scalarMultiply(1.0 / size, resultant);
    }

    return resultant;
  }


  /*
  Helper function that contains logic to determine if the full number of
    samples have been obtained for the moving average calculation.
  Specify the sample size.
  Returns boolean value indicating true (all samples obtained) or false
    (not all samples obtained yet).
   */
  bool fillMovingAvg(List<double> v1, List<List<double>> v2, int size)
  {
    //if List< List<double> > not full,
    // then keep adding accelerometer vectors (v1)
    if( v2.length < size)
      {
        v2.add(v1);
      }

    //if List< List<double> > not full, return false,
    // if full, then return true
    if( v2.length <= size)
      {
        return false;
      }else
      {
        return true;
    }

  }

  /*
    Helper function used to remove oldest index from movingAverage, and
      adding new entry.
   */
  void replaceValMovingAvg(List<double> v1, List<List<double>> v2, int size)
  {
    v2.removeAt(0);
    v2.add(v1);
  }

  /*
    Used to calculate the pitch of the phone.  The pitch is when the phone is
      vertical (with the screen facing the user), and with inclination (tilting
      toward the user and away from the user).
    I found this formula online, and seems to work.

    This helps to know when the phone is pitched too much.
   */
  double pitch(List<double> v1)
  {
    return acos(-1*v1[1]/sqrt( v1[0]*v1[0] + v1[1]*v1[1] + v1[2]*v1[2] ))*180/pi;

  }

  /*
    Doesn't work.
    Used to calculate the roll of the phone.  The Roll is when the phone is vertical
      (with the screen facing the user) and the phone is tilted to the left or
      right.
    Equation didn't work.  Need more research.
   */
  double roll(List<double> v1)
  {
    return atan2(-1*v1[2],sqrt(v1[0]*v1[0] + v1[1]*v1[1]))*180/pi;
  }

  /*
    Copies a vector into another vector.
   */
  void vectorCopy(List<double> v1, List<double> v2)
  {
    v1[0] = v2[0];
    v1[1] = v2[1];
    v1[2] = v2[2];
  }

  /*
    Function used to return a copy of the vector.
    Returns the copy of the vector input.
   */
  List<double> reflect(List<double> v1)
  {
    List<double> temp = [0,0,0];
    vectorCopy(temp, v1);
    return temp;
  }


  /*
    Function takes a vector, and returns the unit vector.
    Returns the unit vector of the input.
   */
  List<double> normalizeV(List<double> v1)
  {
    List<double> resultant = [0,0,0];

    double magnitudeV = magnitude(v1);

    resultant[0] = v1[0]/magnitudeV;
    resultant[1] = v1[1]/magnitudeV;
    resultant[2] = v1[2]/magnitudeV;

    return resultant;
  }

  /*
    Function used to find the magnitude of the vector.
    Returns the scalar magnitude of the input vector.
   */
  double magnitude(List<double> v1)
  {
    return sqrt( v1[0]*v1[0] + v1[1]*v1[1] + v1[2]*v1[2]);
  }

  //FlutterSensors temp = FlutterSensors();


  /*
    Function implements trapezoid discrete integration on each axis: x,y,z.
    Use the sampling rate of the sensors for delta t:
      temporary.sensorInterval.inMilliseconds/1000

    Returns the intergral for x, y, z axis.

   */
  List<double> integrate(List<double> inits, List<double> first, List<double> second)
  {

    inits[0] = inits[0] + (first[0] + second[0])* temporary.sensorInterval.inMilliseconds/2000;
    inits[1] = inits[1] + (first[1] + second[1])* temporary.sensorInterval.inMilliseconds/2000;
    inits[2] = inits[2] + (first[2] + second[2])* temporary.sensorInterval.inMilliseconds/2000;

    return inits;
  }

  /*
    Function used to calculate a position on the phone screen based on the
      accelerometer and magnetomer sensors on the phone.  Implementing multiple
      sensors into the logic is called "sensor fusion".

    Function calculates position using Calculus.
      * Integral of acceleration => velocity.
      * Integral of velocity => position.

    Implements a few additional steps to control the influence of excessive
      movement on the calculation of position.
    Researched about this topic online, but had trouble understanding the
      research papers on this topic.  I implemented interesting ideas found
      online, such as using scaling factors to control chaotic movement.
    I'm sure there are better, more elegant and efficient ways of
      implementing this function.  I didn't have sufficient time to do more
      in-depth reading on this vast topic.

    !!**Position on the canvas is still chaotic, so this function requires
      more improvement**!!.

    NOTE: Test phone does not support a gryroscope, and that is why gryroscope
      is not used here.
   */

  bool changeDirection(List<double> v1, List<double> v2)
  {
    bool resultant = false;

    if((v1[0] > 0 && v2[0] > 0) || (v1[0] <0 && v2[0]<0)){
      if((v1[1] > 0 && v2[1] > 0)  || (v1[1] <0 && v2[1]<0))
            {
              resultant = false;
            }else{
            resultant = true;
        }
    }
    return resultant;

  }

  bool positive = true;
  bool curveChange = false;

  setPosition(){

    //as far as I understand, setState updates the Flutter scaffolding.

    setState((){
      print("Acc = $accelerometer");
      print("Magnet = $magnet");


      //this line is used to initially fill the List of mvAvg vectors with
      // up to sampleSize # of accelerometer data points
      // State starts = -1
      if ( !fillMovingAvg(reflect(accelerometer), mvAvg, sampleSize) ){

        //if size of mvAvg = sampleSize, move to State = 0.
        if(mvAvg.length == sampleSize && sample == -1)
        { sample = 0;

        vectorCopy(initAcc, accelerometer);}

      }

      if (sample == 0) {
        //Take the mvAvg and copy vector into sample;
        vectorCopy(sample0, subtract(initAcc,MovingAvg(mvAvg, sampleSize)));

        //copy the magnetometer vector to magnetSample0
        vectorCopy(magnetSample0, magnet);

        //move to State 1
        sample = 1;

      }else if (sample == 1) {

        //add new acceleromter data point into mvAvg moving average collection
        replaceValMovingAvg(reflect(accelerometer), mvAvg, sampleSize);

        //vectorCopy(sample1, subtract(initAcc,MovingAvg(mvAvg, sampleSize)));

        // taking current mvAvg moving average and copy vector to sample1
        vectorCopy(sample1, MovingAvg(mvAvg, sampleSize));

        //read current magnetometer vector
        vectorCopy(magnetSample1, magnet);
        //magnetSample1 = magnet;

         print("pitch1 = ${pitch(accelerometerDir).abs()}");
        //if(magnitude(subtract(sample1, sample0)).abs()/temporary.sensorInterval.inMilliseconds/1000 < 1 ) {

          /*
            if phone it pitched > 145 degress (or about 35 degrees from vertical)
              Purpose: to remove any false movements due to bad phone posture
          */
          if (pitch(accelerometerDir).abs() > 145) {

            /*
              I use the magnetometer to determine if the phone is moving.
              It appears that when the phone is perfectly still, the magnetometer
                x, y, z values stay constant.
              Purpose: to remove any false movements due to small vibrations of hand
              NOTE: the threshold 0.001 was chosen based on my tests.
             */
            if (magnitude(subtract(magnetSample1, magnetSample0)).abs() > 0.001) {

              //calculate the velocity by integrating accelerometer data points
              velocity0 = integrate(velocity0, sample0, sample1);
              print("Velocity0 = $velocity0");

              /*
                if the velocity > 0.01 then I can consider this valid phone movement.
                NOTE: the threshold 0.01 was chosen based on my tests.
               */
              if(magnitude(velocity0).abs() > 0.01) {

                vectorCopy(sample0, sample1);

                //next State = 2
                sample = 2;
              }
            } else {

              /*
                  If the velocity was too high, or the pitch was too great,
                    then set current velocity to vector [0,0,0].
               */
              vectorCopy(velocity0, [0, 0, 0]);

            }
          }
        //}
        vectorCopy(sample0, sample1);
        //sample0 = sample1;
        //magnetSample0 = magnetSample1;

      }else if (sample == 2) {
            //add new acceleromter data point into mvAvg moving average collection
            replaceValMovingAvg(reflect(accelerometer), mvAvg, sampleSize);

            //read the new movingAverage value
            vectorCopy(sample1, MovingAvg(mvAvg, sampleSize));

            //read new magnetometer value
            vectorCopy(magnetSample1, magnet);

            print("PITCH = ${pitch(accelerometerDir)}");
            print("ROLL = ${roll(accelerometerDir)}");
 //           if((sample1[0]).abs() < 1 && (sample1[1]).abs() < 1) {
          //if(magnitude(subtract(sample1, sample0)).abs()/temporary.sensorInterval.inMilliseconds/1000 < 1) {

            /*
              if phone it pitched > 145 degress (or about 35 degrees from vertical)
                Purpose: to remove any false movements due to bad phone posture
            */
              if (pitch(accelerometerDir).abs() > 145) {
                /*
                  I use the magnetometer to determine if the phone is moving.
                  It appears that when the phone is perfectly still, the magnetometer
                    x, y, z values stay constant.
                  Purpose: to remove any false movements due to small vibrations of hand
                  NOTE: the threshold 0.001 was chosen based on my tests.
                */
                if (magnitude(subtract(magnetSample1, magnetSample0)).abs() > 0.001) {
                  //calculate velocity by integrating 2 accelerometer data points
                  velocity1 = integrate(velocity0, sample0, sample1);
                  print("Velocity1 = ${velocity1[0]}");

                  /*
                    if the velocity > 0.01 then I can consider this valid phone movement.
                    NOTE: the threshold 0.01 was chosen based on my tests.
                  */
                  if (magnitude(velocity1).abs() > 0.01){
                    //calculate position by integrating 2 velocity points
                    position = integrate(position, scalarMultiply(1, velocity0),
                        scalarMultiply(1, velocity1));

                    print("Magnitude = ${magnitude(sample1)}");

                      print("Position = ${position[0]}");

                      vectorCopy(velocity0, velocity1);
                      //velocity0 = velocity1;
                      sample = 2;

                      //xAxis + yAxis update the position on the Canvas
                      this.xAxis = 900 / 4 + 100 * (position[0]);
                      this.yAxis = 1400 / 4 + 100 * (-1 * position[1]);

                      //set xAxis + yAxis as an Offset class
                      Offset tempOffset = Offset(this.xAxis, this.yAxis);
                      print("Offset = $tempOffset");

                      //save into _points2 list
                      _points2.add(tempOffset);
                      //add to the _painter object
                      _painter.addPoint(tempOffset);
                    } else {
                      vectorCopy(velocity0, [0, 0, 0]);
                    }

                    vectorCopy(position1, position);

                } else {
                  //if velocity is too great, then set to zero.
                  //this is my effort to clamp down on the run-away speeding
                  //of the graph
                  vectorCopy(velocity0, [0, 0, 0]);

                }
                //
              }
            //}
            vectorCopy(magnetSample0, magnetSample1);
            //magnetSample0 = magnetSample1;
            vectorCopy(sample0, sample1);
            //sample0 = sample1;
          }
    });

  }



/*

 //My original implementation of setPosition

  setPosition(UserAccelerometerEvent event){
   // if (event == null){
   //   return 0;
   // }
    setState((){

      //print("");

      if (sample == 0) {
        sample0 = [event.x, event.y];
        sample = 1;
        /*
        this.xAxis = this.xAxis + event.x * 12;
        this.yAxis = this.yAxis + event.y * 12;


        Offset tempOffset = Offset(this.xAxis, this.yAxis);
        print("Offset = $tempOffset");

        _points2.add(tempOffset);
        _painter.addPoint(tempOffset);

         */
      }else if (sample == 1)
        {
          sample1 = [event.x, event.y];
          velocity0 = integrate(velocity0, sample0, sample1);
          print("Velocity0 = $velocity0");
          sample0 = sample1;
          sample = 2;
        }else if (sample == 2) {
          sample1 = [-1*event.x, event.y];
          if( (sample0[0]-sample1[0]).abs() < 0.00003){
            velocity0[0] = 0;
          }else if( (sample0[1] - sample1[1]).abs() < 0.00003){
            velocity0[1] = 0;
          }

          velocity1 = integrate(velocity0, sample0, sample1);
          print("Velocity1 = ${velocity1[0]}");
          position = integrate(position, velocity0, velocity1);
          print("Position = ${position[0]}");
          velocity0 = velocity1;
          sample0 = sample1;
          sample = 2;

          this.xAxis = 2*(position[0]);
          this.yAxis = 2*(position[1]);

          Offset tempOffset = Offset(this.xAxis, this.yAxis);
          print("Offset = $tempOffset");

          _points2.add(tempOffset);
          _painter.addPoint(tempOffset);
      }




    });
  }

*/


  //?? seems to be unnecessarily long!??
  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: Scaffold(
        body: Screenshot(
          //?
          controller: _screenshotController,
          child: Container(
            //this container define the top area of the circle game screen, where
            //the menu is.  It does NOT define the area where the circle is to be
            //drawn.
            height: double.maxFinite,
            width: double.maxFinite,
            color: Colors.red, //Colors.white,

              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //_Button are used as "Column" Widgets
                        //created a separate class _Button to reduce the size of the nested tree of Widgets as they appear here
                        _Button(
                            onPressed: (){
                              Get.to(const HomePage());
                            },
                            child: Text( "Back",   //add null test "!"
                                style: TextStyle(
                                    fontSize: FONT_SIZE,
                                    color: Color.fromARGB(ALPHA, RED, GREEN, BLUE)
                                )
                            )
                        ),
                        _Button(onPressed: (){
                          TraceShapeService.reset();
                          _points.clear();
                          _points2.clear();
                          _pointsList.clear();
                          _pointsList2.clear();
                        },
                            child: Text( "Reset",   //add null test "!"
                                style: TextStyle(
                                    fontSize: FONT_SIZE,
                                    color: Color.fromARGB(ALPHA, RED, GREEN, BLUE)
                                )
                            )
                        ),
                        _Button(onPressed: (){
                          //TraceShapeService.traceShapeData();
                          _captureScreenshot();
                        },
                            child: Text( "Submit",   //add null test "!"
                                style: TextStyle(
                                    fontSize: FONT_SIZE,
                                    color: Color.fromARGB(ALPHA, RED, GREEN, BLUE)
                                )
                            )
                        )
                      ],
                    ),
                Positioned(
                  /*
                                        This is part of the "children" of the Stack Widget above
                                         */

                  //created DRAWING_CANVAS_HEIGHT and DRAWING_CANVAS_WIDTH as
                  //class variables to improve readability.
                  //not sure how those values were derived
                  top: (MediaQuery.of(context).size.height - DRAWING_CANVAS_HEIGHT.h) / 2,
                  left: (MediaQuery.of(context).size.width - DRAWING_CANVAS_WIDTH.w) / 2,
                  width: DRAWING_CANVAS_WIDTH.w,
                  height: DRAWING_CANVAS_HEIGHT.h,

                        child: Container(

                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 5.w,
                                )
                            ),

                          child: Stack(
                              children: [
                          Positioned(
                          child: CustomPaint(
                          size: Size(900.w, 1400.h),
                          painter: _painter,  //actually paints the yellow circle!
                        ),
                ),
                Positioned(

                  child: CustomPaint(
                      painter: testing(current_points: _points2, historical_pointsList: _pointsList2)
                    //MyCustomPainter2(pointsList: _pointsList2),
                  ),
                                ),
                              ],
                            )
                        ),

                    ),

                    CustomPaint(
                        painter: testing(current_points: _points, historical_pointsList: _pointsList)
                      //     painter: MyCustomPainter(pointsList: _pointsList2),
                    ),
                    ////***********

                  ],
                ),
              ),
            ),
          ),
    ),
     // ),
    );



  }

  bool screenBox(Offset point) {
    //MediaQuery is used to get the height + width of the screen (screen =
    //"context" object.

    final boxCenter = Offset(MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2
    ); // Center of the red box

    //sets the relative proportion of the screenBox based on the draft pixel
    //size.  In this case, the proportion is 900.w x 1400.h
    final boxWidth = 900.w; // Width of the red box
    final boxHeight = 1400.h; // Height of the red box

    final leftBoundary = boxCenter.dx - boxWidth / 2;
    final rightBoundary = boxCenter.dx + boxWidth / 2;
    final topBoundary = boxCenter.dy - boxHeight / 2;
    final bottomBoundary = boxCenter.dy + boxHeight / 2;

    return point.dx >= leftBoundary &&
        point.dx <= rightBoundary &&
        point.dy >= topBoundary &&
        point.dy <= bottomBoundary;
  }

  double calculateAccuracy(CirclePainter painter) {
    final center = Offset(900.w / 2, 1400.h / 2); // Center of the screen
    final radius = 900.sp / 3; // Radius of the circle
    final numPoints = painter.points.length;

    double totalDistance = 0;
    for (final point in painter.points) {
      final distance = (point - center).distance - radius;
      totalDistance += distance.abs();
    }

    final averageDistance = totalDistance / numPoints;
    final accuracy = (1 - averageDistance / radius) * 100;

    return accuracy.clamp(0, 100);
  }




}



class testing extends CustomPainter{


  final List<Offset> current_points;
  final List<List<Offset>> historical_pointsList;

  double? xAxis;
  double? yAxis;

  testing({required this.current_points,
    required this.historical_pointsList});

  void addPoint(Offset point)
  {
    current_points.add(point);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width/2, size.height/2);
    //print("Inside testing class => paint");
    //print("Size = $size");
    //print("Current points ${current_points}");
    //supply instructions to paint on the Canvas
    //each time it is called, it runs through the list array and draws
    //the points on the canvas
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < current_points.length - 1; i++) {
      canvas.drawLine(current_points[i], current_points[i + 1], paint);
    }

    for (final points in historical_pointsList) {
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


//??
// MyCustomPainter and MyCustomPainter2 appear to be identical!
class MyCustomPainter extends CustomPainter {
  final List<List<Offset>> pointsList;

  MyCustomPainter({required this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    //supply instructions to paint on the Canvas
    //each time it is called, it runs through the list array and draws
    //the points on the canvas
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    for (final points in pointsList) {
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MyCustomPainter2 extends CustomPainter {
  final List<List<Offset>> pointsList;

  MyCustomPainter2({required this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    for (final points in pointsList) {
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


/*
    It looks like this class is used to define a Canvas that is used to draw the
    reference yellow circle when the game begins.
     */
class CirclePainter extends CustomPainter {

  //Paint class defines the style to use when drawing on the Canvas
  final Paint _paint;

  //??
  final List<Offset> points = [];

  //constructor -- initializing _paint local variable; initialing Paint()
  //class parameters
  CirclePainter() : _paint = Paint()
    ..color = Colors.yellow
    ..strokeWidth = 5.0
    ..style = PaintingStyle.stroke;

  // final _paint2 = Paint()
  //   ..color = Colors.black
  //   ..strokeWidth = 3.0
  //   ..style = PaintingStyle.stroke;

  //mandatory to define for subclass of CustomPainter
  @override
  void paint(Canvas canvas, Size size) {
    //print("inside painting now!");
    //Canvas class is used to create Picture objects
    //Size is used to define the area of the box where the Canvas will be located.

    //define center of the Canvas box defined in Cartesean plane.
    final center = Offset(size.width / 2, size.height / 2);

    //radius of circle is 1/3 of the box size
    final radius = size.width / 3;

    //draw the circle on the canvas with the specified center, radius.
    //also _paint defines the style to use (color, width, etc)
    canvas.drawCircle(center, radius, _paint);

    //  for (int i = 0; i < points.length-1; i++) {
    //   canvas.drawLine(points[i], points[i + 1], _paint2);
    // }
  }

  //mandatory to define for subclass of CustomPainter
  //since CirclePainter constructor doesn't take any variables, the object is
  //not expected to change.  So shouldRepaint == false since new instances of
  //the object should not change the existing CustomPainter object
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  //not sure how this is used in this game.
  //Adds a point to the List<Offset> collection of points
  void addPoint(Offset point) {
    points.add(point);
  }

  //not sure how this is used in this game.
  //removes all entries of the List<Offset> collection of points
  void reset() {
    points.clear();
  }
}

/*
The below _Button class is my attempt to reduce the size of the Scafold Widget inside
the _CircleState class.
I found the Scaffold Widget difficult to read, especially for someone using
Flutter the first time.
 */
class _Button extends StatelessWidget{

  //Used to give user ability to pass function into the _Button Widget
  final Function()? onPressed;
  //Used to give user ability to pass another Widget as a child parameter.
  final Widget child;

  const _Button({
    Key? key,
    @required this.onPressed,
    required this.child
  }):assert(onPressed != null),
        assert(child != null),
        super(key:key);

  /*When _Button object is running, the build function will be called.
    This build function contains the context for the Widget

     */
  @override
  Widget build(BuildContext context){


    return Column(
        children: [

          TextButton(
              onPressed: onPressed,  //customer passes the desired callback function
              child: child
            /*child: Text( text!,   //add null test "!"
                                        style: TextStyle(
                                            fontSize: FONT_SIZE,
                                            color: Color.fromARGB(ALPHA, RED, GREEN, BLUE)
                                            )
                                        )

                         */

          )
        ]

    );
  }
}

