import 'package:flutter/material.dart';

Map<String, String> environment = {
  'token': '',
  'cart': 'cart',
  'qtyupdate': 'cart',
  'user_comment_confirm': 'commentconfirmbyuser',
  'user_comment_cancel': 'commentcancelbyuser',
  'admin_get_users': 'commentuserbyadmin',
  'admin_get_irregular': 'commentbyadmin',
  'admin_confirm_comment': 'commentconfirmbyadmin',
  'image_url': '/public/images/product/',
  'video_url': '/public/videos/product/',
  'news_image_url': '/public/images/news/',
  'news_video_url': '/public/videos/news/',
  'chat_video_url': '/public/videos/chat/',
  'chat_image_url': '/public/images/chat/',
  'chat_audio_url': '/public/audios/chat/',
  'delete': 'cart',
  'store': 'orders',
  'preorders': 'preorders',
  'chatter': 'chat/conversation',
  'createChat': 'chat/create',
  'textsend': '/chat/send/text',
  'imagesend': '/chat/send/image',
  'audiosend': '/chat/send/audio',
  'videosend': '/chat/send/video',
};

bool production = true;

String serverUrl = production ? 'http://54.199.96.191' : 'http://192.168.1.120/kyowa';

String dbBase = production ? 'production' : 'development';
String dbMessage = production ? 'messages' : 'devMessages';
String dbService = production ? 'services' : 'devServices';
String dbProduct = production ? 'products' : 'devProducts';

//Color list
Color myBlueColor = Color.fromRGBO(79, 129, 189, 1);
Color myGreyColor = Color.fromRGBO(217, 217, 217, 1);

String shortText(String text, int allowedLength) {
  if (text.length < allowedLength)
    return text;
  else
    return text.substring(0, allowedLength - 1) + '...';
}
