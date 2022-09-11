import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';
import 'package:roadanomalies_root/util/storage_util.dart';

class HttpClient {
  final Dio dio;

  /// Singleton pattern - always return same instance!
  static final HttpClient _singleton = HttpClient._internal();
  factory HttpClient() {
    return _singleton;
  }
  HttpClient._internal()
      : dio = Dio(BaseOptions(baseUrl: "http://44.204.57.99:3000"));
}

class NetworkUtil {
  static HttpClient client = HttpClient();

  static Future<bool> uploadSingle(AnomalyData anomaly) async {
    try {
      Map<String, dynamic> data = {};
      data["latitude"] = anomaly.position.latitude.toString();
      data["longitude"] = anomaly.position.longitude.toString();
      data["capturedAt"] = anomaly.capturedAt.millisecondsSinceEpoch.toString();
      data["photo"] = MultipartFile(
          anomaly.imageFile.openRead(), await anomaly.imageFile.length(),
          filename: basename(anomaly.imageFile.path));

      Response response = await client.dio.post("/single",
          data: FormData.fromMap(data),
          options: Options(contentType: 'multipart/form-data'));
      if (kDebugMode) {
        print(response.data);
      }

      return true;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return false;
  }

  static Future<bool> uploadBatch(List<AnomalyData> anomalies,
      {CancelToken? token, Function(int, int)? onSendProgressCallback}) async {
    try {
      List<Map<String, dynamic>> dataList = [];

      for (AnomalyData anomaly in anomalies) {
        String fileName = basename(anomaly.imageFile.path);

        Map<String, dynamic> data = {};
        data["latitude"] = anomaly.position.latitude.toString();
        data["longitude"] = anomaly.position.longitude.toString();
        data["capturedAt"] =
            anomaly.capturedAt.millisecondsSinceEpoch.toString();
        data["fileName"] = fileName;

        dataList.add(data);
      }

      FormData formData = FormData.fromMap({"metadata": jsonEncode(dataList)});

      for (var anomaly in anomalies) {
        String fileName = basename(anomaly.imageFile.path);
        formData.files.add(MapEntry(
            "photo",
            MultipartFile(
                anomaly.imageFile.openRead(), await anomaly.imageFile.length(),
                filename: fileName)));
      }

      Response response = await client.dio.post("/multiple",
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
          cancelToken: token,
          onSendProgress: onSendProgressCallback);

      if (kDebugMode) {
        print(response.data);
      }

      if(response.statusCode!=null && response.statusCode!>=200 && response.statusCode!<300){
        await LocalStorageUtil.deleteAll();
        return true;
      }else{
        return false;
      }
    } catch (e) {
      if (kDebugMode) print(e.toString() + "\n" + ((e as DioError).response?.data.toString()??""));
    }
    return false;
  }
}
