import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roadanomalies_root/components/full_screen_view_image.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';
import 'package:roadanomalies_root/util/network_util.dart';
import 'package:roadanomalies_root/util/storage_util.dart';

class UploadImageCard extends StatefulWidget {
  final AnomalyData anomalyData;
  final Function deleteCurrentElement;
  final bool showActionButton;
  const UploadImageCard(
      {Key? key,
      required this.anomalyData,
      required this.deleteCurrentElement,
      this.showActionButton = true})
      : super(key: key);

  @override
  State<UploadImageCard> createState() => _UploadImageCardState();
}

class _UploadImageCardState extends State<UploadImageCard> {
  bool isUploading = false;

  void deleteCurrentImage() {
    widget.deleteCurrentElement();
  }

  void uploadHandler() async {
    setState(() {
      isUploading = true;
    });

    try {
      bool success = await NetworkUtil.uploadSingle(widget.anomalyData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? "Successfully uploaded!, this image will be deleted from local storage. "
            : "Failed to upload :("),
      ));

      deleteCurrentImage();
    } catch (e) {
      if (kDebugMode) print(e);
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child:
                    FullScreenViewImage(image: widget.anomalyData.imageFile)),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text("Latitude: ${widget.anomalyData.position.latitude}"),
                    const SizedBox(
                      width: 12,
                    ),
                    Text("Longitude: ${widget.anomalyData.position.longitude}"),
                    const SizedBox(
                      height: 12,
                    ),
                    Text("Captured at: ${widget.anomalyData.capturedAt}"),
                    const SizedBox(
                      height: 12,
                    ),
                    widget.showActionButton
                        ? Row(
                            children: [
                              !isUploading
                                  ? Expanded(
                                      child: ElevatedButton(
                                      onPressed: uploadHandler,
                                      child: const Text("Upload"),
                                    ))
                                  : const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(),
                                    ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                  child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                ),
                                onPressed: deleteCurrentImage,
                                child: const Text("Delete"),
                              ))
                            ],
                          )
                        : const SizedBox(),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
