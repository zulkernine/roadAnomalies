import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/components/video_player_page.dart';
import 'package:roadanomalies_root/models/anomaly_video_data.dart';
import 'package:roadanomalies_root/styles.dart';
import 'package:roadanomalies_root/util/network_util.dart';
import 'package:roadanomalies_root/util/storage_util.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

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
  bool isCompressing = false;
  double progress = 0;

  void uploadHandler() async {
    setState(() {
      isCompressing = true;
    });

    MediaInfo? mediaInfo;
    mediaInfo = await VideoCompress.compressVideo(
      widget.anomalyData.mediaFile.path,
      quality: VideoQuality.HighestQuality,
      deleteOrigin: false, // It's false by default
      includeAudio: false,
      frameRate: 5,
    );
    print("Compressed!");
    print(mediaInfo?.toJson());

    setState(() {
      widget.anomalyData.mediaFile = (mediaInfo?.file)!;
      isCompressing = false;
      isUploading = true;
    });

    try {
      bool success = await NetworkUtil.uploadVideoHttp(widget.anomalyData,
          onSendProgressCallback: (count, total) {
        setState(() {
          progress = (count / total);
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? "Successfully uploaded!, this video will be deleted from local storage. "
            : "Failed to upload :("),
      ));

      if (success) {
        widget.deleteCurrentElement();
        VideoCompress.deleteAllCache();
      }
    } catch (e) {
      if (kDebugMode) print(e);
      // delete previous one as it is compressed
      // LocalStorageUtil.deleteAnomaly(widget.anomalyData.capturedAt.millisecondsSinceEpoch.toString());
      // LocalStorageUtil.addAnomaly(widget.anomalyData);
    }

    setState(() {
      isUploading = false;
    });
  }

  void openVideoPage() {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return VideoPlayerPage(
        controller: VideoPlayerController.file(widget.anomalyData.mediaFile),
      );
    }));
  }

  String _getMonth() {
    return DateFormat("MMM").format(widget.anomalyData.capturedAt);
  }

  String _getTime() {
    return DateFormat("h:mm aa").format(widget.anomalyData.capturedAt);
  }

  String _getDistanceTraveled() {
    double d = widget.anomalyData.distance;
    if (d > 1000) {
      return "${(d / 1000).toStringAsPrecision(3)} kms";
    } else
      return "$d m";
  }

  String _getVideoDuration() {
    Duration duration = Duration(milliseconds: widget.anomalyData.duration);
    if (duration.inHours > 0) {
      return "${duration.inHours}H ${duration.inMinutes.remainder(60)}m ${(duration.inSeconds.remainder(60))}s";
    } else if (duration.inMinutes > 0) {
      return "${duration.inMinutes}m ${(duration.inSeconds)}s";
    }

    return "${(duration.inSeconds)}s";
  }

  String _getFileSize() {
    return "${widget.anomalyData.mediaFile.lengthSync() ~/ 1000000} MB";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: openVideoPage,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: grey2,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.anomalyData.capturedAt.day.toString(),
                              style: txtStl24w600Black,
                            ),
                            Text(
                              _getMonth(),
                              style: txtStl14w300Black,
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              _getTime(),
                              style: txtStl10w300Black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Text(
                      _getFileSize(),
                      style: txtStl12w300Black,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.anomalyData.startLocation.place,
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 1,
                          color: Colors.black,
                          height: 30,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        const Icon(
                          Icons.social_distance,
                          size: 14,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          _getDistanceTraveled(),
                          style: txtStl12w300Black,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        const Icon(
                          Icons.access_time,
                          size: 14,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          _getVideoDuration(),
                          style: txtStl12w300Black,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      widget.anomalyData.destLocation.place,
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: openVideoPage,
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(0),
                          ),
                          child: const Icon(Icons.play_arrow),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        getUploadButtonOrStatus(),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                            child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: red1,
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          onPressed: widget.deleteCurrentElement,
                          child: Text(
                            "Delete",
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                          ),
                        )),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getUploadButtonOrStatus() {
    if (isUploading) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              height: 8,
            ),
            Text(
              "Uploading",
              style: txtStl12w300Black,
            )
          ],
        ),
      );
    } else if (isCompressing) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              height: 8,
            ),
            Text(
              "Compressing",
              style: txtStl12w300Black,
            )
          ],
        ),
      );
    }

    return Expanded(
        child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      onPressed: uploadHandler,
      child: const Text(
        "Upload",
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    ));
  }
}
