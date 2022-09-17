import 'package:flutter/material.dart';
import 'package:roadanomalies_root/components/upload_video_card_v2.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';
import 'package:roadanomalies_root/models/anomaly_video_data.dart';
import 'package:roadanomalies_root/util/storage_util.dart';

class RecordedVideoList extends StatefulWidget {
  const RecordedVideoList({Key? key}) : super(key: key);

  @override
  State<RecordedVideoList> createState() => _RecordedVideoListState();
}

class _RecordedVideoListState extends State<RecordedVideoList> {
  List<AnomalyVideoData> localVideoAnomalies = [];

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
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (localVideoAnomalies.isNotEmpty)
            ...localVideoAnomalies
                .map((e) => UploadVideoCardV2(
                      anomalyData: e,
                      deleteCurrentElement: () {
                        LocalStorageUtil.deleteAnomaly(
                            e.capturedAt.millisecondsSinceEpoch.toString());
                        setState(() {
                          localVideoAnomalies.remove(e);
                        });
                      },
                    ))
                .toList()
          else
            const Text("You've not recorded any video yet.")
        ],
      ),
    );
  }
}
