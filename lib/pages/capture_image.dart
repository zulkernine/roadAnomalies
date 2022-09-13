import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:roadanomalies_root/components/my_drawer.dart';
import 'package:roadanomalies_root/components/upload_image_card.dart';
import 'package:roadanomalies_root/components/upload_video_data.dart';
import 'package:roadanomalies_root/models/anomaly_video_data.dart';
import 'package:roadanomalies_root/util/common_utils.dart';
import 'package:roadanomalies_root/util/storage_util.dart';

import '../models/anomaly_image_data.dart';

class CaptureImage extends StatefulWidget {
  const CaptureImage({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;

  @override
  State<CaptureImage> createState() => _CaptureImageState();
}

class _CaptureImageState extends State<CaptureImage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  AnomalyImageData? lastImageAnomaly;
  AnomalyVideoData? lastVideoAnomaly;
  bool isRecording = false;
  DateTime captureStartedAt = DateTime.now();
  Map<String, LatLng> locationRecorded = {};

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();

    // capture continuous location change, when user is recording
    Location().onLocationChanged.listen((LocationData curLoc) {
      if (isRecording) {
        locationRecorded[(curLoc.time ?? DateTime.now().millisecondsSinceEpoch)
            .toInt()
            .toString()] = LatLng(curLoc.latitude!, curLoc.longitude!);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Future<void> updateLocalQueue() async {
  //   var anomalies = await LocalStorageUtil.getAllAnomalies();
  //   setState(() {
  //     localAnomalies = anomalies;
  //   });
  // }

  void handleCapture() async {
    try {
      final image = await _controller.takePicture();
      var loc = await Location().getLocation();
      var data = await CommonUtils.addImageToQueue(image, loc);
      setState(() {
        lastImageAnomaly = data;
      });
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  void handleRecording() async {
    if (isRecording) {
      final file = await _controller.stopVideoRecording();
      setState(() => isRecording = false);

      //TODO save video
      AnomalyVideoData data = await CommonUtils.addVideoToQueue(
          file, captureStartedAt, {...locationRecorded});
      print(data.toJson());
      setState(() {
        lastVideoAnomaly = data;

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
    return SafeArea(
      child: Scaffold(
        endDrawer: const MyDrawer(),
        appBar: AppBar(
          title: const Text("Capture or Stream images"),
        ),
        body: SingleChildScrollView(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        margin: const EdgeInsets.all(16),
                        child: CameraPreview(_controller)),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                            onPressed: handleCapture,
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20)),
                            child: const Text("Take Image"),
                          )),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: ElevatedButton(
                                onPressed: handleRecording,
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20)),
                                child: Text(!isRecording
                                    ? "Start Recording"
                                    : "Stop Recording")),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (lastImageAnomaly != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: UploadImageCard(
                          anomalyData: lastImageAnomaly!,
                          deleteCurrentElement: () {
                            LocalStorageUtil.deleteAnomaly(lastImageAnomaly!
                                .capturedAt.millisecondsSinceEpoch
                                .toString());
                            setState(() {
                              lastImageAnomaly = null;
                            });
                          },
                        ),
                      ),
                    if (lastVideoAnomaly != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: UploadVideoCard(
                          anomalyData: lastVideoAnomaly!,
                          deleteCurrentElement: () {
                            LocalStorageUtil.deleteAnomaly(lastVideoAnomaly!
                                .capturedAt.millisecondsSinceEpoch
                                .toString());
                            setState(() {
                              lastVideoAnomaly = null;
                            });
                          },
                        ),
                      ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                          "Only the latest image is shown here, please look into"
                          " draft/history page to see all your captures."),
                    ), // Display all anomalies from local queue
                    const SizedBox(
                      height: 20,
                    ), // Display all anomalies from local queue
                  ],
                );
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
