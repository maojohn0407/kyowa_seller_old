import 'package:flutter/material.dart';
import 'package:client/chatting/audio_element.dart';
import 'dart:core';
import 'text_element.dart';
import 'image_element.dart';

class ChatElement extends StatelessWidget {
  final Map<dynamic, dynamic> chat_detail;
  final String receiver_id;
  final String sender_id;
  final dynamic isGroup;
  ChatElement({Key key, this.chat_detail, this.sender_id, this.receiver_id, this.isGroup})
      : super(key: key);

  Widget build(BuildContext context) {
    DateTime start = DateTime.parse(chat_detail['datetime']).toLocal();
    DateTime end =
        isGroup == null ? null : DateTime.parse(isGroup['datetime']).toLocal();
    bool tflag = end == null ? false : is_group(start, end);
    bool flag = end == null
        ? false
        : tflag &&
            isGroup['sender_id'] == chat_detail['sender_id'] &&
            start.hour.compareTo(end.hour) == 0 &&
            start.minute.compareTo(end.minute) == 0;
    String title = chat_detail['message'].toString().split('/')[0];
    final regex = RegExp(r'^chat-\w+\.mp3$');

    if (regex.hasMatch(title)) {
      return AudioElement(
          data: chat_detail,
          receiver_id: receiver_id,
          sender_id: sender_id,
          isGroup: tflag,
          isNew: flag);
    } else if (title == 'audio') {
      chat_detail['message'] = chat_detail['message'].toString().split('/')[1];
      return AudioElement(
          data: chat_detail,
          receiver_id: receiver_id,
          sender_id: sender_id,
          isGroup: tflag,
          isNew: flag);
    } else {
      if (title != 'image' && title != 'video') {
        return TextElement(
            data: chat_detail,
            receiver_id: receiver_id,
            sender_id: sender_id,
            isGroup: tflag,
            isNew: flag);
      } else {
        return ImageElement(
            data: chat_detail,
            sender_id: sender_id,
            receiver_id: receiver_id,
            isGroup: tflag,
            isNew: flag);
      }
    }
  }
}

bool is_group(DateTime start, DateTime end) {
  return start.year.compareTo(end.year) == 0 &&
      start.month.compareTo(end.month) == 0 &&
      start.day.compareTo(end.day) == 0;
}
