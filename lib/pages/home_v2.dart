import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/components/my_appbar_v2.dart';
import 'package:roadanomalies_root/components/my_drawer.dart';
import 'package:roadanomalies_root/constants.dart';
import 'package:roadanomalies_root/styles.dart';
import 'package:roadanomalies_root/util/auth_util.dart';
import 'package:roadanomalies_root/util/locaton_util.dart';
import 'package:roadanomalies_root/util/user_util.dart';

class HomePageV2 extends StatefulWidget {
  const HomePageV2({Key? key}) : super(key: key);

  @override
  State<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends State<HomePageV2> {
  String? locationName;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  User? user;

  @override
  void initState() {
    LocationUtil.getCurrentLocationName().then((value) => setState(() {
          locationName = value;
        }));
    user = AuthUtil.getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      drawer: const MyDrawer(),
      backgroundColor: scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: scaffoldBackgroundColor,
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello",
                              style: txtStl20w300,
                            ),
                            Text(
                              user?.displayName ?? "",
                              style: txtStl40w800,
                            )
                          ],
                        )),
                    Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                          child: const CircleAvatar(
                            radius: 23,
                            backgroundColor: white1,
                            backgroundImage:
                                NetworkImage("https://picsum.photos/300"),
                            // child:  Text('M'),
                          ),
                        ))
                  ],
                ),
              ),
              if (locationName != null)
                RichText(
                    text: TextSpan(children: [
                  TextSpan(text: "You're in ", style: txtStl20w400),
                  TextSpan(text: locationName!, style: txtStl20w700)
                ])),
              const SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      height: 118,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "24",
                            style: txtStl50w800Black,
                          ),
                          const Spacer(),
                          Text(
                            "Media Uploaded",
                            style: txtStl18w600Black,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      height: 118,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                "985",
                                style: txtStl50w800Black,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                  child: Text(
                                "Anomalies Identified",
                                style: txtStl18w600Black,
                                softWrap: true,
                                maxLines: 5,
                              ))
                            ],
                          ),
                          const Spacer(),
                          Text(
                            "Last detected on",
                            style: txtStl16w300Black,
                          ),
                          Text(
                            "Sep 24, 2022 06:40 PM",
                            style: txtStl16w300Black,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 19,
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Around You",
                          style: txtStl18w600Black,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          "13",
                          style: txtStl35w800Red,
                        ),
                        Text(
                          "Potholes",
                          style: txtStl18w600Black,
                        ),
                      ],
                    )),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "2",
                              style: txtStl30w800Black,
                            ),
                            const SizedBox(
                              width: 14,
                            ),
                            Text(
                              "Cracks",
                              style: txtStl18w600Black,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "8",
                              style: txtStl30w800Black,
                            ),
                            const SizedBox(
                              width: 14,
                            ),
                            Text(
                              "Manholes",
                              style: txtStl18w600Black,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "3",
                              style: txtStl30w800Black,
                            ),
                            const SizedBox(
                              width: 14,
                            ),
                            Text(
                              "Speed Break",
                              style: txtStl18w600Black,
                            )
                          ],
                        ),
                      ],
                    )),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              getButton("Start Data Collection", blue1, () {
                Navigator.pushNamed(context, "/capture");
              }),
              const SizedBox(
                height: 16,
              ),
              getButton("View Recorded Clips", blue2, () {
                Navigator.pushNamed(context, "/draft");
              }),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                height: 40,
                child: getButton("Logout", Colors.white, () async {
                  await AuthUtil.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      RouteName.signin, (Route<dynamic> route) => false);
                }, style: txtStl20w400Black, color: Colors.black),
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text(
                    "Version 2.1.0",
                    style: txtStl12w300,
                    maxLines: 2,
                    softWrap: true,
                  ),
                  Text(
                    "JUSense PotSpot",
                    style: txtStl12w300,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }

  Widget getButton(String text, Color backgroundColor, Function() onClick,
      {TextStyle? style, Color? color}) {
    return InkWell(
        onTap: onClick,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          height: 50,
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: Row(
            children: [
              Expanded(
                  child: Text(text, style: style ?? txtStl18w600, maxLines: 2)),
              Icon(
                Icons.arrow_forward_rounded,
                color: color ?? Colors.white,
                size: 40,
              )
            ],
          ),
        ));
  }
}
