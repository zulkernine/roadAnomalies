class MediaDao{
  final String assetType;
  final String assetURL;
  final DateTime capturedAt;
  final bool isProcessed;

  MediaDao.fromJson(Map<String,dynamic> json):
        assetType = json["assetType"],
        assetURL = json['assetURL'],
        capturedAt = DateTime.fromMillisecondsSinceEpoch(int.parse(json['capturedAt'])),
        isProcessed = json['isProcessed'];
}