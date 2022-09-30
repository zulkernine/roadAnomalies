import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:roadanomalies_root/models/anomaly_image_data.dart';
import 'package:roadanomalies_root/models/anomaly_video_data.dart';
import 'package:roadanomalies_root/util/network_util.dart';
import 'package:roadanomalies_root/util/storage_util.dart';

class CommonUtils{
  static Future<AnomalyImageData> addImageToQueue(XFile image,LocationData locationData)async{
    LatLng location = LatLng(locationData.latitude!, locationData.longitude!);
    File img = await LocalStorageUtil.copyToDocumentDirectory(image);
    AnomalyImageData anomaly = AnomalyImageData(img,DateTime.now(),location);
    await LocalStorageUtil.addAnomaly(anomaly);
    return anomaly;
  }

  static Future<AnomalyVideoData> addVideoToQueue(XFile video,DateTime captureStartAt,Map<String,LatLng> locations,double traveledDistance)async{
    File vid = await LocalStorageUtil.copyToDocumentDirectory(video);
    final start = await NetworkUtil.reverseGeoCode(locations.values.first);
    final dest = await NetworkUtil.reverseGeoCode(locations.values.last);
    AnomalyVideoData anomaly = AnomalyVideoData(vid,captureStartAt,locations,traveledDistance,start,dest);
    await LocalStorageUtil.addAnomaly(anomaly);
    return anomaly;
  }
}
