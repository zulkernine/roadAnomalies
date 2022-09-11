import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';

class LocalStorageUtil {
  static Future<void> initialCheck()async{
    try{
      final directory = await getApplicationDocumentsDirectory();

      Directory images = Directory("${directory.path}/images/");
      if(!(await images.exists())){ // If images folder doesn't exist create it.
        await images.create(recursive: true);
      }

      File anomalies = await _getLocalAnomalyFile();
      if(!(await anomalies.exists())){ // If anomalies.json doesn't exist save empty array.
        saveAnomalies([]);
      }
    }catch(e){
      if(kDebugMode){
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

    await file.writeAsString(jsonEncode(jsonList),flush: true);
  }

  static Future<void> deleteAll()async{
    await saveAnomalies([]);
  }

  static Future<List<AnomalyData>> getAllAnomalies() async {
    File file = await _getLocalAnomalyFile();
    String contents = await file.readAsString();
    List<AnomalyData> anomalies = [];
    List jsonList = jsonDecode(contents);
    // List<Map<String,String>> jsonResponse = jsonList.map((e) => Map<String,String>e).toList();

    for (dynamic p in jsonList) {
      anomalies.add(AnomalyData.fromJson(p));
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
    anomalies.removeWhere((e) => (e.capturedAt.millisecondsSinceEpoch.toString() == capturedAt));
    print(anomalies);
    await saveAnomalies(anomalies);
  }

  static Future<File> copyToDocumentDirectory(XFile file) async {
    final directory = await getApplicationDocumentsDirectory();

    // copy to document directory , safer
    File newFile = await File(file.path).copy(
        "${directory.path}/images/${file.name}");
    await File(file.path).delete(); // delete old file (it was saved in temp dir
    return newFile;
  }
}
