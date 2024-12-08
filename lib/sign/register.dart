import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../home/others/recommendPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../env.dart';
import '../BottomNav.dart';

class register extends StatefulWidget {
  register({Key key}) : super(key: key);
  @override
  _registerState createState() => _registerState();
}

class _registerState extends State<register> {
  SharedPreferences pref;
  String username = "", email = "", password = "";
  @override
  Widget build(BuildContext context) {
    TextEditingController _emailController = TextEditingController(text: "");
    return Scaffold(
      appBar: AppBar(
          backgroundColor: myBlueColor,
          shadowColor: Colors.transparent,
          title: Container(
            alignment: Alignment(-0.24, 0),
            child: Text('注册屏幕'),
          )),
//        drawer: Icon(Icons.navigate_before),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 100, 30, 0),
        child: Column(
          children: [
            Text(
              """请填写您的信息。""",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextField(
                decoration: InputDecoration(
                  labelText: '名字',
                  hintText: '名字',
                  icon: Icon(
                    Icons.person,
                    color: Colors.red,
                  ),
                ),
                onChanged: (String val) => {
                      username = val,
                    }),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: '您的@email.com',
                icon: Icon(
                  Icons.contact_mail,
                  color: Colors.red,
                ),
              ),
              onChanged: (value) => {
                email = value,
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String val) {
                return RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(_emailController.text)
                    ? null
                    : "确保您的电子邮件地址正确。";
              },
            ),
            TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '您的@密码',
                  icon: Icon(
                    Icons.lock_outline,
                    color: Colors.red,
                  ),
                ),
                onChanged: (String val) => {
                      password = val,
                    }),
            Container(
              margin: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    // color: myBlueColor,
                    onPressed: () async {
                      if (username.length == 0 ||
                          email.length == 0 ||
                          password.length == 0) {
                        showDialog(
                            context: context,
                            builder: (BuildContext Dialogcontext) {
                              return AlertDialog(
                                  title: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text("您必须填写所有字段。请完成您的输入。",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Center(
                                      child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(Dialogcontext),
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
                      } else {
                        pref = await SharedPreferences.getInstance();
                        var response = await http.post(
                            Uri.parse(serverUrl + '/api/register'),
                            body: {
                              'name': '${username}',
                              'email': '${email}',
                              'password': '${password}'
                            });
                        if (response.statusCode == 200) {
                          print('success');
                          showDialog(
                              context: context,
                              builder: (BuildContext Dialogcontext) {
                                return AlertDialog(
                                    title: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text("注册成功。",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Center(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(Dialogcontext);
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            print({
                                              'email': '${email}',
                                              'password': '${password}'
                                            });
                                            var response = await http.post(
                                                Uri.parse(
                                                    serverUrl + '/api/login'),
                                                body: {
                                                  'email': '${email}',
                                                  'password': '${password}'
                                                });
                                            var bodyData =
                                                json.decode(response.body);
                                            if (bodyData['message'] ==
                                                'Login Successful') {
                                              prefs.setString(
                                                  'token', bodyData['token']);
                                              Navigator.pushReplacement(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation1,
                                                          animation2) =>
                                                      recommendPage(),
                                                  transitionDuration:
                                                      Duration.zero,
                                                  reverseTransitionDuration:
                                                      Duration.zero,
                                                ),
                                              );
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext
                                                      Dialogcontext) {
                                                    return AlertDialog(
                                                        title: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Text("登录失败，邮箱或密码不正确",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText2),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Center(
                                                            child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      Dialogcontext),
                                                              // color:
                                                              //     myBlueColor,
                                                              child: Text('确定',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyText2
                                                                      .copyWith(
                                                                          color:
                                                                              Colors.white)),
                                                              style: TextButton
                                                                  .styleFrom(
                                                                backgroundColor:
                                                                    myBlueColor,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            4.0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            4.0),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            4.0),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            4.0),
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
                                          },
                                          // color: myBlueColor,
                                          child: Text('确定',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(
                                                      color: Colors.white)),
                                          style: TextButton.styleFrom(
                                            backgroundColor: myBlueColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(4.0),
                                                topRight: Radius.circular(4.0),
                                                bottomLeft:
                                                    Radius.circular(4.0),
                                                bottomRight:
                                                    Radius.circular(4.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ))
                                  ],
                                ));
                              });
                        } else {
                          print('您的网络有问题。');
                          showDialog(
                              context: context,
                              builder: (BuildContext Dialogcontext) {
                                return AlertDialog(
                                    title: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text("注册失败。因为重复的用户名或电子邮件。或者检查您与互联网的连接。",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Center(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(Dialogcontext),
                                          // color: myBlueColor,
                                          child: Text('确定',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(
                                                      color: Colors.white)),
                                          style: TextButton.styleFrom(
                                            backgroundColor: myBlueColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(4.0),
                                                topRight: Radius.circular(4.0),
                                                bottomLeft:
                                                    Radius.circular(4.0),
                                                bottomRight:
                                                    Radius.circular(4.0),
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
                    },
                    child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Text(
                            '报名',
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
