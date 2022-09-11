import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';

class FullScreenViewImage extends StatelessWidget {
  final File image;
  final double height;
  const FullScreenViewImage({Key? key, required this.image,this.height = 150}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context,MaterialPageRoute(builder: (context){
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(),
              body: PhotoView(
                imageProvider: FileImage(image),
              ),
            ),
          );
        }));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        clipBehavior: Clip.hardEdge,
        child: Image.file(image,height: height,fit: BoxFit.fill,),
      ),
    );

  }
}


