enum MessageEnum {
  text('text'),
  image('image'),
  audio('audio'),
  video('video'),
  gif('gif');

// Enhanced enums

  const MessageEnum(this.type);
  final String type;
}

// Advanced enums were introduced in dart 2.17








// 
// The other method of achieving this is using extensions
// Use this if you don't have enhanced enums

extension ConvertMessageEnum on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'audio':
        return MessageEnum.audio;
      case 'video':
        return MessageEnum.video;
      case 'gif':
        return MessageEnum.gif;
      case 'image':
        return MessageEnum.image;
      case 'text':
        return MessageEnum.text;
      default:
        return MessageEnum.text;
    }
  }
}

extension ConvertString on MessageEnum {
  String toEnum() {
    switch (this) {
      case MessageEnum.audio:
        return 'audio';
      case MessageEnum.video:
        return 'video';
      case MessageEnum.gif:
        return 'gif';
      case MessageEnum.image:
        return 'image';
      case MessageEnum.text:
        return 'text';
      default:
        return 'text';
    }
  }
}
