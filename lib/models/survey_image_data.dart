
import 'package:roadanomalies_root/models/anomaly_image_data.dart';

class SurveyImageData extends AnomalyImageData{
  String? landmark;
  String possibleAnomaly;

  SurveyImageData(super.imageFile, super.capturedAt, super.position, super.locationName,this.possibleAnomaly,[this.landmark]);

  @override
  Map<String, String> toJson() => {
    ... super.toJson(),
    "landmark":landmark??"",
    "possibleAnomaly":possibleAnomaly
  };
}
