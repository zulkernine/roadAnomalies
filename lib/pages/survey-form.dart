import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/components/my_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadanomalies_root/models/anomaly_data.dart';
import 'package:roadanomalies_root/models/survey_image_data.dart';

import '../styles.dart';

class SurveyForm extends StatefulWidget {
  const SurveyForm({Key? key}) : super(key: key);

  @override
  State<SurveyForm> createState() => _SurveyFormState();
}

class _SurveyFormState extends State<SurveyForm> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _imagePicker = ImagePicker();
  final anomalies = ["Pothole", "Uneven Surface", "Speed Breaker", "Manhole"];
  File? imageFile;
  LatLng? location;
  String? landmark;
  late String anomaly;

  @override
  void initState() {
    anomaly = anomalies.first;
    super.initState();
  }

  void takePicture() async {
    XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    var loc = await Location().getLocation();
    if (image != null) {
      setState(() {
        imageFile = File(image.path);
        location = LatLng(loc.latitude!, loc.longitude!);
      });
    }
  }

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Survey",
                              style: txtStl20w300,
                            ),
                            Text(
                              "Form",
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
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Landmark",
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (text) {
                            setState(() {
                              landmark = text;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Take Image",
                              style: TextStyle(fontSize: 18),
                            ),
                            IconButton(
                                onPressed: takePicture,
                                icon: const Icon(Icons.camera_enhance_rounded))
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        if (imageFile != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Image.file(imageFile!),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Anomaly Type:",
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                                style: BorderStyle.solid, width: 0.80),
                          ),
                          child: DropdownButton<String>(
                            value: anomaly,
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            onChanged: (String? value) {
                              setState(() {
                                anomaly = value!;
                              });
                            },
                            items: anomalies
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Card(
                  child: TextButton(
                      onPressed: () {
                        SurveyImageData imageData = SurveyImageData(imageFile!,
                            DateTime.now(), location!, "NA", anomaly,landmark);
                        print("Anomaly logged: ${imageData.toJson()}");
                      },
                      child: Text("Submit",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 18))),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
