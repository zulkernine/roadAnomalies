import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:roadanomalies_root/models/anomaly_image_data.dart';
import 'package:roadanomalies_root/models/anomaly_video_data.dart';
import 'package:roadanomalies_root/util/auth_util.dart';
import 'package:roadanomalies_root/util/storage_util.dart';
import 'package:video_player/video_player.dart';

class HttpClient {

  static const baseUrl = "http://107.23.192.116";

  static http.MultipartRequest getGETRequest(String path) =>
      http.MultipartRequest("GET", Uri.parse(baseUrl+path));

  static http.MultipartRequest getPOSTRequest(String path) =>
      http.MultipartRequest("POST", Uri.parse(baseUrl+path));

  final Dio dio;

  /// Singleton pattern - always return same instance!
  static final HttpClient _singleton = HttpClient._internal();

  factory HttpClient() {
    return _singleton;
  }

  HttpClient._internal()
      : dio = Dio(BaseOptions(baseUrl: "http://107.23.192.116"));
}

class NetworkUtil {
  static HttpClient client = HttpClient();

  static Future<bool> uploadSingle(AnomalyImageData anomaly) async {
    try {
      Map<String, dynamic> data = {};
      data["latitude"] = anomaly.position.latitude.toString();
      data["longitude"] = anomaly.position.longitude.toString();
      data["capturedAt"] = anomaly.capturedAt.millisecondsSinceEpoch.toString();
      data["photo"] = MultipartFile(
          anomaly.mediaFile.openRead(), await anomaly.mediaFile.length(),
          filename: basename(anomaly.mediaFile.path));

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

  static Future<bool> uploadBatch(List<AnomalyImageData> anomalies,
      {CancelToken? token, Function(int, int)? onSendProgressCallback}) async {
    try {
      List<Map<String, dynamic>> dataList = [];

      for (AnomalyImageData anomaly in anomalies) {
        String fileName = basename(anomaly.mediaFile.path);

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
        String fileName = basename(anomaly.mediaFile.path);
        formData.files.add(MapEntry(
            "photo",
            MultipartFile(
                anomaly.mediaFile.openRead(), await anomaly.mediaFile.length(),
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

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        await LocalStorageUtil.deleteAll();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode)
        print("$e\n${(e as DioError).response?.data.toString() ?? ""}");
    }
    return false;
  }

  static Future<bool> uploadVideoSingle(AnomalyVideoData anomaly,
      {Function(int, int)? onSendProgressCallback}) async {
    try {
      Map<String, dynamic> metadata = {};
      metadata["positions"] = {};
      metadata["capturedAt"] = anomaly.capturedAt.millisecondsSinceEpoch;
      for (var p in anomaly.positions.entries) {
        metadata["positions"][p.key] = {
          "latitude": p.value.latitude,
          "longitude": p.value.longitude
        };
      }
      var controller = VideoPlayerController.file(anomaly.mediaFile);
      await controller.initialize();
      metadata["duration"] = controller.value.duration.inMilliseconds;

      Map<String, dynamic> formData = {};
      formData["video"] = MultipartFile(
          anomaly.mediaFile.openRead(), await anomaly.mediaFile.length(),
          filename: basename(anomaly.mediaFile.path));
      formData["metadata"] = jsonEncode(metadata);

      if (kDebugMode) print("Video upload:\n$formData");
      if (kDebugMode) {
        print("uploading size: ${(await anomaly.mediaFile.length()) / 1000}");
      }

      Response response = await client.dio.post("/video/single",
          data: FormData.fromMap(formData),
          options: Options(contentType: 'multipart/form-data'),
          onSendProgress: onSendProgressCallback);
      if (kDebugMode) {
        print(response.data);
      }

      return true;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return false;
  }

  static Future<bool> uploadVideoHttp(AnomalyVideoData anomaly,
      {Function(int, int)? onSendProgressCallback}) async {
    try {
      Map<String, dynamic> metadata = {};
      metadata["positions"] = {};
      metadata["capturedAt"] = anomaly.capturedAt.millisecondsSinceEpoch;
      metadata["deviceId"] = await PlatformDeviceId.getDeviceId;
      metadata["userId"] = AuthUtil.getCurrentUser()?.uid;
      for (var p in anomaly.positions.entries) {
        metadata["positions"][p.key] = {
          "latitude": p.value.latitude,
          "longitude": p.value.longitude
        };
      }
      var controller = VideoPlayerController.file(anomaly.mediaFile);
      await controller.initialize();
      metadata["duration"] = controller.value.duration.inMilliseconds;

      var request = HttpClient.getPOSTRequest("/video/single")
        ..fields['metadata'] = jsonEncode(metadata)
        ..files.add(await http.MultipartFile.fromPath(
            "video", anomaly.mediaFile.path,
            contentType: MediaType('video', 'mp4')));

      print("making request");
      var response = await http.Response.fromStream(await request.send());
      print(response.statusCode);
      print(response.body);
      print(response.headers);
      if(response.statusCode >= 200 && response.statusCode <300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return false;
  }

  static Future<String> reverseGeoCode(LatLng location,
      {bool short = false}) async {
    try {
      var response = await client.dio.get("/geocode", queryParameters: {
        "lat": location.latitude,
        "lng": location.longitude,
        if (short) "short": 1
      });
      return (response.data as Map<String, dynamic>)["address"] as String;
    } catch (e) {
      print(e);
      return "";
    }
  }
}
