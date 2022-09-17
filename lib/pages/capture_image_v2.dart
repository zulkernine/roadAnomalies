import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
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
          });
        }
        previousPosition = currentPosition;
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
          file, captureStartedAt, {...locationRecorded},traveledDistance);
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
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final size = MediaQuery.of(context).size;
            final deviceRatio = size.width / size.height;
            final width2 = (213 / 926) * size.width;
            return Stack(alignment: AlignmentDirectional.centerEnd, children: [
              AspectRatio(
                aspectRatio: deviceRatio,
                child: CameraPreview(_controller),
              ),
              Container(
                height: size.height,
                decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12))),
                width: width2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Distance Travelled",
                            style: txtStl16w300,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            "$traveledDistance m",
                            style: txtStl16w700,
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: handleRecording,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                        ),
                        child: Text(
                          !isRecording ? 'START' : 'STOP',
                          style: txtStl16w700Black,
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Exit",
                            style: txtStl16w700,
                          ))
                    ],
                  ),
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

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;

  const _MediaSizeClipper(this.mediaSize);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
