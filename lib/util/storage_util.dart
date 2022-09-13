import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';

class LocalStorageUtil {
  static Future<void> initialCheck() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      Directory media = Directory("${directory.path}/media/");
      if (!(await media.exists())) {
        // If images folder doesn't exist create it.
        await media.create(recursive: true);
      }

      File anomalies = await _getLocalAnomalyFile();
      if (!(await anomalies.exists())) {
        // If anomalies.json doesn't exist save empty array.
        saveAnomalies([]);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static Future<File> _getLocalAnomalyFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File("${directory.path}/anomalyData.json");
  }

  static Future<void> saveAnomalies(List<AnomalyData> data) async {
    var jsonList = data.map((e) => e.toJson()).toList();
    File file = await _getLocalAnomalyFile();

    await file.writeAsString(jsonEncode(jsonList), flush: true);
  }

  static Future<void> deleteAll() async {
    // delete media files
    await getAllAnomalies().then((value){
      for(var d in value) {
        d.mediaFile.delete();
      }
    });

    await saveAnomalies([]);
  }

  static Future<List<AnomalyData>> getAllAnomalies() async {
    File file = await _getLocalAnomalyFile();
    String contents = await file.readAsString();
    List<AnomalyData> anomalies = [];
    List jsonList = jsonDecode(contents);

    for (dynamic p in jsonList) {
      print(p);
      AnomalyData? anomaly = AnomalyData.getAnomalyFromJson(p);
      if (anomaly != null) {
        anomalies.add(anomaly);
      }
    }
    return anomalies;
  }

  static Future<void> addAnomaly(AnomalyData data) async {
    List<AnomalyData> anomalies = await getAllAnomalies();
    anomalies.add(data);
    await saveAnomalies(anomalies);
  }

  /// @capturedAt: millisecondsSinceEpoch
  static Future<void> deleteAnomaly(String capturedAt) async {
    List<AnomalyData> anomalies = await getAllAnomalies();
    AnomalyData data = anomalies.firstWhere(
        (e) => (e.capturedAt.millisecondsSinceEpoch.toString() == capturedAt));
    anomalies.remove(data);
    if (kDebugMode) print("Deleted: $anomalies");
    data.mediaFile.delete();
    await saveAnomalies(anomalies);
  }

  static Future<File> copyToDocumentDirectory(XFile file) async {
    final directory = await getApplicationDocumentsDirectory();

    // copy to document directory , safer
    File newFile =
        await File(file.path).copy("${directory.path}/media/${file.name}");
    await File(file.path).delete(); // delete old file (it was saved in temp dir
    return newFile;
  }
}
