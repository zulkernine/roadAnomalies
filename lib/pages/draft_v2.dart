import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/components/my_appbar_v2.dart';
import 'package:roadanomalies_root/components/my_drawer.dart';
import 'package:roadanomalies_root/components/recorded_video_list.dart';
import 'package:roadanomalies_root/styles.dart';

class DraftsV2 extends StatefulWidget {
  const DraftsV2({Key? key}) : super(key: key);

  @override
  State<DraftsV2> createState() => _DraftsV2State();
}

class _DraftsV2State extends State<DraftsV2> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: scaffoldBackgroundColor ,
            endDrawer: const MyDrawer(),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
                  return [
                    const SliverToBoxAdapter(child: MyAppBarV2("Clips")),
                    SliverToBoxAdapter(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.0)
                        ),
                        margin: const EdgeInsets.only(bottom: 18),
                        child:  TabBar(
                          indicator: BoxDecoration(
                              color: grey1,
                              borderRadius:  BorderRadius.circular(12.0)
                          ) ,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black,
                          labelStyle: txtStl18w600,
                          tabs: const  [
                            Tab(text: 'Recorded',),
                            Tab(text: 'Uploaded',)
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body:  const TabBarView(
                  children:  [
                    RecordedVideoList(),
                    Text("Status Pages")
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
