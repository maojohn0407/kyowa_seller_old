import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BottomNav.dart';
import '../home/shopping/mainHome.dart';
import '../mypage/addresss/addressList.dart';

class login extends StatefulWidget {
  login({Key key}) : super(key: key);
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  String email_text, password_text;
  loginPost(String email, password, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(serverUrl + '/api/login'),
        body: {'email': '${email}', 'password': '${password}'});
    var bodyData = json.decode(response.body);
    if (bodyData['message'] == 'Login Successful' && bodyData['type'] == 0) {
      prefs.setString('token', bodyData['token']);
      print('ok!login success');
      //to check the cartCount is really suitable number for the app.
      await http.get(Uri.parse(serverUrl + '/api/' + environment['cart']),
          headers: {
            'Authorization': bodyData['token']
          }).then((http.Response appJson) {
        if (appJson.statusCode == 200) {
          prefs.setInt(
              'cartCount',
              json.decode(appJson.body)['regular'].length +
                  json.decode(appJson.body)['irregular'].length);
        } else {
          prefs.setInt('cartCount', 0);
        }
      });
      bool goAddress = await prefs.getBool("goAddress");
      if (goAddress) {
        debugPrint("*** Go Addresss");
        prefs.setBool("goAddress", false);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                addressList(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        if (ModalRoute.of(context).settings.arguments == null)
          Navigator.popAndPushNamed(context, '/home');
        else
          Navigator.popAndPushNamed(
              context, ModalRoute.of(context).settings.arguments.toString());
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext Dialogcontext) {
            return AlertDialog(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("电子邮件或密码不正确。或不允许的用户。",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText2),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(Dialogcontext),
                              // color: myBlueColor,
                              child: Text('确定',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(color: Colors.white)),
                              style: TextButton.styleFrom(
                                backgroundColor: myBlueColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4.0),
                                    topRight: Radius.circular(4.0),
                                    bottomLeft: Radius.circular(4.0),
                                    bottomRight: Radius.circular(4.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))
                  ],
                ));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _emailController = TextEditingController(text: "");
    return Scaffold(
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
          backgroundColor: myBlueColor,
          shadowColor: Colors.transparent,
          title: Container(
            alignment: Alignment(-0.24, 0),
            child: Text('登录屏幕'),
          )),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 100, 30, 0),
        child: Column(
          children: [
            Text(
              """欢迎来到协和店。请输入。""",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: '密码@email.com',
                icon: Icon(
                  Icons.contact_mail,
                  color: Colors.red,
                ),
              ),
              onChanged: (value) => {
                email_text = value,
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String val) {
                return RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(_emailController.text)
                    ? null
                    : "确保您的电子邮件地址正确。";
              },
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '密码@密码',
                icon: Icon(
                  Icons.lock_outline,
                  color: Colors.red,
                ),
              ),
              onChanged: (value) => {
                password_text = value,
              },
            ),
            Container(
              margin: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    // color: myBlueColor,
                    onPressed: () => {
                      loginPost(email_text, password_text, context),
                    },
                    child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Text(
                            '加入',
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.login,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: myBlueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                          topRight: Radius.circular(4.0),
                          bottomLeft: Radius.circular(4.0),
                          bottomRight: Radius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 50),
                  TextButton(
                    // color: myBlueColor,
                    onPressed: () =>
                    {Navigator.popAndPushNamed(context, '/register')},
                    child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Text(
                            '登记',
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.supervised_user_circle,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: myBlueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                          topRight: Radius.circular(4.0),
                          bottomLeft: Radius.circular(4.0),
                          bottomRight: Radius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        pageName: 'sign',
      ),
    );
  }
}