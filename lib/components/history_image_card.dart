import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/components/full_screen_view_image.dart';
import 'package:roadanomalies_root/models/server_models/image_dao.dart';
import 'package:roadanomalies_root/styles.dart';

class HistoryImageCard extends StatelessWidget {
  final ImageDao image;

  const HistoryImageCard({Key? key, required this.image}) : super(key: key);

  String getDate() {
    return DateFormat("d MMM, h:mm a").format(image.capturedAt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
              child: FullScreenViewImage(
                image: NetworkImage(image.assetURL),
                height: 100,
              )),
          const SizedBox(
            width: 12,
          ),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image.place,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    getDate(),
                    style: txtStl12w300Black,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Chip(
                    label: Text(
                      image.isProcessed ? "Processed" : "Not Processed",
                      style: txtStl16w300,
                    ),
                    backgroundColor: image.isProcessed ? blue1 : grey1,
                  )
                ],
              ))
        ],
      ),
    );
  }
}
