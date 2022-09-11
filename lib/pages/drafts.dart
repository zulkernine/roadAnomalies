import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roadanomalies_root/components/my_drawer.dart';
import 'package:roadanomalies_root/components/upload_image_card.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';
import 'package:roadanomalies_root/util/network_util.dart';
import 'package:roadanomalies_root/util/storage_util.dart';

class Drafts extends StatefulWidget {
  const Drafts({Key? key}) : super(key: key);

  @override
  State<Drafts> createState() => _DraftsState();
}

class _DraftsState extends State<Drafts> {
  List<AnomalyData> localAnomalies = [];
  bool isUploadingAll = false;
  double progress = 0;
  final CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    updateLocalQueue();
  }

  Future<void> updateLocalQueue() async {
    var anomalies = await LocalStorageUtil.getAllAnomalies();
    setState(() {
      localAnomalies = anomalies;
    });
  }

  void batchUploadHandler() async {
    if (localAnomalies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("No pothole-images stored at local storage! Please take some"
                " picture of potholes to aware society and authority :)"),
      ));

      return;
    }

    setState(() {
      isUploadingAll = true;
    });
    try {
      bool success = await NetworkUtil.uploadBatch(localAnomalies,
          token: cancelToken, onSendProgressCallback: (int sent, int total) {
        setState(() {
          progress = sent / total;
          print("progress: $progress");
        });
      });

      if (success) updateLocalQueue();

      showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                content: Text(success
                    ? 'Hurray! All the images are uploaded! You can see your uploads in history section :)'
                    : "Failed to upload images. Please try again :("),
                actions: [
                  CupertinoDialogAction(
                    child: const Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
          barrierDismissible: true);
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      setState(() {
        isUploadingAll = false;
      });
    }
  }

  void onCancel() {
    cancelToken.cancel("User canceled the operation.");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      endDrawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Captured images"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "These images are yet to be uploaded. "
                "Already uploaded one will appear in history section.",
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(
                height: 16,
              ),
              !isUploadingAll
                  ? ElevatedButton(
                      onPressed: batchUploadHandler,
                      child: const Text("Upload All"),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: LinearProgressIndicator(
                        value: progress,
                      ),
                    ),
              if (isUploadingAll)
                ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Cancel"),
                ),
              const SizedBox(
                height: 16,
              ),
              if (localAnomalies.isNotEmpty)
                ...localAnomalies
                    .map((e) => UploadImageCard(
                          anomalyData: e,
                          showActionButton: !isUploadingAll,
                          deleteCurrentElement: () {
                            LocalStorageUtil.deleteAnomaly(
                                e.capturedAt.millisecondsSinceEpoch.toString());
                            setState(() {
                              localAnomalies.remove(e);
                            });
                          },
                        ))
                    .toList(),
            ],
          ),
        ),
      ),
    ));
  }
}
