import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';

class AnomalyImageData extends AnomalyData {
  final LatLng position;
  final String locationName;

  AnomalyImageData(
      File imageFile, DateTime capturedAt, this.position, this.locationName)
      : super(imageFile, capturedAt);

  AnomalyImageData.fromJson(Map<String, dynamic> json)
      : position = LatLng(
            double.parse(json["lati"]!), double.parse(json["long"]! as String)),
        locationName = json["locationName"],
        super.fromJson(json);

  @override
  Map<String, String> toJson() => {
        ...super.toJson(),
        "lati": position.latitude.toString(),
        "long": position.longitude.toString(),
        "locationName": locationName
      };

  @override
  DataType getType() {
    return DataType.image;
  }
}
