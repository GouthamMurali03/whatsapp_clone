
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  String videoUrl;
  VideoPlayerItem({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController? videoPlayerController;
  bool isPlaying = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        videoPlayerController!.setVolume(1);
      });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          VideoPlayer(videoPlayerController!),
          Align(
              alignment: Alignment.center,
              child: IconButton(
                  onPressed: () {
                    if (isPlaying) {
                      videoPlayerController!.pause();
                    } else {
                      videoPlayerController!.play();
                    }
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                  },
                  icon: isPlaying
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow))),
        ],
      ),
    );
  }
}
