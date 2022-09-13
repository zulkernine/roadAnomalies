import 'dart:convert';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';

class AnomalyVideoData extends AnomalyData {

  late Map<String, LatLng> positions;

  AnomalyVideoData(File video, DateTime capturedAt, this.positions) : super(video, capturedAt);

  AnomalyVideoData.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    positions = {};
    for (MapEntry<String, dynamic> mpe
        in (jsonDecode(json["positions"]) as Map<String, dynamic>).entries) {
      positions[mpe.key] = LatLng.fromJson(mpe.value)!;
    }
  }

  @override
  Map<String, String> toJson() =>
      {...super.toJson(), "positions": jsonEncode(positions)};

  @override
  DataType getType() {
    return DataType.video;
  }
}
