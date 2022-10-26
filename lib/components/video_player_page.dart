import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:video_player/video_player.dart';

/// Stateful widget to fetch and then display video content.
class VideoPlayerPage extends StatefulWidget {
  final VideoPlayerController? controller;
  final String? videoUrl;

  const VideoPlayerPage({Key? key, this.controller, this.videoUrl})
      : assert(controller != null || videoUrl != null),
        super(key: key);

  @override
  VideoPlayerPageState createState() => VideoPlayerPageState();
}

class VideoPlayerPageState extends State<VideoPlayerPage> {
  ChewieController? chewieController;
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future initAsync() async {
    if (widget.controller == null) {
      controller =
          VideoPlayerController.network(widget.videoUrl!);
      await controller.initialize();

      setState(() {
        chewieController = ChewieController(
          videoPlayerController: controller,
          autoPlay: true,
          looping: true,
        );
      });
    } else {
      controller = widget.controller!;
      chewieController = ChewieController(
        videoPlayerController: widget.controller!,
        autoPlay: true,
        looping: true,
      );
    }
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
                aspectRatio: controller.value.aspectRatio,
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
    controller.dispose();
    chewieController?.dispose();
  }
}
