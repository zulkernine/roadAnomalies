import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/pages/anomalies_map.dart';
import 'package:roadanomalies_root/constants.dart';
import 'package:roadanomalies_root/pages/capture_image_v2.dart';
import 'package:roadanomalies_root/pages/recorded_media.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:roadanomalies_root/pages/home_v2.dart';
import 'package:roadanomalies_root/pages/signin.dart';
// import 'firebase_options.dart';
import 'package:roadanomalies_root/pages/signup.dart';
import 'package:roadanomalies_root/util/auth_util.dart';
import 'package:roadanomalies_root/util/storage_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageUtil.initialCheck();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  await Firebase.initializeApp();

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
    // _checkUser();
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

    bool b = AuthUtil.isLoggedIn();
    //v2
    return MaterialApp(
      title: 'Road Anomalies',
      theme: buildShrineTheme(),
      home: b ? const HomePageV2() : const SignUpPage(),
      // initialRoute: b ? RouteName.home : RouteName.signup,
      showSemanticsDebugger: false,
      routes: {
        RouteName.capture: (context) => CaptureImageV2(
              camera: widget.camera,
            ),
        RouteName.map: (context) => const AnomaliesMap(),
        RouteName.draft: (context) => const DraftsV2(),
        RouteName.signup: (context) => const SignUpPage(),
        RouteName.signin: (context) => const SignInPage(),
        RouteName.home: (context) => const HomePageV2(),
      },
    );

  }
}


