import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../tokenValidate.dart';
import '../../BottomNav.dart';
import '../mainMyPage.dart';
import 'orderHistoryItem.dart';

class orderHistoryList extends StatefulWidget {
  final String myPoint;
  orderHistoryList({Key key, this.myPoint}) : super(key: key);
  @override
  _orderHistoryListState createState() => _orderHistoryListState();
}

class _orderHistoryListState extends State<orderHistoryList> {
  int getCount = 0,
      cartCount =
          0; //getCount is used to call getJson() only once,and cartCount is used for the cart button on BottomNavbar
  bool receivedFromApi = false;
  getJson() async {
    await validateLogin(context, '/orderHistoryList');
    getCount++;
    if (getCount == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final appJson = await http.get(Uri.parse(serverUrl + '/api/orders'),
          headers: {'Authorization': prefs.getString('token')});
      setState(() {
        receivedFromApi = true;
        if (appJson.statusCode == 200) {
          tempData = json.decode(appJson.body)['data'];
        } else
          print('Cannot connect to server');
      });
    } else
      print('No data from previous screen!');
  }

  var tempData = [];
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
            child: Text("我的 > 订单与积分",
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Colors.black)),
          ),
        ),
        body: (tempData.length == 0 && receivedFromApi == false)
            ? Center(
                child: Image.asset('assets/images/animated_loading.gif'),
              )
            : (tempData.length == 0 && receivedFromApi == true)
                ? Container()
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: tempData
                              .map((e) => GestureDetector(
                                    child: panelWidgetForOrder(data: e),
                                    onTap: () => {
//                          Navigator.pushNamed(context, '/orderHistoryItem',arguments: e['order']['id'])
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              orderHistoryItem(
                                            orderId: (e['order']['id']).toString(),
                                            myPoint: widget.myPoint,
                                          ),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      )
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                      Container(
                        color: myGreyColor,
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('积分余额 :',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(color: Colors.black)),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                                (widget.myPoint == null)
                                    ? ''
                                    : (widget.myPoint + ' 分'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(color: Colors.red))
                          ],
                        ),
                      )
                    ],
                  ),
        bottomNavigationBar: BottomNav(
          pageName: 'mypage',
        ));
  }
}

class panelWidgetForOrder extends StatelessWidget {
  final Map data;
  panelWidgetForOrder({this.data});

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
      padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: myGreyColor))),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data['order']['order_number'],
                  style: TextStyle(fontSize: 13),
                ),
                flex: 3,
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  (data['order']['status'] == 0) ? '运输中/未支付' : '运输中/已支付',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
                flex: 3,
              ),
              Spacer(
                flex: 1,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Text(
                  data['price'].toString() + '円',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Container(
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: myGreyColor,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
