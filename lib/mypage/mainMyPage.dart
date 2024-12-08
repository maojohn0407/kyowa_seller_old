import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../env.dart';
import 'dart:convert';
import 'dart:async';
import '../BottomNav.dart';
import '../tokenValidate.dart';
import 'addresss/addressList.dart';
import 'chatHistory/histroy.dart';
import 'favorite/favorite.dart';
import 'orderHistory/orderHistoryList.dart';

class mainMyPage extends StatefulWidget {
  mainMyPage({Key key}) : super(key: key);
  @override
  _mainMyPageState createState() => _mainMyPageState();
}

class _mainMyPageState extends State<mainMyPage> {
  int getCount = 0,
      cartCount = 0; //getCount is used to call getJson() only once,and cartCount is used for the cart button on BottomNavbar
  var temp;
  var vipUser = false;
  String receiver;
  SharedPreferences prefs;
  Timer _timer;
  int dialogAppearingCount = 0;

  showDialogIfAddressPassed(BuildContext context) async {
    dialogAppearingCount++;
    if (dialogAppearingCount == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      tokenValidate().then((value) => {
        if (value == false)
          {
            print('guest user'),
          }
        else
          {
            http.get(Uri.parse(serverUrl + '/api/addressreadstatus'),
                headers: {
                  'Authorization': value,
                }).then((http.Response jsonData) {
              if (jsonData.statusCode == 200 &&
                  jsonDecode(jsonData.body)['message'] ==
                      'Address Signed')
              {
                prefs.setBool('VIPUser', true);
                showDialog(
                    context: context,
                    builder: (BuildContext Dialogcontext) {
                      return AlertDialog(
                        content: Text(
                            """尊敬的客户，您的地址已经通过审查。 可以下单了！ 根据您的地址设定好了邮费的范围。 可以在【我的 >  地址】里查看邮费的详细信息。""",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1),
                        actions: [
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 100, 0),
                            padding: EdgeInsets.all(5.0),
                            child: TextButton(
                              onPressed: () async {
                                http.post(Uri.parse(serverUrl + '/api/addressreadset'),
                                    headers: { 'Authorization': value},
                                    body: {
                                      'id': '${json.decode(jsonData.body)['data']['id']}'
                                    }).then((http.Response jsonData) {
                                  if (jsonData.statusCode == 200) {
                                    getCount = 0;
                                    getJson();
                                  } else {
                                    print('network error');
                                  }
                                });
                                Navigator.pop(Dialogcontext);
                              },
                              child: const Text(
                                '  知道了  ',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: TextButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(
                                      247, 150, 70, 1.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4.0),
                                      topRight: Radius.circular(4.0),
                                      bottomLeft:
                                      Radius.circular(4.0),
                                      bottomRight:
                                      Radius.circular(4.0),
                                    ),
                                  )),
                            ),
                          )
                        ],
                      );
                    });
              }
            })
          },
      });
    }
  }

  getJson() async {
    prefs = await SharedPreferences.getInstance();
    getCount++;
    if (getCount == 1) {
      setState(() {
        vipUser = prefs.getBool("VIPUser") ?? false;
      });
      tokenValidate().then((value) => {
            if (value == false)
              {
                Navigator.popAndPushNamed(context, '/login', arguments: '/myPage'),
              }
            else
              {
                //here,value is token
                if (prefs.getInt('cartCount') == null)
                  prefs.setInt('cartCount', 0),
                http.get(Uri.parse(serverUrl + '/api/mypage'), headers: {
                  'Authorization': value
                }).then((http.Response appJson) => {
                      setState(() {
                        cartCount = prefs.getInt('cartCount');
                        if (appJson.statusCode == 200) {
                          temp = json.decode(appJson.body);
                        } else
                          print('Cannot connect to server');
                      }),
                    }),

                http.get(
                    Uri.parse(serverUrl + '/api/' + environment['chatter']),
                    headers: {
                      'Authorization': prefs.getString('token')
                    }).then((http.Response response) => {
                      if (response.statusCode == 200)
                        {
                          receiver = jsonDecode(response.body)['receiver_id']
                              .toString(),
                          print(jsonDecode(response.body)),
                        }
                      else
                        {receiver = null}
                    }),
              },
          });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getJson();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shadowColor: Colors.transparent,
        backgroundColor: myGreyColor,
        title: Container(
          alignment: Alignment(0, 0),
          child: Text("我的", style: TextStyle(color: Colors.black)),
        ),
      ),
      body: (temp != null)
          ? Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                          bottom: BorderSide(
                              width: 1,
                              color: Color.fromRGBO(217, 217, 217, 1.0)))),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                  margin: EdgeInsets.fromLTRB(20, 10, 0, 10),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            child: Text(
                          "地址 (" + temp['addresscount'].toString() + ")",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.black),
                        )),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color.fromRGBO(217, 217, 217, 1.0),
                        )
                      ],
                    ),
                    onTap: () => {
//                  Navigator.pushNamed(context, '/addressList'),
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
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                          bottom: BorderSide(
                              width: 1,
                              color: Color.fromRGBO(217, 217, 217, 1.0)))),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                  margin: EdgeInsets.fromLTRB(20, 10, 0, 10),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            child: Text(
                          "收藏 (" + temp['favoriteCount'].toString() + ")",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.black),
                        )),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color.fromRGBO(217, 217, 217, 1.0),
                        )
                      ],
                    ),
                    onTap: () => {
//                  Navigator.pushNamed(context, '/favorite')
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              favorite(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      )
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                          bottom: BorderSide(
                              width: 1,
                              color: Color.fromRGBO(217, 217, 217, 1.0)))),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                  margin: EdgeInsets.fromLTRB(20, 10, 0, 10),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            child: Text(
                          "订单/积分 (" + temp['orderCount'].toString() + ")",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.black),
                        )),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Text(
                            '余额积分:',
                            style: TextStyle(color: myGreyColor),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Text(
                            temp['myPoint'].toString() + ' 分',
                            style: TextStyle(color: myGreyColor),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color.fromRGBO(217, 217, 217, 1.0),
                        )
                      ],
                    ),
                    onTap: () => {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              orderHistoryList(
                            myPoint: temp['myPoint'].toString(),
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      )
                    },
                  ),
                ),
                (vipUser) ? Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                          bottom: BorderSide(
                              width: 1,
                              color: Color.fromRGBO(217, 217, 217, 1.0)))),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                  margin: EdgeInsets.fromLTRB(20, 10, 0, 10),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            child: Text(
                          "联系客服",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.black),
                        )),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color.fromRGBO(217, 217, 217, 1.0),
                        )
                      ],
                    ),
                    onTap: () => {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              ChatHistory(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      )
                    },
                  ),
                ) : Container(),
              ],
            )
          : Center(
              child: Image.asset('assets/images/animated_loading.gif'),
            ),
      bottomNavigationBar: BottomNav(
        pageName: 'mainMyPage',
      ),
    );
  }
}
