import 'package:client/home/shopping/mainHome.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../env.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class splashPage extends StatefulWidget {
  @override
  _splashPageState createState() => _splashPageState();
}

class _splashPageState extends State<splashPage> {

  SharedPreferences pref;
  @override
  void initState() {
    super.initState();

    // FirebaseCrashlytics.instance.crash();
    _navigateToMainPage();
  }

  _navigateToMainPage() async {

    pref = await SharedPreferences.getInstance();
    String token = await pref.getString('token');
    if (token.isNotEmpty && token != '') {

      final appJson = await http.get(Uri.parse(serverUrl + '/api/userStatus'),
          headers: {'Authorization': token});
      if (appJson.statusCode == 200) {
        bool isVerfied = json.decode(appJson.body)['verified'] ?? false;
        int userId = json.decode(appJson.body)['userId'] ?? 0;
        await pref.setBool("VIPUser", isVerfied);
        await pref.setInt("userId", userId);
      } else if (appJson.statusCode == 400 || appJson.statusCode == 403) {
        pref.setString('token', '');
        pref.setBool("VIPUser", false);
        return;
      } else {
        await pref.setBool("VIPUser", false);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => mainHome()),
      );
    } else {
      await pref.setBool("VIPUser", false);
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              '购买需要输入地址信息，地址验证需要大约1小时～1天的时间，您现在要输入地址信息吗？',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        pref = await SharedPreferences.getInstance();
                        await pref.setBool('goAddress', true);
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text('现在输入地址'),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
                      },
                      child: Text('以后再说'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
