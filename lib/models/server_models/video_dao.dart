import 'package:roadanomalies_root/models/server_models/base_model.dart';

class VideoDao extends MediaDao{
  final String startedAt;
  final String endedAt;

  VideoDao.fromJson(Map<String,dynamic> json) :
      startedAt = json["startedAt"]["place"],
        endedAt = json["endedAt"]["place"],
        super.fromJson(json);
}