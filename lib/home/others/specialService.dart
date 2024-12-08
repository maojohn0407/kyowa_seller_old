import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../BottomNav.dart';
import '../shopping/mainHome.dart';

class specialService extends StatefulWidget {
  specialService({Key key}) : super(key: key);
  @override
  _specialServiceState createState() => _specialServiceState();
}

class _specialServiceState extends State<specialService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.arrow_back, size: 32.0),
            onTap: () => {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => mainHome(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              )
            },
          ),
          shadowColor: Colors.transparent,
          backgroundColor: myBlueColor,
          title: Container(
            alignment: Alignment(-0.24, 0),
            child: Text('特殊服务'),
          )),
      body: Text(''),
      bottomNavigationBar: BottomNav(
        pageName: 'home',
      ),
    );
  }
}
