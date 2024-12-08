import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../env.dart';
import 'dart:convert';
import '../../BottomNav.dart';
import '../mainMyPage.dart';
import '../../home/shopping/detail.dart';

class favorite extends StatefulWidget {
  favorite({Key key}) : super(key: key);
  @override
  _favoriteState createState() => _favoriteState();
}

class _favoriteState extends State<favorite> {
  int getCount = 0,
      cartCount =
          0; //getCount is used to call getJson() only once,and cartCount is used for the cart button on BottomNavbar
  var temp = [];
  bool receivedFromApi = false;

  getJson() async {
    getCount++;
    if (getCount == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getInt('cartCount') == null) prefs.setInt('cartCount', 0);
      final appJson = await http.get(Uri.parse(serverUrl + '/api/favorites'),
          headers: {'Authorization': prefs.getString('token')});
      setState(() {
        receivedFromApi = true;
        cartCount = prefs.getInt('cartCount');
        if (appJson.statusCode == 200) {
          temp = json.decode(appJson.body)['data'];
        } else
          print('Cannot connect to server');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getJson();
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.black),
          shadowColor: Colors.transparent,
          backgroundColor: myGreyColor,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back, size: 32.0),
            onTap: () => {
//                Navigator.pushNamed(context,'/secondCategory',arguments: receivedData['p_id']),
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      mainMyPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              )
            },
          ),
          title: Container(
            alignment: Alignment(-0.24, 0),
            child: Text("我的 > 收藏", style: TextStyle(color: Colors.black)),
          ),
        ),
        body: (temp.length == 0 && receivedFromApi == false)
            ? Center(
                child: Image.asset('assets/images/animated_loading.gif'),
              )
            : (temp.length == 0 && receivedFromApi == true)
                ? Container()
                : ListView(
                    children: temp
                        .map((e) => Container(
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: myGreyColor)),
                                    child: GestureDetector(
                                      child:
                                          (e['product']['images'].length == 0)
                                              ? Image.asset(
                                                  'assets/images/logo.png',
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.15)
                                              : Image.network(
                                                  serverUrl +
                                                      environment['image_url'] +
                                                      e['product']['images'][0]
                                                              ['image_src']
                                                          .toString(),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.15),
                                      onTap: () => {
                                        Navigator.pushReplacement(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1,
                                                    animation2) =>
                                                Detail(
                                              productId: e['product']['id'],
                                              exploringData: {'id': -3},
                                            ),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
                                          ),
                                        )
                                      },
                                    ),
                                    margin: EdgeInsets.fromLTRB(5, 5, 20, 5),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(e['product']['name'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                e['product']['retailsales']
                                                            ['retailsale']
                                                        .toString() +
                                                    '円',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ),
                                              flex: 2,
                                            ),
                                            Spacer(
                                              flex: 2,
                                            ),
                                            Text(
                                              e['created_at'].substring(0, 10),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .copyWith(color: myGreyColor),
                                            ),
                                            SizedBox(
                                              width: 30,
                                            ),
                                            Expanded(
                                              child: TextButton(
                                                child: Icon(
                                                  Icons.clear,
                                                  size: 15,
                                                ),
                                                onPressed: () => {
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
                                                            Text("""商品名：xxxxx
确定要删除吗？""",
                                                                textAlign:
                                                                    TextAlign
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
                                                                  onPressed:
                                                                      () async {
                                                                    var response = await http.delete(
                                                                        Uri.parse(serverUrl +
                                                                            '/api/favorite/' +
                                                                            e['id'].toString()),
                                                                        headers: {
                                                                          'Authorization':
                                                                              environment['token']
                                                                        });
                                                                    if (json.decode(
                                                                            response.body)['message'] ==
                                                                        'Favorite Delete Successful') {
                                                                      setState(
                                                                          () {
                                                                        getCount =
                                                                            0;
                                                                      });
                                                                      getJson();
                                                                    }
                                                                    Navigator.pop(
                                                                        Dialogcontext);
                                                                  },
                                                                  // colo
                                                                  child: Text(
                                                                      '确定',
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyText2),
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Color
                                                                            .fromRGBO(
                                                                      166,
                                                                      166,
                                                                      166,
                                                                      1.0,
                                                                    ),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
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
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        Dialogcontext);
                                                                  },
                                                                  child: Text(
                                                                      '取消',
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyText2),
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Color
                                                                            .fromRGBO(
                                                                      166,
                                                                      166,
                                                                      166,
                                                                      1.0,
                                                                    ),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
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
                                                      })
                                                },
                                              ),
                                              flex: 1,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  ),
        bottomNavigationBar: BottomNav(
          pageName: 'mypage',
        ));
  }
}
