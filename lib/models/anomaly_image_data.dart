import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';

class AnomalyImageData extends AnomalyData{
  final LatLng position;

  AnomalyImageData(File imageFile, DateTime capturedAt, this.position) : super(imageFile, capturedAt);

  AnomalyImageData.fromJson(Map<String, dynamic> json)
      : position =
            LatLng(double.parse(json["lati"]!), double.parse(json["long"]! as String)),super.fromJson(json);

  @override
  Map<String, String> toJson() => {
        ...super.toJson(),
        "lati": position.latitude.toString(),
        "long": position.longitude.toString()
      };

  @override
  DataType getType() {
    return DataType.image;
  }
}
