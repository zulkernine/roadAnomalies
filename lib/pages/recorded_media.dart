import 'package:disk_space/disk_space.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/components/my_appbar_v2.dart';
import 'package:roadanomalies_root/components/my_drawer.dart';
import 'package:roadanomalies_root/components/recorded_video_list.dart';
import 'package:roadanomalies_root/components/uploaded_media_list.dart';
import 'package:roadanomalies_root/styles.dart';

class DraftsV2 extends StatefulWidget {
  const DraftsV2({Key? key}) : super(key: key);

  @override
  State<DraftsV2> createState() => _DraftsV2State();
}

class _DraftsV2State extends State<DraftsV2> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: scaffoldBackgroundColor,
        endDrawer: const MyDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                    child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Recorded",
                                  style: txtStl20w300,
                                ),
                                Text(
                                  "Media",
                                  style: txtStl40w800,
                                )
                              ],
                            )),
                        InkWell(
                          onTap: () {
                            _scaffoldKey.currentState?.openEndDrawer();
                          },
                          child: const CircleAvatar(
                            radius: 23,
                            backgroundColor: white1,
                            backgroundImage:
                                NetworkImage("https://picsum.photos/300"),
                            // child:  Text('M'),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Rem. Storage",
                              style: txtStl16w300,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            FutureBuilder(
                                future: DiskSpace.getFreeDiskSpace,
                                builder: (ctx, snapshot) {
                                  if (snapshot.hasData) {
                                    print(snapshot.data);
                                    const mb = (1024);
                                    var freespace = (snapshot.data!) / mb;
                                    return Text(
                                      "${freespace.toStringAsPrecision(3)} GB",
                                      style: txtStl16w700,
                                    );
                                  }
                                  return const Text("Calculating...");
                                })
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )),
                SliverToBoxAdapter(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0)),
                    margin: const EdgeInsets.only(bottom: 18),
                    child: TabBar(
                      indicator: BoxDecoration(
                          color: blue1,
                          borderRadius: BorderRadius.circular(12.0)),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      labelStyle: txtStl18w600,
                      tabs: const [
                        Tab(
                          text: 'Recorded',
                        ),
                        Tab(
                          text: 'Uploaded',
                        )
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: const TabBarView(
              children: [RecordedVideoList(), UploadedMediaList()],
            ),
          ),
        ),
      ),
    ));
  }
}
