import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:roadanomalies_root/models/anomaly_video_data.dart';
import 'package:roadanomalies_root/styles.dart';
import 'package:roadanomalies_root/util/common_utils.dart';
import 'package:roadanomalies_root/util/locaton_util.dart';
import '../models/anomaly_image_data.dart';

class CaptureImageV2 extends StatefulWidget {
  const CaptureImageV2({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;

  @override
  State<CaptureImageV2> createState() => _CaptureImageV2State();
}

class _CaptureImageV2State extends State<CaptureImageV2> {
  late NativeDeviceOrientationCommunicator nativeDeviceOrientationCommunicator;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  AnomalyImageData? lastImageAnomaly;
  bool isRecording = false;
  double traveledDistance = 0;
  DateTime captureStartedAt = DateTime.now();
  Map<String, LatLng> locationRecorded = {};
  LatLng? previousPosition;
  bool isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.max);
    _initializeControllerFuture = _controller.initialize();

    _onInitListenToSensors();

    //change orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _onInitListenToSensors() {
    // capture continuous location change, when user is recording
    Location().onLocationChanged.listen((LocationData curLoc) {
      final currentPosition = LatLng(curLoc.latitude!, curLoc.longitude!);
      if (isRecording && !_controller.value.isRecordingPaused) {
        locationRecorded[(curLoc.time ?? DateTime.now().millisecondsSinceEpoch)
            .toInt()
            .toString()] = currentPosition;
        if (previousPosition != null) {
          setState(() {
            traveledDistance +=
                LocationUtil.getDistance(previousPosition!, currentPosition);
            print("new traveled distance: $traveledDistance");
            previousPosition = currentPosition;
          });
        } else {
          setState(() {
            previousPosition = currentPosition;
          });
        }
      }
    });

    nativeDeviceOrientationCommunicator = NativeDeviceOrientationCommunicator();
    // nativeDeviceOrientationCommunicator
    //     .onOrientationChanged(useSensor: true)
    //     .listen((orientation) {
    //   if ((orientation == NativeDeviceOrientation.portraitDown ||
    //       orientation == NativeDeviceOrientation.portraitUp) && isRecording) {
    //     // handleRecording();
    //     //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     //     handleRecording();
    //     //   });
    //   }
    // });

    // accelerometerEvents.listen((AccelerometerEvent event) {
    //   print(event);
    // });
    //
    // userAccelerometerEvents.listen((UserAccelerometerEvent event) {
    //   print(event);
    // });
    //
    // gyroscopeEvents.listen((GyroscopeEvent event) {
    //   print(event);
    // });
    //
    // magnetometerEvents.listen((MagnetometerEvent event) {
    //   print(event);
    // });
  }

  @override
  void dispose() {
    _controller.dispose();

    // change orientation back to default
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void handlePause() async {
    try{
      if (_controller.value.isRecordingVideo) {
        if (_controller.value.isRecordingPaused) {
          await _controller.resumeVideoRecording();
          setState(() {});
        } else {
          await _controller.pauseVideoRecording();
          setState(() {});
        }
      }
    }catch(e){
      print(e);
    }

  }

  void handleRecording() async {
    if (isRecording) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Saving the video..."),
      ));

      final file = await _controller.stopVideoRecording();
      final distance = traveledDistance;
      setState(() {
        isRecording = false;
        traveledDistance = 0;
      });

      //add current location to the list
      final curLoc = await Location.instance.getLocation();
      final currentPosition = LatLng(curLoc.latitude!, curLoc.longitude!);

      locationRecorded[(DateTime.now())
          .millisecondsSinceEpoch
          .toInt()
          .toString()] = currentPosition;

      //save video
      AnomalyVideoData data = await CommonUtils.addVideoToQueue(
          file, captureStartedAt, {...locationRecorded}, distance);
      print(data.toJson());
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Video successfully saved :)"),
      ));
      setState(() {
        /// clear the record, it should only contain while recording, once record stopped, all the
        /// data will be moved to create AnomalyVideoData
        locationRecorded.clear();
      });
    } else {
      await _controller.prepareForVideoRecording();
      await _controller.startVideoRecording();
      setState(() {
        isRecording = true;
      });

      // Add current location to the list
      final curLoc = await Location.instance.getLocation();
      captureStartedAt = DateTime.now();
      final currentPosition = LatLng(curLoc.latitude!, curLoc.longitude!);
      locationRecorded[captureStartedAt.millisecondsSinceEpoch
          .toInt()
          .toString()] = currentPosition;
    }
  }

  void handleCapture() async {
    setState(() {
      isProcessingImage = true;
    });
    try {
      final image = await _controller.takePicture();
      var loc = await Location().getLocation();
      await CommonUtils.addImageToQueue(image, loc);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Image saved successfully :)"),
      ));
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    } finally {
      setState(() {
        isProcessingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    late String distancestr;
    if (traveledDistance > 1000) {
      distancestr = "${traveledDistance / 1000} kms";
    } else {
      distancestr = "$traveledDistance m";
    }

    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final size = MediaQuery.of(context).size;
            final deviceRatio = size.width / size.height;

            return Stack(alignment: AlignmentDirectional.centerEnd, children: [
              AspectRatio(
                aspectRatio: deviceRatio,
                child: CameraPreview(_controller),
              ),
              Container(
                height: size.height,
                color: Colors.transparent,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 26, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12))),
                          child: Text(
                            distancestr,
                            style: txtStl16w300,
                          ),
                        ),
                        const SizedBox(
                          width: 236,
                        ),
                        RecordedTime(
                          isRecording: isRecording,
                          pause: _controller.value.isRecordingPaused,
                        ),
                      ],
                    ),
                    if (isRecording)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: handlePause,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                      color: Colors.white,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                _controller.value.isRecordingPaused ? 'Resume' : 'Pause',
                                style: txtStl14w400,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 42,
                          )
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: handleRecording,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 30),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(50)),
                            child: Text(
                              !isRecording ? 'START' : 'STOP',
                              style: txtStl16w700,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 42,
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: isProcessingImage ? null : handleCapture,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                    color: Colors.white.withOpacity(
                                        isProcessingImage ? 0.5 : 1),
                                    width: 1),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              'Capture',
                              style: txtStl14w400.copyWith(
                                  color: Colors.white.withOpacity(
                                      isProcessingImage ? 0.5 : 1)),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 42,
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Exit",
                              style: txtStl16w700,
                            )),
                        const SizedBox(
                          width: 42,
                        )
                      ],
                    ),
                  ],
                ),
              )
            ]);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class RecordedTime extends StatefulWidget {
  final bool isRecording;
  final bool pause;

  const RecordedTime({Key? key, required this.isRecording, required this.pause})
      : super(key: key);

  @override
  State<RecordedTime> createState() => _RecordedTimeState();
}

class _RecordedTimeState extends State<RecordedTime> {
  late Stopwatch stopwatch;
  String _timeString = "00:00:00";
  Timer? t;

  @override
  void initState() {
    stopwatch = Stopwatch();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RecordedTime oldWidget) {
    if (oldWidget.isRecording != widget.isRecording) {
      if (widget.isRecording) {
        stopwatch.start();
        t = Timer.periodic(
            const Duration(seconds: 1), (Timer t) => _getTime(t));
      } else {
        t?.cancel();
        stopwatch.stop();
        stopwatch.reset();
        _timeString = "00:00:00";
      }
    } else if (oldWidget.pause && !widget.pause) {
      stopwatch.start();
    } else if (widget.pause && !oldWidget.pause) {
      stopwatch.stop();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  void _getTime(Timer t) {
    if (widget.pause) return;

    final Duration d = stopwatch.elapsed;

    final String formattedDateTime = _printDuration(d);
    setState(() {
      this.t = t;
      _timeString = formattedDateTime;
    });
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Row(
        children: [
          if (widget.isRecording)
            Lottie.asset(
              'assets/recording_animation.json',
              width: 16,
              height: 16,
              fit: BoxFit.fill,
            ),
          const SizedBox(
            width: 8,
          ),
          Text(
            _timeString,
            style: txtStl16w300,
          ),
        ],
      ),
    );
  }
}
