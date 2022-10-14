import 'package:flutter/material.dart';
import 'package:roadanomalies_root/components/upload_image_card.dart';
import 'package:roadanomalies_root/components/upload_video_card_v2.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';
import 'package:roadanomalies_root/models/anomaly_image_data.dart';
import 'package:roadanomalies_root/models/anomaly_video_data.dart';
import 'package:roadanomalies_root/styles.dart';
import 'package:roadanomalies_root/util/storage_util.dart';

class RecordedVideoList extends StatefulWidget {
  const RecordedVideoList({Key? key}) : super(key: key);

  @override
  State<RecordedVideoList> createState() => _RecordedVideoListState();
}

class _RecordedVideoListState extends State<RecordedVideoList> {
  List<AnomalyVideoData> localVideoAnomalies = [];
  List<AnomalyImageData> localImageAnomalies = [];

  @override
  void initState() {
    super.initState();
    updateLocalQueue();
  }

  Future<void> updateLocalQueue() async {
    var anomalies = await LocalStorageUtil.getAllAnomalies();
    setState(() {
      for (var data in anomalies) {
        if (data.getType() == DataType.video) {
          localVideoAnomalies.add(data as AnomalyVideoData);
        }else{
          localImageAnomalies.add(data as AnomalyImageData);
        }
      }
      localVideoAnomalies.sort((a,b)=>b.capturedAt.compareTo(a.capturedAt));
      localImageAnomalies.sort((a,b)=>b.capturedAt.compareTo(a.capturedAt));
    });
  }

  String onEmptyMessage(){
    if(localImageAnomalies.isEmpty && localVideoAnomalies.isEmpty) {
      return "You've no recorded or captured media saved.";
    } else if(localVideoAnomalies.isEmpty) {
      return "You've no saved video.";
    } else if(localImageAnomalies.isEmpty) {
      return "You've no saved images.";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (localVideoAnomalies.isNotEmpty)
            ...localVideoAnomalies
                .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: UploadVideoCardV2(
                        anomalyData: e,
                        deleteCurrentElement: () {
                          LocalStorageUtil.deleteAnomaly(
                              e.capturedAt.millisecondsSinceEpoch.toString());
                          setState(() {
                            localVideoAnomalies.remove(e);
                          });
                        },
                      ),
                ))
                .toList(),
          if (localImageAnomalies.isNotEmpty)
            ...localImageAnomalies
                .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: UploadImageCard(
                        anomalyData: e,
                        deleteCurrentElement: () {
                          LocalStorageUtil.deleteAnomaly(
                              e.capturedAt.millisecondsSinceEpoch.toString());
                          setState(() {
                            localImageAnomalies.remove(e);
                          });
                        },
                      ),
                ))
                .toList(),
            const SizedBox(height: 32,),
            Text(onEmptyMessage(),style: txtStl14w400,),

        ],
      ),
    );
  }
}
