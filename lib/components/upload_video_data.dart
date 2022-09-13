import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roadanomalies_root/components/video_player_page.dart';
import 'package:roadanomalies_root/models/anomaly_video_data.dart';
import 'package:roadanomalies_root/util/network_util.dart';

class UploadVideoCard extends StatefulWidget {
  final AnomalyVideoData anomalyData;
  final Function() deleteCurrentElement;
  const UploadVideoCard(
      {Key? key, required this.anomalyData, required this.deleteCurrentElement})
      : super(key: key);

  @override
  State<UploadVideoCard> createState() => _UploadVideoCardState();
}

class _UploadVideoCardState extends State<UploadVideoCard> {

  bool isUploading = false;
  double progress = 0;

  void uploadHandler() async {
    setState(() {
      isUploading = true;
    });

    try {
      bool success = await NetworkUtil.uploadVideoSingle(widget.anomalyData,onSendProgressCallback: (count,total){
        setState(() {
          progress = (count/total);
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? "Successfully uploaded!, this image will be deleted from local storage. "
            : "Failed to upload :("),
      ));

      if(success) widget.deleteCurrentElement();
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(flex: 1, child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                icon: const Icon(Icons.play_circle),
                iconSize: 64,
                onPressed: openVideoPage,
              ),
            )),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                        "Capture started at: ${widget.anomalyData.capturedAt}"),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        !isUploading
                            ? Expanded(
                            child: ElevatedButton(
                              onPressed: uploadHandler,
                              child: const Text("Upload"),
                            ))
                            : Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(width: 8,),
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
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: widget.deleteCurrentElement,
                          child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),),
                        )),
                      ],
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
