import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/components/video_player_page.dart';
import 'package:roadanomalies_root/models/server_models/video_dao.dart';
import 'package:roadanomalies_root/styles.dart';
import 'package:video_player/video_player.dart';

class HistoryVideoCard extends StatelessWidget {
  final VideoDao video;
  const HistoryVideoCard({Key? key, required this.video}) : super(key: key);

  void openVideoPage(context){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return VideoPlayerPage(
        controller: VideoPlayerController.network(video.assetURL),
      );
    }));
  }

  String _getMonth() {
    return DateFormat("MMM").format(video.capturedAt);
  }

  String _getTime() {
    return DateFormat("h:mm aa").format(video.capturedAt);
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openVideoPage(context),
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
                              video.capturedAt.day.toString(),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      video.startedAt,
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text("To",style: txtStl12w300Black,textAlign: TextAlign.center,),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      video.endedAt,
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: ()=>openVideoPage(context),
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
                        const SizedBox(width: 8,),
                        Chip(
                          label: Text(
                            video.isProcessed ? "Processed" : "Uploaded",
                            style: txtStl12w300,
                          ),
                          backgroundColor: video.isProcessed ? blue1 : grey1,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
