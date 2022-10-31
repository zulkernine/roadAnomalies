import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:video_player/video_player.dart';

/// Stateful widget to fetch and then display video content.
class VideoPlayerPage extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoPlayerPage({Key? key, required this.controller}) : super(key: key);

  @override
  VideoPlayerPageState createState() => VideoPlayerPageState();
}

class VideoPlayerPageState extends State<VideoPlayerPage> {
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    initAsync();
  }



  Future initAsync() async {
    await widget.controller.initialize();
    setState(() {
      chewieController = ChewieController(
        videoPlayerController: widget.controller!,
        autoPlay: true,
        looping: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: scaffoldBackgroundColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: chewieController == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: Chewie(
                  controller: chewieController!,
                ),
              )),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.dispose();
    chewieController?.dispose();
  }
}
