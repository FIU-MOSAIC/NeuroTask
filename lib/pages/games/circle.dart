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

/*
The purpose of this file is to create the circle game.
The circle game allows the user to draw free-hand the outline of a circle
on the UI canvas.
 */

/*
Creates a Circle Widget.
 */
class Circle extends StatefulWidget {
    const Circle({super.key});

    //function will define the state of the Widget type Circle
    @override
    State<Circle> createState() => _CircleState();
}

class Intermediate {
    int start = 0, end = 0;

    //used for positioning; added these to improve readability
    //not sure how these numbers were derived
    final int DRAWING_CANVAS_WIDTH = 900;
    final int DRAWING_CANVAS_HEIGHT = 1400;
    final int DRAWING_CANVAS_INIT = 0;

    //?
    // Offset type is used to define points in cartesean plane.
    //Create a List of Offsets.  Not sure why?
    final List<Offset> _points = [];

    //?
    // List collection of a List of Offsets.  Not sure why?
    final List<List<Offset>> _pointsList = [];
    final List<List<Offset>> _pointsList3 = [];

    // Another list of Offsets.  Not sure why?
    final List<Offset> _points2 = [];

    //?
    //Another List collection of List of Offsets.  Not sure why?
    final List<List<Offset>> _pointsList2 = [];

    String posX="",posY="",startTime="",endTime="",accuracy="";
    Offset offsetOutside = Offset.zero;


}

/*
Purpose of this class is to concendce the code for the Screenshot logic of the game.
By putting the logic inside a dedicated class, I am able to make the build code for the game
smaller.
User creates an object of TakeScreenShotWindow and the logic for the screenshot window will
be added.
 */
class TakeScreenShotWindow extends StatelessWidget{

    final String title;
    final Uint8List? capturedImageBytes;
    final Function()? onPressed;

    int DIALOG_HEIGHT = 900;
    int DIALOG_WIDTH = 500;
    int BORDER_WIDTH = 2;
    double IMAGE_HEIGHT = 200;
    double IMAGE_WIDTH = 200;

    //?? used to take screenshot of the game ?
    TakeScreenShotWindow({
        Key? key,
        required this.title,
        @required this.capturedImageBytes,
        @required this.onPressed,
    }):assert( title!=null),
            assert(capturedImageBytes != null),
            assert(onPressed != null),
            super(key:key);

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
                _Button(onPressed: onPressed, child: const Text("OK") )
                /*
                        TextButton(
                        onPressed: onPressed,
                        child: const Text('OK')
                    ),

 */
            ],
        );
    }

}

/*
Humongous class to define the states for the Widget Circle
 */
class _CircleState extends State<Circle> {
    int start = 0, end = 0;

    final double FONT_SIZE = 20.0;
    final int ALPHA = 166;
    final int RED = 166;
    final int GREEN = 207;
    final int BLUE = 11;

    //used for positioning; added these to improve readability
    //not sure how these numbers were derived
    final int DRAWING_CANVAS_WIDTH = 900;
    final int DRAWING_CANVAS_HEIGHT = 1400;
    final int DRAWING_CANVAS_INIT = 0;

    //?
    // Offset type is used to define points in cartesean plane.
    //Create a List of Offsets.  Not sure why?
    final List<Offset> _points = [];

    //?
    // List collection of a List of Offsets.  Not sure why?
    final List<List<Offset>> _pointsList = [];
    final List<List<Offset>> _pointsList3= [];

    //?
    // Another list of Offsets.  Not sure why?
    final List<Offset> _points2 = [];

    //?
    //Another List collection of List of Offsets.  Not sure why?
    final List<List<Offset>> _pointsList2 = [];

    bool isDrawingInsideBox = false;
    bool isEndingInsideBox = false;

    //CirclePainter is the user-defined class to create a Canvas and draw
    //the yellow circle
    final CirclePainter _painter = CirclePainter();

    //???
    bool _isDrawingInside = true;
    String posX="",posY="",startTime="",endTime="",accuracy="";
    Offset offsetOutside = Offset.zero;

    //temporarily removign this section
    //?? used to take screenshot of the game ??
    final _screenshotController = ScreenshotController();
    Uint8List? _capturedImageBytes;

    //?? used to take screenshot of the game ??
    void _captureScreenshot() async {
        final imageBytes = await _screenshotController.capture();
        setState(() {
            _capturedImageBytes = imageBytes;
        });
        _showScreenShot();
    }


    //?? used to take screenshot of the game ??
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
        //print(details.globalPosition);
        //////////
    }

    //??
    final VelocityTracker velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);
    Offset offset = Offset.zero;
    Offset lastPosition = Offset.zero;

    //?? not sure what this is for
    //not sure what this does.  Only modifies local variables and doesn't
    //return anything
    //? why is the setState() inside this function and not part of the Scaffolding???
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

    //defines start of the circle game in flutter
    @override
    void initState() {
        //TraceShapeStartMessage defines the dialog box that appears when the circle
        //app starts on the User Equipment (UE).

        WidgetsBinding.instance.addPostFrameCallback( (_) {
            TraceShapeStartMessage.startMessage(context);
        });
        super.initState();
    }

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

                        child: GestureDetector(
                            /*
                            This GestureDetector should be the Widget for detection
                            of the Gesture over the entire screen
                             */

                            /*
                            ?
                            Why does the part of the screen outside of the Canvas, where
                            the circle is, need onPanStart, onPanUpdate and onPanEnd?
                            Seems weird to me since the circle is not in this box.
                             */
                            onPanStart: (details) {
                                _points.clear();
                                //Data Collection
                                //???? why is the memory game here?
                                //???
                                MemoryGameFunctions.findTime();
                                TraceShapeService.lineStartTime.add(MemoryGameFunctions.formattedTime);

                                screenXYCoordinate(details);
                                TraceShapeService.startRegion.add("$posX,$posY");
                                TraceShapeService.startLocation.add('0');

                                //?
                                // not sure what this is for
                                setState(() {
                                    print("inside onPanStart - gesturedetector 1");
                                    isDrawingInsideBox = screenBox(details.localPosition);
                                    isEndingInsideBox = true; // Reset the end status when drawing starts
                                    //_points.add(details.localPosition); // Add the starting point
                                    //added by JB
                                    _points.add(details.localPosition);
                                    print("details.localPosition = $details.localPosition");
                                });
                            },

                            //?
                            //why is DragUpdateDetails details used for onPanUpdate??
                            onPanUpdate: (DragUpdateDetails details) {
                                setState(() {
                                    print("inside onPanUpdate - gesturedetector 1");
                                    offsetOutside = details.delta;
                                    //_points.add(details.localPosition);
                                    _points.add(details.localPosition); //added by JBB

                                    //////////

                                });
                            },

                            onPanEnd: (DragEndDetails details) {
                                print("inside onPanEND - gesturedetector 1");
                                if (_points.isNotEmpty) {
                                    //_pointsList.add([..._points]);  //adding points into _pointsList
                                    _pointsList.add([..._points]);    //added by JB
                                    setState(() {
                                        isEndingInsideBox = screenBox(_points2.last);
                                    });

                                    MemoryGameFunctions.findTime();
                                    TraceShapeService.lineEndTime.add(MemoryGameFunctions.formattedTime);
                                    // ignore: unused_local_variable
                                    //final velocity = velocityTracker.getVelocity();
                                    if (lastPosition != Offset.zero) {
                                        screenXYCoordinateEnd(lastPosition);
                                    }
                                    TraceShapeService.endRegion.add('$posX,$posY');
                                    (isEndingInsideBox) ? TraceShapeService.endLocation.add('1'): TraceShapeService.endLocation.add('0');

                                    // showDialog(
                                    //   context: context,
                                    //   builder: (_) => AlertDialog(
                                    //     title: const Text('Drawing Status'),
                                    //     content: Text(
                                    //       'Start: ${isDrawingInsideBox ? "Inside" : "Outside"}\n'
                                    //       'End: ${isEndingInsideBox ? "Inside" : "Outside"}',
                                    //     ),
                                    //     actions: [
                                    //       ElevatedButton(
                                    //         onPressed: () {
                                    //           Navigator.pop(context);
                                    //         },
                                    //         child: const Text('OK'),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // );
                                    _points.clear();
                                }
                                else{
                                    MemoryGameFunctions.findTime();
                                    TraceShapeService.lineEndTime.add(MemoryGameFunctions.formattedTime);
                                    if (lastPosition != Offset.zero) {
                                        screenXYCoordinateEnd(lastPosition);
                                    }
                                    TraceShapeService.endRegion.add('$posX,$posY');
                                    (isEndingInsideBox) ? TraceShapeService.endLocation.add('0'):
                                    TraceShapeService.endLocation.add('0');
                                }

                                TraceShapeService.accuracy.add('0.00');
                            },

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

                                            child: GestureDetector(

                                                onPanStart: (details) {
                                                    _points2.clear();
                                                    //Data Collection
                                                    print("OnPanStart");
                                                    _painter.addPoint(details.localPosition);   //CirclePainter class object
                                                    _points2.add(details.localPosition);        //List<Offset> collection object

                                                    MemoryGameFunctions.findTime();
                                                    /*
                                                TraceShapeService defined in trace_shape_services.dart
                                                Should these variables be hidden?
                                                writing to local varaibles defined in TraceShapeService
                                                 */
                                                    TraceShapeService.lineStartTime.add(MemoryGameFunctions.formattedTime);
                                                    screenXYCoordinate(details);                //get relative coordinates
                                                    TraceShapeService.startRegion.add("$posX,$posY");

                                                    //not sure why '1' is added to the List<String> collection
                                                    TraceShapeService.startLocation.add('0');
                                                },

                                                onPanUpdate: (details) {
                                                    print("OnPanUpdate");
                                                    //why _painter & _points2 variables?  very, very strange
                                                    _painter.addPoint(details.localPosition);   //CirclePainter class object
                                                    _points2.add(details.localPosition);        //List<Offset> collection object

                                                    setState(() {
                                                        print("iNSIDE => onpanupdate");

                                                        _painter.addPoint(details.localPosition);   //CirclePainter class object
                                                        _points2.add(details.localPosition);        //List<Offset> collection object
                                                        //Added by Juan
                                                        //! this line allows the circle to be drawn in near real time;
                                                        //HORRIBLE delay.  Need to see how to optimize this.

                                                        //_pointsList2.add([..._points2]);        //List<Offset> collection object
                                                        //

                                                        //determines if the current cursor is inside the drawing area
                                                        //added variables DRAWING_CANVAS_HEIGHT, DRAWING_CANVAS_WIDTH and DRAWING_CANVAS_INIT
                                                        //for readability

                                                        if (details.localPosition.dx < DRAWING_CANVAS_INIT ||
                                                            details.localPosition.dx > DRAWING_CANVAS_WIDTH.h ||
                                                            details.localPosition.dy < DRAWING_CANVAS_INIT ||
                                                            details.localPosition.dy > DRAWING_CANVAS_HEIGHT.w)
                                                        {
                                                            _isDrawingInside = false;
                                                        }
                                                    });

                                                },

                                                onPanEnd: (details) {

                                                    print("OnPanEnd");
                                                    _pointsList2.add([..._points2]);        //List<Offset> collection object
                                                    final accuracy = calculateAccuracy(_painter);
                                                    print(accuracy);

                                                    setState(() {

                                                        MemoryGameFunctions.findTime();

                                                        /*
                                                    TraceShapeService defined in trace_shape_services.dart
                                                    Should these variables be hidden?
                                                    writing to local varaibles defined in TraceShapeService
                                                    */
                                                        TraceShapeService.lineEndTime.add(MemoryGameFunctions.formattedTime);
                                                        if (lastPosition != Offset.zero) {
                                                            //not sure difference between screenXYCoordinateEnd vs screenXYCoordinate
                                                            screenXYCoordinateEnd(lastPosition);
                                                        }
                                                        TraceShapeService.endRegion.add('$posX,$posY');
                                                        if (_isDrawingInside) {
                                                            //why adding '1'
                                                            TraceShapeService.endLocation.add('1');
                                                        }
                                                        else {
                                                            //why adding '0'
                                                            TraceShapeService.endLocation.add('0');
                                                        }
                                                        _isDrawingInside = true;
                                                    });



                                                    TraceShapeService.accuracy.add("${accuracy.toStringAsFixed(2)}%");
                                                    _painter.reset();
                                                    _points2.clear();
                                                },



                                                //another Container Widget inside Positioned
                                                //why is Painter in a different Container from the Gesture Control?????

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
            ),
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

    testing({required this.current_points,
        required this.historical_pointsList});

    void addPoint(Offset point)
    {
        current_points.add(point);
    }

    @override
    void paint(Canvas canvas, Size size) {
        //print("Inside testing class => paint");
        //print("Size = $size");
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
        print("inside painting now!");
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

