import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/components/video_player_page.dart';
import 'package:roadanomalies_root/models/anomaly_video_data.dart';
import 'package:roadanomalies_root/styles.dart';
import 'package:roadanomalies_root/util/network_util.dart';

class UploadVideoCardV2 extends StatefulWidget {
  final AnomalyVideoData anomalyData;
  final Function() deleteCurrentElement;

  const UploadVideoCardV2(
      {Key? key, required this.anomalyData, required this.deleteCurrentElement})
      : super(key: key);

  @override
  State<UploadVideoCardV2> createState() => _UploadVideoCardV2State();
}

class _UploadVideoCardV2State extends State<UploadVideoCardV2> {
  bool isUploading = false;
  double progress = 0;

  void uploadHandler() async {
    setState(() {
      isUploading = true;
    });

    try {
      bool success = await NetworkUtil.uploadVideoSingle(widget.anomalyData,
          onSendProgressCallback: (count, total) {
        setState(() {
          progress = (count / total);
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? "Successfully uploaded!, this image will be deleted from local storage. "
            : "Failed to upload :("),
      ));

      if (success) widget.deleteCurrentElement();
    } catch (e) {
      if (kDebugMode) print(e);
    }

    setState(() {
      isUploading = false;
    });
  }

  void openVideoPage() {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return VideoPlayerPage(videoFile: widget.anomalyData.mediaFile);
    }));
  }

  String _getDate() {
    return DateFormat("d MMM, hh:mm aa").format(widget.anomalyData.capturedAt);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: openVideoPage,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getDate(),
                style: txtStl18w300Black,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                "${widget.anomalyData.distance} m",
                style: txtStl18w300Black,
              ),
              const SizedBox(
                width: 15,
              ),
              Row(
                children: [
                  !isUploading
                      ? Expanded(
                          child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          onPressed: uploadHandler,
                          child: const Text(
                            "Upload",
                            style: TextStyle(color: Colors.white),
                          ),
                        ))
                      : Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(
                                width: 8,
                              ),
                              Text("${progress.toInt()}%")
                            ],
                          ),
                        ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red1,
                    ),
                    onPressed: widget.deleteCurrentElement,
                    child: Text(
                      "Delete",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                  )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
