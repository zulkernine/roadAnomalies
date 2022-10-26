import 'package:roadanomalies_root/models/server_models/base_model.dart';

class ImageDao extends MediaDao{
  final String place;

  ImageDao.fromJson(Map<String,dynamic> json) : place = json['location']["place"], super.fromJson(json);
}