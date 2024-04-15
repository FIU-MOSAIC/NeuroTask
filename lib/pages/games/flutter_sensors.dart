import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:all_sensors/all_sensors.dart' as all_sensors;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dio/dio.dart';

class FlutterSensors {
  //static final KoiosAPIClient koiosAPIClient = KoiosAPIClient(Dio());

  static StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  static StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  static StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;
  static StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  static StreamSubscription<all_sensors.ProximityEvent>? _proximitySubscription;
// TODO EDITING HERE
  static List<String>? currSensorCacheFilePaths = [];
  static List<String>? prevSensorCacheFilePaths;
  static bool cleared = false;

  //Added for the sampling interval
  Duration sensorInterval = SensorInterval.normalInterval;

  Duration get samplingRate => sensorInterval;

  static Future<List<String>?> saveCacheFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('sensorCacheFilePaths', currSensorCacheFilePaths!);

    print('Saved: ' + currSensorCacheFilePaths.toString());
    return currSensorCacheFilePaths;
  }

  static Future<List<String>?> readCacheFiles() async {  // Loads the previous cache files
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prevSensorCacheFilePaths = prefs.getStringList('sensorCacheFilePaths');

    print('Loaded: ' + prevSensorCacheFilePaths.toString());
    if (prevSensorCacheFilePaths == null)
      prevSensorCacheFilePaths = [];

    return prevSensorCacheFilePaths;
  }

  static Future<void> addFileToCache(String fileName) async {
    if (!cleared) {  // Make sure its clear each time the app is in a new instance
      clearCache();
      cleared = true;
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    if (!(await file.exists())) {  // If the file does not exist, end the function
      return;
    }
    for (String path in currSensorCacheFilePaths!) {  // If the file exists in the list, don't add it
      if (path == filePath) {
        return;
      }
    }
    currSensorCacheFilePaths?.add(filePath);
    print('Added file: $currSensorCacheFilePaths.toString()');
    saveCacheFiles();
  }

  static Future<void> clearCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getStringList('sensorCacheFilePaths')?.clear();
    currSensorCacheFilePaths?.clear();
    saveCacheFiles();
  }

  //TODO -------------------------------------------------------------------


  // Add text to a file, or create and write to one if it does not exist
  static Future<void> appendToFile(String fileName, String text) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    // Check if the file exists, create it if it doesn't
    if (!(await file.exists())) {
      file.create();
    }

    // Open the file in append mode and write the text
    IOSink sink = file.openWrite(mode: FileMode.append);  // IOSink provides a way to write data to a file
    sink.write(text);
    await sink.flush();
    await sink.close();
  }

  static Future<String> readFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      String text = await file.readAsString();
      return text;
    } catch (e) {
      return ''; // Handle error
    }
  }

  // Delete a file if it exists
  static Future<void> deleteFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    // Check if the file exists
    if (!(await file.exists())) {
      return;
    }

    await file.delete();
  }

  static void startAccelerometerListening(void Function(AccelerometerEvent event) onUpdate) {
    // '??=' -> only assign value to variable if it is null
    _accelerometerSubscription ??=
        accelerometerEventStream(samplingPeriod: SensorInterval.normalInterval).listen((AccelerometerEvent event) async {
          onUpdate(event);

          String output = 'Accelerometer: ' +
              event.x.toString() + ', ' + event.y.toString() + ', ' + event.z.toString() + '\n';
          appendToFile('accelerometer_log', output);
          //String fileContent = await readFile('accelerometer_log');
          //print(fileContent);

        });
  }

  static void stopAccelerometerListening() {
    if (_accelerometerSubscription != null)  // If the sensor was used
      addFileToCache('accelerometer_log');
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  static void startGyroscopeListening(void Function(GyroscopeEvent event) onUpdate) {
    _gyroscopeSubscription ??=
        gyroscopeEventStream().listen((GyroscopeEvent event) {
          onUpdate(event);

          String output = 'Gyroscope: ' +
              event.x.toString() + ', ' + event.y.toString() + ', ' + event.z.toString() + '\n';
          appendToFile('gyroscope_log', output);
        });
  }

  static void stopGyroscopeListening() {
    if (_gyroscopeSubscription != null)  // If the sensor was used
      addFileToCache('gyroscope_log');
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;
  }

  static void startUserAccelerometerListening(void Function(UserAccelerometerEvent event) onUpdate) {
    _userAccelerometerSubscription ??= userAccelerometerEventStream().listen((event) {
      onUpdate(event);

      String output = 'UserAccelerometer: ' +
          event.x.toString() + ', ' + event.y.toString() + ', ' + event.z.toString() + '\n';
      appendToFile('user_accelerometer_log', output);
    });
  }

  static void stopUserAccelerometerListening() {
    if (_userAccelerometerSubscription != null)  // If the sensor was used
      addFileToCache('user_accelerometer_log');
    _userAccelerometerSubscription?.cancel();
    _userAccelerometerSubscription = null;
  }

  static void startMagnetometerListening(void Function(MagnetometerEvent event) onUpdate) {
    _magnetometerSubscription ??= magnetometerEventStream().listen((event) {
      onUpdate(event);

      String output = 'Magnetometer: ' +
          event.x.toString() + ', ' + event.y.toString() + ', ' + event.z.toString() + '\n';
      appendToFile('magnetometer_log', output);
    });
  }

  static void stopMagnetometerListening() {
    if (_magnetometerSubscription != null)  // If the sensor was used
      addFileToCache('magnetometer_log');
    _magnetometerSubscription?.cancel();
    _magnetometerSubscription = null;
  }

  static void startProximityListening(void Function(all_sensors.ProximityEvent event) onUpdate) {
    _proximitySubscription ??= all_sensors.proximityEvents?.listen((event) {
      onUpdate(event);
    });
  }

  static void stopProximityListening() {
    _proximitySubscription?.cancel();
    _proximitySubscription = null;
  }
/*
  static Future<void> uploadFile(String fileName) async {
    try {
      print('Upload File Engaged!');
      // Get the file from device
      String filesBasePath = '/data/user/0/com.mosaic.koios_log/app_flutter/';
      File file = File(filesBasePath + fileName);

      // Call the uploadFile function from the RestAPI
      KoiosResponse response = await koiosAPIClient.uploadFile(file);

      //print('Response Code: ' + response.code.toString());

      if (response.code == 0) {
        print('File uploaded successfully');
      } else {
        print('Failed to upload file');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }
*/

}