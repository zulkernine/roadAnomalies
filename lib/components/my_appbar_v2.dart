import 'package:flutter/material.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/styles.dart';

class MyAppBarV2 extends StatelessWidget {
  final String title;

  const MyAppBarV2(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 29),
      color: scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("JUSense",style: txtStl20w300,),
              Text(title,style: txtStl50w800,)
            ],
          )),
          Expanded(
            flex: 1,
              child: InkWell(
                onTap: (){
                  Scaffold.of(context).openDrawer();
                },
                child: const CircleAvatar(
                  radius: 23,
                  backgroundColor: white1,
                  backgroundImage: NetworkImage("https://picsum.photos/300"),
                  // child:  Text('M'),
                ),
              ))
        ],
      ),
    );
  }
}
