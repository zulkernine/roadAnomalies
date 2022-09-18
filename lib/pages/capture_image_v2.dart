import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
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
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  AnomalyImageData? lastImageAnomaly;
  AnomalyVideoData? lastVideoAnomaly;
  bool isRecording = false;
  double traveledDistance = 0;
  DateTime captureStartedAt = DateTime.now();
  Map<String, LatLng> locationRecorded = {};
  LatLng? previousPosition;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();

    // capture continuous location change, when user is recording
    Location().onLocationChanged.listen((LocationData curLoc) {
      final currentPosition = LatLng(curLoc.latitude!, curLoc.longitude!);
      if (isRecording) {
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

    //change orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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

  void handleRecording() async {
    if (isRecording) {
      final file = await _controller.stopVideoRecording();
      setState(() => isRecording = false);

      //TODO save video
      AnomalyVideoData data = await CommonUtils.addVideoToQueue(
          file, captureStartedAt, {...locationRecorded}, traveledDistance);
      print(data.toJson());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Video successfully saved :)"),
      ));
      setState(() {
        lastVideoAnomaly = data;
        traveledDistance = 0;

        /// clear the record, it should only contain while recording, once record stopped, all the
        /// data will be moved to create AnomalyVideoData
        locationRecorded.clear();
      });
    } else {
      await _controller.prepareForVideoRecording();
      await _controller.startVideoRecording();
      setState(() {
        captureStartedAt = DateTime.now();
        isRecording = true;
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
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(12))),
                          child: Text(
                            distancestr,
                            style: txtStl16w300,
                          ),
                        ),
                        const SizedBox(width: 236,),
                        RecordedTime(isRecording: isRecording),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: handleRecording,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 30),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(50)
                            ),
                            child: Text(
                              !isRecording ? 'START' : 'STOP',
                              style: txtStl16w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 42,)
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
                        const SizedBox(width: 42,)
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

  const RecordedTime({Key? key, required this.isRecording}) : super(key: key);

  @override
  State<RecordedTime> createState() => _RecordedTimeState();
}

class _RecordedTimeState extends State<RecordedTime> {
  DateTime startTime = DateTime.now();
  String _timeString = "00:00:00";
  Timer? t;

  @override
  void didUpdateWidget(covariant RecordedTime oldWidget) {
    if (oldWidget.isRecording != widget.isRecording) {
      if (widget.isRecording) {
        startTime = DateTime.now();
        t = Timer.periodic(
            const Duration(seconds: 1), (Timer t) => _getTime(t));
      } else {
        t?.cancel();
        _timeString = "00:00:00";
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  void _getTime(Timer t) {
    final Duration d = DateTime.now().difference(startTime);
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
