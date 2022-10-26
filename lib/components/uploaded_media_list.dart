import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roadanomalies_root/components/history_image_card.dart';
import 'package:roadanomalies_root/components/history_video_card.dart';
import 'package:roadanomalies_root/constants.dart';
import 'package:roadanomalies_root/models/server_models/base_model.dart';
import 'package:roadanomalies_root/models/server_models/image_dao.dart';
import 'package:roadanomalies_root/models/server_models/video_dao.dart';
import 'package:roadanomalies_root/util/auth_util.dart';
import 'package:roadanomalies_root/util/network_util.dart';

class UploadedMediaList extends StatefulWidget {
  const UploadedMediaList({Key? key}) : super(key: key);

  @override
  State<UploadedMediaList> createState() => _UploadedMediaListState();
}

class _UploadedMediaListState extends State<UploadedMediaList> {
  List<MediaDao> uploadedMedia = [];
  late bool isFetching;

  @override
  void initState() {
    isFetching = true;
    initAsync();
    super.initState();
  }

  Future initAsync() async {
    uploadedMedia = await NetworkUtil.getUploadedMedia();
    if (mounted) {
      setState(() {
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFetching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        var media = uploadedMedia[index];

        if (media.assetType == 'photo') {
          return HistoryImageCard(image: media as ImageDao);
        } else {
          return HistoryVideoCard(video: media as VideoDao);
        }
      },
      itemCount: uploadedMedia.length,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: 8,
        );
      },
    );
  }
}
