import 'dart:core';
import 'package:flutter/material.dart';
import 'home/shopping/mainHome.dart';
import 'home/others/specialService.dart';
// import 'sign/login.dart';
import 'sign/smslogin.dart';
import 'sign/register.dart';
import 'cart/mainCart.dart';
import 'mypage/addresss/addressList.dart';
import 'mypage/chatHistory/histroy.dart';
import 'mypage/addresss/phoneValidate.dart';
import 'mypage/addresss/addressInput.dart';
import 'mypage/addresss/addressConfirm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mypage/favorite/favorite.dart';
import 'firebase_options.dart';
import 'mypage/orderHistory/orderHistoryList.dart';
import 'mypage/orderHistory/orderHistoryItem.dart';
import 'mypage/orderHistory/orderHistoryDetail.dart';
import 'mypage/mainMyPage.dart';
import 'splashPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '京和',
      initialRoute: '/splash',
      routes: {
        '/splash': (BuildContext ctx) => splashPage(), //first screen(Home)
        '/home': (BuildContext ctx) => mainHome(), //first screen(Home)
        '/cart': (BuildContext ctx) => mainCart(), //my bucket page
        '/myPage': (BuildContext ctx) => mainMyPage(), //first page of the my page
        '/addressList': (BuildContext ctx) => addressList(), //address list page
        '/chatHistory': (BuildContext ctx) => ChatHistory(), //chat history page
        '/phoneValidate': (BuildContext ctx) => phoneValidate(), //new phone number and validate page
        '/addressInput': (BuildContext ctx) => addressInput(), //address creating page
        '/addressConfirm': (BuildContext ctx) => addressConfirm(), //address edit page
        '/favorite': (BuildContext ctx) => favorite(), //favorite page
        '/orderHistoryList': (BuildContext ctx) => orderHistoryList(), //orderHistory's list
        '/orderHistoryItem': (BuildContext ctx) => orderHistoryItem(), //orderHistory's item
        '/orderHistoryDetail': (BuildContext ctx) => orderHistoryDetail(), //orderHistory's detail
        '/login': (BuildContext ctx) => Login(),
        '/register': (BuildContext ctx) => register(),
        '/specialService': (BuildContext ctx) => specialService(),
      },
    );
  }
}
