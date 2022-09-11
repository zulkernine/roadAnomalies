import 'package:flutter/material.dart';
import 'package:roadanomalies_root/constants.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('SignIn'),
          ),
          ListTile(
            title: const Text('Capture pothole'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteName.capture);
            },
          ),
          ListTile(
            title: const Text("Draft Images"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteName.draft);
            },
          ),
          ListTile(
            title: const Text("Previous Uploads"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteName.history);
            },
          ),
          ListTile(
            title: const Text("Map"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteName.map);
            },
          ),

        ],
      ),
    );
  }
}

