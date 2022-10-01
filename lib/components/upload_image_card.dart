import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/components/full_screen_view_image.dart';
import 'package:roadanomalies_root/models/anomaly_image_data.dart';
import 'package:roadanomalies_root/styles.dart';
import 'package:roadanomalies_root/util/network_util.dart';
import 'package:roadanomalies_root/util/storage_util.dart';

class UploadImageCard extends StatefulWidget {
  final AnomalyImageData anomalyData;
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

      if (success) deleteCurrentImage();
    } catch (e) {
      if (kDebugMode) print(e);
    }

    setState(() {
      isUploading = false;
    });
  }

  String getDate() {
    return DateFormat("d MMM, h:mm a").format(widget.anomalyData.capturedAt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
        padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child:
                  FullScreenViewImage(image: widget.anomalyData.mediaFile,height: 100,)),
          const SizedBox(
            width: 8,
          ),
          Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.anomalyData.locationName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    getDate(),
                    style: txtStl12w300Black,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  widget.showActionButton
                      ? Row(
                          children: [
                            !isUploading
                                ? Expanded(
                                    child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        visualDensity: VisualDensity.compact,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    onPressed: uploadHandler,
                                    child: const Text(
                                      "Upload",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ))
                                : const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(height: 14,width:14,child: CircularProgressIndicator(strokeWidth: 1,),),
                                  ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                                child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: red1,
                                  visualDensity: VisualDensity.compact,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8))),
                              onPressed: deleteCurrentImage,
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                              ),
                            ))
                          ],
                        )
                      : const SizedBox(),
                ],
              ))
        ],
      ),
    );
  }
}
