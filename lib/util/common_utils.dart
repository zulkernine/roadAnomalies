import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';
import 'package:roadanomalies_root/util/storage_util.dart';

class CommonUtils{
  static Future<void> addImageToQueue(XFile image,LocationData locationData)async{
    LatLng location = LatLng(locationData.latitude!, locationData.longitude!);
    File img = await LocalStorageUtil.copyToDocumentDirectory(image);

    await LocalStorageUtil.addAnomaly(AnomalyData(img,DateTime.now(),location));
  }
}
