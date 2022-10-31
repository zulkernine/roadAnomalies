import 'dart:convert';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';
import 'package:roadanomalies_root/models/location_descriptio.dart';

class AnomalyVideoData extends AnomalyData {
  late Map<String, LatLng> positions;
  final double distance;
  final int duration; // inMilliSeconds
  final LocationDescription startLocation;
  final LocationDescription destLocation;

  AnomalyVideoData(File video, DateTime capturedAt, this.positions,
      this.distance, this.startLocation, this.destLocation, this.duration)
      : super(video, capturedAt);

  AnomalyVideoData.fromJson(Map<String, dynamic> json)
      : distance = double.parse(json["distance"]),
       duration = json["duration"],
        startLocation = LocationDescription.fromJson(json["startLocation"]),
        destLocation = LocationDescription.fromJson(json["destLocation"]),
        super.fromJson(json) {
    positions = {};
    for (MapEntry<String, dynamic> mpe
        in (jsonDecode(json["positions"]) as Map<String, dynamic>).entries) {
      positions[mpe.key] = LatLng.fromJson(mpe.value)!;
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        "positions": jsonEncode(positions),
        "distance": distance.toString(),
        "startLocation": startLocation.toJson(),
        "destLocation": destLocation.toJson(),
        'duration': duration,
      };

  @override
  DataType getType() {
    return DataType.video;
  }
}
