import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../BottomNav.dart';
import '../../env.dart';
import '../mainMyPage.dart';
import '../../../chatting/servicechatting.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatHistory extends StatelessWidget {
  int getCount = 0;
  var tempJson = [];
  var deleteList = [];
  SharedPreferences pref;

  String token = '';
  int receiver_id = 0;
  String info = "";

  ChatHistory() {}

  Future<void> initialize() async {


    pref = await SharedPreferences.getInstance();
    token = pref.getString('token');

    final appJson = await http.post(Uri.parse(serverUrl + '/api/getuserinfo'), headers: {'Authorization': token});
    if(appJson.statusCode==200) {
      receiver_id=json.decode(appJson.body)['user_id'];
    }
    debugPrint("Token = $token");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.black),
              shadowColor: Colors.transparent,
              backgroundColor: myGreyColor,
              title: Text("我的>联系客服", style: TextStyle(color: Colors.black)),
              leading: GestureDetector(
                child: Icon(Icons.arrow_back, size: 32.0),
                onTap: () => {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => mainMyPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  )
                },
              ),
              centerTitle: true,
            ),
            body: ServiceChatting(receiver: receiver_id.toString(), flag: false, info: token),
          );
        }
      },
    );
  }
}
