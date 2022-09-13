import 'dart:io';

import 'package:roadanomalies_root/models/anomaly_image_data.dart';
import 'package:roadanomalies_root/models/anomaly_video_data.dart';

abstract class AnomalyData{
  final File mediaFile;
  final DateTime capturedAt;

  AnomalyData(this.mediaFile, this.capturedAt);

  AnomalyData.fromJson(Map<String, dynamic> json)
      : mediaFile = File(json["mediaPath"]! as String),
        capturedAt =
        DateTime.fromMillisecondsSinceEpoch(int.parse(json["capturedAt"]! as String));

  Map<String, String> toJson() => {
    "mediaPath": mediaFile.path,
    "capturedAt": capturedAt.millisecondsSinceEpoch.toString(),
    "type": getType().name,
  };

  DataType getType();

  static AnomalyData? getAnomalyFromJson(Map<String,dynamic> json){
    String type = (json["type"]! as String);
    switch(type){
      case "image":{
        return AnomalyImageData.fromJson(json);
      }
      case "video":{
        return AnomalyVideoData.fromJson(json);
      }
    }
    return null;
  }
}

enum DataType{
  image,video
}
