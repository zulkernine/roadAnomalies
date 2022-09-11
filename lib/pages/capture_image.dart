import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:roadanomalies_root/components/my_drawer.dart';
import 'package:roadanomalies_root/components/upload_image_card.dart';
import 'package:roadanomalies_root/util/common_utils.dart';
import 'package:roadanomalies_root/util/storage_util.dart';

import '../models/anomaly_data.dart';

class CaptureImage extends StatefulWidget {
  const CaptureImage({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;

  @override
  State<CaptureImage> createState() => _CaptureImageState();
}

class _CaptureImageState extends State<CaptureImage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<AnomalyData> localAnomalies = [];

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera, create a CameraController.
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    updateLocalQueue();
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<void> updateLocalQueue() async {
    var anomalies = await LocalStorageUtil.getAllAnomalies();
    setState(() {
      localAnomalies = anomalies;
    });
  }

  void handleCapture() async {
    try {
      final image = await _controller.takePicture();
      var loc = await Location().getLocation();
      await CommonUtils.addImageToQueue(image, loc);
      await updateLocalQueue();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  void handleStreaming() async {}

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
                                onPressed: handleStreaming,
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20)),
                                child: const Text("Stream Image")),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (localAnomalies.isNotEmpty)
                      ...localAnomalies
                          .map((e) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: UploadImageCard(
                                  anomalyData: e,
                                  deleteCurrentElement: () {
                                    LocalStorageUtil.deleteAnomaly(e
                                        .capturedAt.millisecondsSinceEpoch
                                        .toString());
                                    setState(() {
                                      localAnomalies.remove(e);
                                    });
                                  },
                                ),
                              ))
                          .toList(),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                        "Only the latest image is shown here, please look into"
                        " draft/history page to see all your captures."), // Display all anomalies from local queue
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
