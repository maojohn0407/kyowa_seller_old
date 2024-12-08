import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../env.dart';
import '../../tokenValidate.dart';
import '../../BottomNav.dart';
import 'addressList.dart';
import 'addressInput.dart';

class phoneValidate extends StatefulWidget {
  phoneValidate({Key key}) : super(key: key);
  @override
  _phoneValidateState createState() => _phoneValidateState();
}

class _phoneValidateState extends State<phoneValidate> {
  String phoneNumber = '', sign = '';
  bool isReadyForSign = false, isReadyForPhone = false, isReadyForRetry = false;
  SharedPreferences pref;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            iconTheme:
                Theme.of(context).iconTheme.copyWith(color: Colors.black),
            shadowColor: Colors.transparent,
            leading: GestureDetector(
              child: Icon(Icons.arrow_back, size: 32.0),
              onTap: () => {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        addressList(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              },
            ),
            backgroundColor: myGreyColor,
            title: Row(
              children: [
                Spacer(
                  flex: 1,
                ),
                Container(
                  child: Text("我的 > 地址 > 新增",
                      style: TextStyle(color: Colors.black)),
                ),
                Spacer(
                  flex: 2,
                ),
              ],
            )),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(20, 5, 10, 0),
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(width: 1, color: myGreyColor))),
              child: Row(
                children: [
                  Expanded(
                    child: Text('手机: ',
                        style: Theme.of(context).textTheme.bodyText1),
                    flex: 2,
                  ),
                  Expanded(
                    child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          // WhitelistingTextInputFormatter(RegExp('[0-9 -]'))
                        ],
                        decoration: InputDecoration(
                          hintText: '请输入电话号码',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: myGreyColor),
                          isCollapsed: true,
                          contentPadding: EdgeInsets.all(2),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        onChanged: (String val) => {
                              setState(() {
                                if (val.length > 0) isReadyForPhone = true;
                                phoneNumber = val;
                              })
                            }),
                    flex: 4,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: TextButton(
                      // color: myBlueColor,
                      // disabledColor: Color.fromRGBO(79, 129, 189, 0.5),
                      onPressed: (!isReadyForPhone)
                          ? null
                          : () async {
                              await validateLogin(context, '/phoneValidate');
                              pref = await SharedPreferences.getInstance();
                              var response = await http.post(
                                  Uri.parse(serverUrl + '/api/addressphone'),
                                  headers: {
                                    'Authorization': pref.getString('token')
                                  },
                                  body: {
                                    'phone': '${phoneNumber}'
                                  });
                              if (response.statusCode == 200) {
                                setState(() {
                                  isReadyForSign = true;
                                });
                                showDialog(
                                    context: context,
                                    builder: (BuildContext Dialogcontext) {
                                      return AlertDialog(
                                          title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                              '代码发送成功。',
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
                                                onPressed: () => Navigator.pop(
                                                    Dialogcontext),
                                                // color: myBlueColor,
                                                child: Text('确定',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .copyWith(
                                                            color:
                                                                Colors.white)),
                                                style: TextButton.styleFrom(
                                                  backgroundColor: myBlueColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(4.0),
                                                      topRight:
                                                          Radius.circular(4.0),
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
                                          Text(
                                              "您的网络有问题。",
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
                                                onPressed: () => Navigator.pop(
                                                    Dialogcontext),
                                                // disabledColor: myGreyColor,
                                                child: Text('确定',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .copyWith(
                                                            color:
                                                                Colors.white)),
                                                style: TextButton.styleFrom(
                                                  backgroundColor: myBlueColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(4.0),
                                                      topRight:
                                                          Radius.circular(4.0),
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
                            },
                      child: Text('验证码发送',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
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
                    flex: 3,
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 5, 10, 0),
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(width: 1, color: myGreyColor))),
              child: Row(
                children: [
                  Expanded(
                    child: Text('验证码: ',
                        style: Theme.of(context).textTheme.bodyText1),
                    flex: 2,
                  ),
                  Expanded(
                    child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '请输入验证码',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: myGreyColor),
                          isCollapsed: true,
                          contentPadding: EdgeInsets.all(2),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        onChanged: (String val) => {
                              setState(() {
                                sign = val;
                              })
                            }),
                    flex: 4,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextButton(
                      // color: myBlueColor,
                      // disabledColor: Color.fromRGBO(79, 129, 189, 0.5),
                      onPressed: (!isReadyForSign)
                          ? null
                          : () async {
                              pref = await SharedPreferences.getInstance();
                              var response = await http.post(
                                  Uri.parse(serverUrl + '/api/addresssign'),
                                  headers: {
                                    'Authorization': pref.getString('token')
                                  },
                                  body: {
                                    'sign': '${sign}'
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
                                          Text(
                                              "已成功核对您的手机并签到号码！您可以进入创建页面。",
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
                                                onPressed: () => {
//                                                Navigator.popAndPushNamed(Dialogcontext,'/addressInput',arguments: phoneNumber)
                                                  Navigator.pushReplacement(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context,
                                                              animation1,
                                                              animation2) =>
                                                          addressInput(
                                                              phoneNumber:
                                                                  phoneNumber),
                                                      transitionDuration:
                                                          Duration.zero,
                                                      reverseTransitionDuration:
                                                          Duration.zero,
                                                    ),
                                                  )
                                                },
                                                // color: myBlueColor,
                                                child: Text('确定',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .copyWith(
                                                            color:
                                                                Colors.white)),
                                                style: TextButton.styleFrom(
                                                  backgroundColor: myBlueColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(4.0),
                                                      topRight:
                                                          Radius.circular(4.0),
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
                                setState(() {
                                  isReadyForPhone = false;
                                  isReadyForSign = false;
                                  isReadyForRetry = true;
                                });
                                showDialog(
                                    context: context,
                                    builder: (BuildContext Dialogcontext) {
                                      return AlertDialog(
                                          title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                              "False certNum.You are not the owner of that phone Number",
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
                                                onPressed: () => Navigator.pop(
                                                    Dialogcontext),
                                                // color: myBlueColor,
                                                child: Text('确定',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .copyWith(
                                                            color:
                                                                Colors.white)),
                                                style: TextButton.styleFrom(
                                                  backgroundColor: myBlueColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(4.0),
                                                      topRight:
                                                          Radius.circular(4.0),
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
                            },
                      child: Text('验证', style: TextStyle(color: Colors.white)),
                      style: TextButton.styleFrom(
                          backgroundColor: myBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4.0),
                              topRight: Radius.circular(4.0),
                              bottomLeft: Radius.circular(4.0),
                              bottomRight: Radius.circular(4.0),
                            ),
                          )),
                    ),
                    flex: 3,
                  )
                ],
              ),
            ),
            (isReadyForRetry)
                ? Container(
                    margin: EdgeInsets.fromLTRB(0, 30, 0, 5),
                    alignment: Alignment.center,
                    child: Text(
                      '⚠验证码有误请重新验证',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : Container(),
            (isReadyForRetry)
                ? Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                    alignment: Alignment.center,
                    child: TextButton(
                      // color: myBlueColor,
                      // disabledColor: Color.fromRGBO(79, 129, 189, 0.5),
                      onPressed: () => {
                        Navigator.popAndPushNamed(context, '/phoneValidate')
                      },
                      child:
                          Text('重新验证', style: TextStyle(color: Colors.white)),
                      style: TextButton.styleFrom(
                          backgroundColor: myBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4.0),
                              topRight: Radius.circular(4.0),
                              bottomLeft: Radius.circular(4.0),
                              bottomRight: Radius.circular(4.0),
                            ),
                          )),
                    ))
                : Container()
          ],
        ),
        bottomNavigationBar: BottomNav(
          pageName: 'mypage',
        ));
  }
}
