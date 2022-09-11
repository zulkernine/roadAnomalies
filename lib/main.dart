import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:roadanomalies_root/pages/anomalies_map.dart';
import 'package:roadanomalies_root/pages/capture_image.dart';
import 'package:roadanomalies_root/constants.dart';
import 'package:roadanomalies_root/pages/drafts.dart';
import 'package:roadanomalies_root/pages/home.dart';
import 'package:location/location.dart';
import 'package:roadanomalies_root/util/storage_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageUtil.initialCheck();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(
    camera: firstCamera,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.camera});
  final CameraDescription camera;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _error;
  String _errorMessage = "Something went wrong!\nPlease restart the app";

  @override
  void initState() {
    super.initState();

    checkLocationPermission();
  }

  Future<void> checkLocationPermission() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _error = true;
          _errorMessage =
              "We can't Work without location service :(, Enable it, give permission and reopen the app.";
        });
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if(permissionGranted == PermissionStatus.granted){
      setState(() {
        _error = false;
      });
      return;
    } else if (permissionGranted == PermissionStatus.denied || permissionGranted == PermissionStatus.deniedForever) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _error = true;
          _errorMessage =
              "We can't Work without location service :(, Enable it, give permission and reopen the app.";
        });
      } else {
        setState(() {
          _error = false;
        });
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (_error == null) {
      return const MaterialApp(
        title: "Road Anomalies",
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_error!) {
      return MaterialApp(
        home: SafeArea(
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_errorMessage),
                  TextButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text("Give Permission"))
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Road Anomalies',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFFCEAE6),
      ),
      home:  const MyHomePage(title: 'Road Anomalies'),
      // initialRoute: '/',
      routes: {
        // '/': (context) => const MyHomePage(title: 'Road Anomalies'),
        RouteName.capture: (context) => CaptureImage(
              camera: widget.camera,
            ),
        RouteName.map: (context) => const AnomaliesMap(),
        RouteName.draft: (context) => const Drafts(),
      },
    );
  }
}
