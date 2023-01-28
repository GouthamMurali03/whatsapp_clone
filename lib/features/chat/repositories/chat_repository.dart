import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/common/repositories/common_firebase_storage_repository.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/models/chat_contact.dart';
import 'package:whatsapp_ui/models/message.dart';
import 'package:whatsapp_ui/models/user_model.dart';
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
      firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

//

  void _saveDataToContactsSubCollection(
      UserModel senderUserData,
      UserModel recieverUserData,
      String textMessage,
      DateTime timeSent,
      String recieverUserId) async {
    //
    // users -> recieverUserId -> chats -> senderUserId -> setData
    var recieverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: textMessage);

    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(recieverChatContact.toMap());

    // users -> senderUserId -> chats -> recieverUserId -> setData

    var senderChatContact = ChatContact(
        name: recieverUserData.name,
        profilePic: recieverUserData.profilePic,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: textMessage);

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .set(senderChatContact.toMap());
  }

  // Save message to message subCollection

  void _saveMessageToMessageSubCollection(
      {required String recieverUserId,
      required String text,
      required DateTime timeSent,
      required String messageId,
      required String senderUserName,
      required String recieverUserName,
      required MessageEnum messageType}) async {
    // Initializing the massage as a model
    final message = Message(
        senderId: auth.currentUser!.uid,
        recieverId: recieverUserId,
        text: text,
        type: messageType,
        timeSent: timeSent,
        messageID: messageId,
        isSeen: false);

    // user --> senderId --> recieverId ---> messages --> messageId ---> store the Message
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    //
    // user --> recieverId --> senderId ---> messages --> messageId ---> store the Message
    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
  }

// The above two methods are incorporated inside this sendTextMessageMethod
  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel recieverUserData;
      var userDataMap =
          await firestore.collection('users').doc(recieverUserId).get();
      recieverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();

      // saveDataForcontactSubCollection
      _saveDataToContactsSubCollection(
          senderUser, recieverUserData, text, timeSent, recieverUserId);

      _saveMessageToMessageSubCollection(
          recieverUserId: recieverUserId,
          text: text,
          senderUserName: senderUser.name,
          recieverUserName: recieverUserData.name,
          messageType: MessageEnum.text,
          messageId: messageId,
          timeSent: timeSent);
    } catch (err) {
      showSnackBar(context, err.toString());
    }
  }

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots() // snapshots returns a stream
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());

        // We need user name and user ProfilePic

        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);
        contacts.add(ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage));
      }
      return contacts;
    });
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy('timeSent') //Here we are arranging by time sent
        .snapshots()
        .map((event) {
      List<Message> chatMessageList = [];
      for (var document in event.docs) {
        var chatMessage = Message.fromMap(document.data());
        chatMessageList.add(chatMessage);
      }

      return chatMessageList;
    });
  }

  void sendFileMessage(
      {required BuildContext context,
      required File file,
      required String recieverUserId,
      required UserModel senderUser,
      required ProviderRef ref,
      required MessageEnum messageEnum}) async {
    try {
      var timeSent = DateTime.now();
      String messageId = const Uuid().v1();
      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
              'chat/${messageEnum.type}/${senderUser.uid}/$recieverUserId/$messageId',
              file);

      var recieverUserMap =
          await firestore.collection('users').doc(recieverUserId).get();
      UserModel recieverUserData = UserModel.fromMap(recieverUserMap.data()!);

      String contactMsg;

      switch (messageEnum) {
        case (MessageEnum.image):
          contactMsg = '📸 Image';
          break;
        case (MessageEnum.video):
          contactMsg = '🎥 Video';
          break;
        case (MessageEnum.audio):
          contactMsg = '🔊 Audio';
          break;
        case (MessageEnum.gif):
          contactMsg = 'GIF';
          break;

        default:
          contactMsg = 'GIF';
      }

      _saveDataToContactsSubCollection(
          senderUser, recieverUserData, contactMsg, timeSent, recieverUserId);

      _saveMessageToMessageSubCollection(
          recieverUserId: recieverUserId,
          text: imageUrl,
          timeSent: timeSent,
          messageId: messageId,
          senderUserName: senderUser.name,
          recieverUserName: recieverUserData.name,
          messageType: messageEnum);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
