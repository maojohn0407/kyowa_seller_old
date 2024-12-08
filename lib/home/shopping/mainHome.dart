import 'dart:convert';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dialogContent.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../env.dart';
import '../../BottomNav.dart';
import '../../tokenValidate.dart';
import '../others/specialService.dart';
import 'package:firebase_database/firebase_database.dart';
import 'secondCategory.dart';
import '../news/newsCategory.dart';

class mainHome extends StatefulWidget {
  mainHome({Key key}) : super(key: key);
  @override
  _mainHomeState createState() => _mainHomeState();
}

class CustomFabLocation extends FloatingActionButtonLocation {
  // Define a constructor to pass the offset (in logical pixels)
  const CustomFabLocation(this.offsetX);

  // Offset in logical pixels to deduct from the current X position
  final double offsetX;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Calculate the new X position by deducting the offsetX
    final double x = scaffoldGeometry.scaffoldSize.width - offsetX;
    final double y = scaffoldGeometry.contentBottom - 150.0; // Adjust Y-axis position as needed
    return Offset(x, y);
  }
}

class _mainHomeState extends State<mainHome> {
  dynamic flagForBack = false;
  int dialogAppearingCount = 0;
  bool shouldDisplayLogout = false;
  int getCount = 0, cartCount = 0, count = 0;
  SharedPreferences prefs;
  bool vipUser = false;
  bool isNewMsg = false;
  int userId = 0;
  var temp = [];
  Timer _timer;
  var _msgSubscr;
  bool firstScreenOpened = true;

  Future<void> getJson() async {
    getCount++;
    if (getCount == 1) {
      prefs = await SharedPreferences.getInstance();
      bool vipUser = await prefs.getBool("VIPUser") ?? false;
      int userId = prefs.getInt("userId") ?? 0;
      String token = await prefs.getString("token");

      _timer = Timer.periodic(Duration(seconds: 30), (timer) {
        dialogAppearingCount = 0;
        showDialogIfAddressPassed(context);
      });

      if (token != null && token.isNotEmpty) {
        setState(() {
          shouldDisplayLogout = true;
          this.vipUser = vipUser;
          this.userId = userId;
        });
      }

      if (this.vipUser && this.userId != 0) {
        DatabaseReference ref1 = FirebaseDatabase.instance.ref('$dbService/' + userId.toString());
        _msgSubscr = ref1.onValue.listen((event) {
          if (event.snapshot.exists) {
            Map map = event.snapshot.value;
            var temp = [];
            map.forEach((key, value) {
              temp.add(value);
            });

            temp.sort((a, b) => DateTime.parse(a['datetime']).compareTo(DateTime.parse(b['datetime'])));
            if (temp.isNotEmpty) {
              var lastElement = temp.last;
              if (lastElement['sender_id'].toString() != userId.toString()) {
                firstScreenOpened = false;
                setState(() {
                  isNewMsg = true;
                });
              }
            }
          }
        });
      }

      if (prefs.getInt('cartCount') == null) prefs.setInt('cartCount', 0);

      String cachedParentCategory = prefs.getString('parentCategory');
      if (cachedParentCategory != null && cachedParentCategory != '') {
        dynamic json = jsonDecode(cachedParentCategory);
        var lastCategoryParentTime = DateTime.fromMillisecondsSinceEpoch(
            prefs.getInt('lastCategoryParentTime') ?? 0);

        // Check time difference
        if (DateTime.now().difference(lastCategoryParentTime).inMinutes <= 30) {
          // Use cached data
          setState(() {
            temp = json;
          });
          return;
        }
      }

      final appJson = await http.get(Uri.parse(serverUrl + '/api/parentcategory'));
      if (appJson.statusCode == 200) {
        setState(() {
          cartCount = prefs.getInt('cartCount');
          temp = json.decode(appJson.body)['data'];
        });

        await prefs.setString('parentCategory', jsonEncode(temp));
        await prefs.setInt('lastCategoryParentTime', DateTime.now().millisecondsSinceEpoch);
      }
      else
        print('Cannot connect to server');
    }
  }

  Future<int> getNewsID() async {
    // prefs = await SharedPreferences.getInstance();
    //
    // String cachedNewsTitles = prefs.getString('newsTitles');
    // if (cachedNewsTitles != null && cachedNewsTitles != '') {
    //   dynamic json = jsonDecode(cachedNewsTitles);
    //   var lastNewsTitlesTime = DateTime.fromMillisecondsSinceEpoch(
    //       prefs.getInt('lastNewsTitlesTime') ?? 0);
    //
    //   // Check time difference
    //   if (DateTime.now().difference(lastNewsTitlesTime).inMinutes <= 30) {
    //     // Use cached data
    //     setState(() {
    //       temp = json;
    //     });
    //     return 0;
    //   }
    // }

    return http
        .get(Uri.parse(serverUrl + '/api/newstitles'))
        .then((http.Response res) {
      if (res.statusCode == 200) {
        var newsList = jsonDecode(res.body)['data'];
        List<String> newsids = prefs.getStringList('newsIds') ?? [];
        List<String> templist = [];
        if (newsids == null || newsids.length < 1) {
          return jsonDecode(res.body)['data'].length;
        } else {
          int count = 0;
          newsList.forEach((element) {
            if (!newsids.contains(element['id'].toString())) {
              count++;
            }
            templist.add(element['id'].toString());
          });
          newsids.removeWhere((element) => !templist.contains(element));
          prefs.setStringList('newsIds', newsids);
          return count;
        }
      }
      return 0;
    });
  }

  @override
  void dispose() {
    _msgSubscr?.cancel();
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  showDialogIfAddressPassed(BuildContext context) async {
    dialogAppearingCount++;
    if (dialogAppearingCount == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      if (token.isEmpty) return ;
      http.get(Uri.parse(serverUrl + '/api/addressreadstatus'),
          headers: {
            'Authorization': token,
          }).then((http.Response jsonData) {
        if (jsonData.statusCode == 200 && jsonDecode(jsonData.body)['message'] == 'Address Signed') {
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
                              headers: { 'Authorization': token},
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
      });
    }
  }


  Widget build(BuildContext context) {
    getJson();
    Future.delayed(Duration.zero, () => showDialogIfAddressPassed(context));
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.white,
            title: Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(
                      flex: 1,
                    ),
                    Column(
                      children: [
                        Container(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.fitHeight,
                            width: 50,
                          ),
                        ),
                        Text('KYOWA',
                            style: Theme.of(context)
                                .textTheme
                                .overline
                                .copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold))
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("京和商城",
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            color: myBlueColor, fontWeight: FontWeight.bold)),
                    Spacer(
                      flex: 1,
                    ),
                    (shouldDisplayLogout)
                        ? GestureDetector(
                            child: Row(
                              children: [
                                Text('登出', style: TextStyle(color: myBlueColor, fontSize: 15)),
                                Icon(Icons.logout, color: myBlueColor, size: 15)
                              ],
                            ),
                            onTap: () async {
                              prefs = await SharedPreferences.getInstance();
                              prefs.setString('token', '');
                              prefs.setInt('cartCount', 0);
                              setState(() {
                                shouldDisplayLogout = false;
                              });
                              Navigator.pushNamed(context, '/login', arguments: '/home');
                            },
                          )
                        : GestureDetector(
                            child: Row(
                              children: [
                                Text('加入', style: TextStyle(color: myBlueColor, fontSize: 15),),
                                Icon(
                                  Icons.login,
                                  color: myBlueColor,
                                  size: 15,
                                )
                              ],
                            ),
                            onTap: () => {
                              Navigator.pushNamed(context, '/login', arguments: '/home'),
                            },
                          )
                  ],
                ))),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.volume_up_outlined,
                  size: 30,
                ),
                GestureDetector(
                  child: Text("12月促销活动",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          decoration: TextDecoration.underline)),
                  onTap: () => {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            specialService(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    )
                  },
                )
              ],
            ),
            Container(
              color: myBlueColor,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.fromLTRB(0, 3, 0, 7),
              child: GestureDetector(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Text("关于京和", style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),)
                    ),
                    Container(
                      child: FutureBuilder<int>(
                          future: getNewsID(),
                          builder: (BuildContext context,
                              AsyncSnapshot<int> snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data == 0) {
                                return Container();
                              }
                              count = snapshot.data;
                              return Container(
                                padding: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: Text(
                                  snapshot.data.toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                            return Container();
                          }),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    )
                  ],
                ),
                onTap: () => {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => newsCategory(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  )
                },
              ),
            ),
            Container(
              color: myBlueColor,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.fromLTRB(0, 3, 0, 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: Text(
                    "商品分类",
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                  GestureDetector(
                    child: Transform(
                      transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                      alignment: Alignment.center,
                      transformHitTests: false,
                      child: Icon(
                        Icons.search_sharp,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    onTap: () => {
                      showDialog<void>(
                          context: context,
                          builder: (BuildContext ctx) {
                            return dialogContent(
                                whichPage: 'mainHome',
                                categoryType: 'entire',
                                categoryId: null,
                                sendingData: {
                                  'id' : -6
                                },
                            );
                          })
                    },
                  )
                ],
              ),
            ),
            (temp.length != 0)
                ? Expanded(
                    child: ListView(
                        children: temp.map((e) => GestureDetector(
                                  child: panelWidget(data: e),
                                  onTap: () => {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation1,
                                                animation2) =>
                                            secondCategory(categoryId: e['id']),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    )
                                  },
                                ))
                            .toList()))
                : Center(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: Image.asset('assets/images/animated_loading.gif'),
                    ),
                  )
          ],
        ),
        bottomNavigationBar: BottomNav(
          pageName: 'mainHome',
       ),
      floatingActionButton: (vipUser)
          ? Stack(
        clipBehavior: Clip.none, // Allows the red dot to overflow the Stack bounds
        children: [
          FloatingActionButton(
            onPressed: () {
              // Implement the action to make a call here...
              Navigator.pushNamed(context, '/chatHistory');
            },
            tooltip: 'Make a Call',
            backgroundColor: Colors.blueAccent,
            foregroundColor: myBlueColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/servicecall.png',
                  width: 35,
                ),
                SizedBox(height: 4), // Space between image and text
                Text(
                  '在线客服',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (isNewMsg) // Show red dot only when isNewMsg is true
            Positioned(
              right: 0, // Position it at the top right of the button
              top: -4, // Slightly above the button to center on the corner
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.blue, // Red dot color
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      )
          : null,

      floatingActionButtonLocation: CustomFabLocation(70.0),
    );
  }
}

//@author:Yaroslav
//@date:2022-2-11
//@desc: the row component associated with the big category button

class panelWidget extends StatelessWidget {
  final Map data;
  panelWidget({this.data});
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(bottom: BorderSide(width: 1, color: myBlueColor))),
      padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
      margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              child: Text(
            data['name'] + "(" + data['p_products_count'].toString() + ")",
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.black),
          )),
          Icon(
            Icons.arrow_forward_ios_sharp,
            color: myBlueColor,
          )
        ],
      ),
    );
  }
}
