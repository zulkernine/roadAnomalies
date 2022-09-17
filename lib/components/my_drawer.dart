import 'package:flutter/material.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/constants.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: scaffoldBackgroundColor,
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black45,
            ),
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white38,
                backgroundImage: NetworkImage("https://picsum.photos/300"),
                child: Text("M",style: TextStyle(fontSize: 60,color: Colors.white),),
              ),
            ),
          ),
          ListTile(
            title: const Text('Capture pothole',style: TextStyle(color: Colors.white),),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteName.capture);
            },
          ),
          ListTile(
            title: const Text("Draft Images",style: TextStyle(color: Colors.white),),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteName.draft);
            },
          ),
          ListTile(
            title: const Text("Previous Uploads",style: TextStyle(color: Colors.white),),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteName.history);
            },
          ),
          ListTile(
            title: const Text("Map",style: TextStyle(color: Colors.white),),
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

