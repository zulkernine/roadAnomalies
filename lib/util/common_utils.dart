import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:roadanomalies_root/models/anomaly_image_data.dart';
import 'package:roadanomalies_root/models/anomaly_video_data.dart';
import 'package:roadanomalies_root/models/location_descriptio.dart';
import 'package:roadanomalies_root/util/network_util.dart';
import 'package:roadanomalies_root/util/storage_util.dart';
import 'package:video_player/video_player.dart';

class CommonUtils {
  static Future<AnomalyImageData> addImageToQueue(XFile image,
      LocationData locationData) async {
    LatLng location = LatLng(locationData.latitude!, locationData.longitude!);
    File img = await LocalStorageUtil.copyToDocumentDirectory(image);
    final locationName = await NetworkUtil.reverseGeoCode(location);
    AnomalyImageData anomaly = AnomalyImageData(
        img, DateTime.now(), location, locationName);
    await LocalStorageUtil.addAnomaly(anomaly);
    return anomaly;
  }

  static Future<AnomalyVideoData> addVideoToQueue(XFile video,
      DateTime captureStartAt, Map<String, LatLng> locations,
      double traveledDistance) async {

    // copy video to permanent directory
    File vid = await LocalStorageUtil.copyToDocumentDirectory(video);

    //get duration
    var controller = VideoPlayerController.file(vid);
    await controller.initialize();
    int duration = controller.value.duration.inMilliseconds;
    controller.dispose();

    //Get locations and there descriptions
    final startPlace = await NetworkUtil.reverseGeoCode(locations.values.first);
    final start = LocationDescription(
        locations.values.first.latitude, locations.values.first.longitude,
        startPlace);
    final endPlace = await NetworkUtil.reverseGeoCode(locations.values.last);
    final end = LocationDescription(
        locations.values.last.latitude, locations.values.last.longitude,
        endPlace);

    // create anomaly object
    AnomalyVideoData anomaly = AnomalyVideoData(
        vid, captureStartAt, locations, traveledDistance, start, end,duration);

    // save to local storage
    await LocalStorageUtil.addAnomaly(anomaly);
    return anomaly;
  }
}
