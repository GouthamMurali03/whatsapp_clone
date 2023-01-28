import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackBar(context, e.toString());
  }
  return image;
}

// Future<File?> pickVideoFromGallery(BuildContext context) async {
//   File? video;
//   try {
//     final pickedVideo =
//         await ImagePicker().pickVideo(source: ImageSource.gallery);
//     if (pickedVideo != null) {
//       video = File(pickedVideo.path);
//     }
//   } catch (e) {
//     showSnackBar(context, e.toString());
//   }
//   return video;
// }

// pickGif(BuildContext context) {
//   try {
//     Giphy.getGif(context: context, apiKey: apiKey)
//   } catch (e) {
//     showSnackBar(context, e.toString());
//   }
// }
