// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/features/chat/widgets/video_player_item.dart';

class DisplayChatWidget extends StatelessWidget {
  final String message;
  final MessageEnum type;
  const DisplayChatWidget({
    Key? key,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();
    return type == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(
              fontSize: 16,
            ),
          )
        : type == MessageEnum.video
            ? VideoPlayerItem(videoUrl: message)
            : type == MessageEnum.audio
                ? StatefulBuilder(builder: (context, setState) {
                    return IconButton(
                        constraints: const BoxConstraints(minWidth: 100),
                        onPressed: () {
                          if (isPlaying) {
                            audioPlayer.pause();
                            setState(
                              () => isPlaying = false,
                            );
                          } else {
                            audioPlayer.play(UrlSource(message));
                            setState(
                              () => isPlaying = true,
                            );
                          }
                        },
                        icon: Icon(isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle));
                  })
                : CachedNetworkImage(imageUrl: message);
  }
}
