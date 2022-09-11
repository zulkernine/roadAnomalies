import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class AnomalyData {
  final File imageFile;
  final DateTime capturedAt;
  final LatLng position;

  AnomalyData(this.imageFile, this.capturedAt, this.position);

  AnomalyData.fromJson(Map<String, dynamic> json)
      : imageFile = File(json["imagePath"]! as String),
        capturedAt =
            DateTime.fromMillisecondsSinceEpoch(int.parse(json["capturedAt"]! as String)),
        position =
            LatLng(double.parse(json["lati"]!), double.parse(json["long"]! as String));

  Map<String, String> toJson() => {
        "imagePath": imageFile.path,
        "capturedAt": capturedAt.millisecondsSinceEpoch.toString(),
        "lati": position.latitude.toString(),
        "long": position.longitude.toString()
      };
}
