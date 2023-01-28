import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/chat/controllers/chat_controller.dart';
import 'package:whatsapp_ui/features/chat/widgets/my_message_card.dart';
import 'package:whatsapp_ui/features/chat/widgets/sender_message_card.dart';
import 'package:whatsapp_ui/info.dart';
import 'package:whatsapp_ui/models/message.dart';
import 'package:intl/intl.dart';

class ChatList extends ConsumerStatefulWidget {
  final String recieverUid;
  const ChatList({required this.recieverUid, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    {
      return StreamBuilder<List<Message>>(
          stream: ref
              .watch(chatControllerProvider)
              .getChatStream(widget.recieverUid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }

            SchedulerBinding.instance.addPostFrameCallback((_) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            });
            return ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final messageData = snapshot.data![index];
                if (messageData.senderId != widget.recieverUid) {
                  return MyMessageCard(
                    message: messageData.text.toString(),
                    date: DateFormat.Hm().format(messageData.timeSent),
                    type: messageData.type,
                  );
                }
                return SenderMessageCard(
                  message: messageData.text.toString(),
                  date: DateFormat.Hm().format(messageData.timeSent),
                  type: messageData.type,
                );
              },
            );
          });
    }
  }
}
