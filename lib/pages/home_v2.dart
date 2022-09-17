import 'package:flutter/material.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/components/my_appbar_v2.dart';
import 'package:roadanomalies_root/components/my_drawer.dart';
import 'package:roadanomalies_root/constants.dart';
import 'package:roadanomalies_root/styles.dart';
import 'package:roadanomalies_root/util/locaton_util.dart';
import 'package:roadanomalies_root/util/user_util.dart';

class HomePageV2 extends StatefulWidget {
  const HomePageV2({Key? key}) : super(key: key);

  @override
  State<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends State<HomePageV2> {
  String? locationName;

  @override
  void initState() {
    LocationUtil.getCurrentLocationName().then((value) => setState(() {
          locationName = value;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyAppBarV2(Contents.appName),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Hello ${UserUtil.getName()}",
                style: txtStl20w400,
              )),
          const SizedBox(
            height: 17,
          ),
          if (locationName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(text: "You're in", style: txtStl20w400),
                TextSpan(text: locationName!, style: txtStl20w700)
              ])),
            ),
          const SizedBox(
            height: 47,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: getButton("Start Data Collection", (){
              Navigator.pushNamed(context, "/capture");
            }),
          ),
          const SizedBox(
            height: 35,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: getButton("View Recorded Clips", (){
              Navigator.pushNamed(context, "/draft");
            }),
          ),
          const SizedBox(
            height: 120,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: Text(
                "Logout",
                style: txtStl20w700Black,
              ),
              onPressed: () {},
            ),
          )
        ],
      ),
    ));
  }

  Widget getButton(String text, Function() onClick) {
    return InkWell(
        onTap: onClick,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
              color: grey1,
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Row(
            children: [
              Expanded(child: Text(text, style: txtStl30w600, maxLines: 2)),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 40,
              )
            ],
          ),
        ));
  }
}
