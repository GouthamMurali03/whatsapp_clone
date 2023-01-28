import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/chat/controllers/chat_controller.dart';

import '../../../colors.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class BottomChatTextField extends ConsumerStatefulWidget {
  final String recieverUserId;
  const BottomChatTextField({
    required this.recieverUserId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<BottomChatTextField> createState() =>
      _BottomChatTextFieldState();
}

class _BottomChatTextFieldState extends ConsumerState<BottomChatTextField> {
  bool isShowSendButton = false;
  final _messageController = TextEditingController();
  bool isShowEmoji = false;
  final FocusNode _messageFocus = FocusNode();
  FlutterSoundRecorder? _soundRecorder;
  bool isSoundRecorderInit = false;
  bool isRecording = false;

  void sendTextMessage() async {
    if (isShowSendButton) {
      ref.read(chatControllerProvider).sendTextMessage(
          context, _messageController.text.trim(), widget.recieverUserId);
      print(widget.recieverUserId);
      // Emptying the textfield after message is sent
      setState(() {
        _messageController.text = '';
      });
      _messageFocus.unfocus();
    } else {
      // Setting path for storing audio recording
      var tempDirectory = await getTemporaryDirectory();
      var path = '${tempDirectory.path}/flutter_sound.aac';
      // Send this path in the start recorder

      if (!isSoundRecorderInit) {
        return;
      }
      if (isRecording) {
        await _soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(toFile: path);
      }

      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void sendFileMessage(File file, MessageEnum messageEnum) {
    ref.read(chatControllerProvider).sendFileMessage(
        context: context,
        file: file,
        recieverUserId: widget.recieverUserId,
        messageEnum: messageEnum);
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  // void selectVideo() async {
  //   File? video = await pickVideoFromGallery(context);
  //   if (video != null) {
  //     sendFileMessage(video, MessageEnum.video);
  //   }
  // }

  void hideEmojiContainer() {
    setState(() {
      isShowEmoji = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmoji = true;
    });
  }

  void toggleBWKeyboardEmoji() {
    if (isShowEmoji) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  void hideKeyboard() => _messageFocus.unfocus();

  void showKeyboard() => _messageFocus.requestFocus();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic Permission allowed');
    }
    await _soundRecorder!.openRecorder();
    isSoundRecorderInit = true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageController.dispose();
    _soundRecorder!.closeRecorder();
    isSoundRecorderInit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
            child: TextFormField(
              focusNode: _messageFocus,
              controller: _messageController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    isShowSendButton = true;
                  });
                } else {
                  setState(() {
                    isShowSendButton = false;
                  });
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: mobileChatBoxColor,
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.gif,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                            onPressed: toggleBWKeyboardEmoji,
                            icon: const Icon(
                              Icons.emoji_emotions,
                              color: Colors.grey,
                            )),
                      ],
                    ),
                  ),
                ),
                suffixIcon: SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: selectImage,
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.attach_file,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                hintText: 'Type a message!',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 2, left: 2),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF128C7E),
              radius: 25,
              child: GestureDetector(
                child: Icon(
                  isShowSendButton
                      ? Icons.send
                      : isRecording
                          ? Icons.close
                          : Icons.mic,
                  color: Colors.white,
                ),
                onTap: sendTextMessage,
              ),
            ),
          )
        ]),
        isShowEmoji
            ? SizedBox(
                height: 210,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    setState(() {
                      _messageController.text += emoji.emoji;
                      if (!isShowSendButton) {
                        isShowSendButton = true;
                      }
                    });
                  },
                ),
              )
            : const SizedBox()
      ],
    );
  }
}
