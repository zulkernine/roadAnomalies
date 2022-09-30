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
  late ChewieController chewieController;
  @override
  void initState() {
    super.initState();
    chewieController = ChewieController(
      videoPlayerController: widget.controller,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(backgroundColor: scaffoldBackgroundColor,iconTheme: IconThemeData(color: Colors.white),),
        body: Center(
          child: widget.controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child: Chewie(
                    controller: chewieController,
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    chewieController.dispose();
    widget.controller.pause();
  }
}
