import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../tokenValidate.dart';
import '../../BottomNav.dart';
import 'orderHistoryItem.dart';

class orderHistoryDetail extends StatefulWidget {
  final String orderId;
  final String myPoint;
  orderHistoryDetail({Key key, this.orderId, this.myPoint}) : super(key: key);
  @override
  _orderHistoryDetailState createState() => _orderHistoryDetailState();
}

class _orderHistoryDetailState extends State<orderHistoryDetail> {
  int getCount = 0,
      cartCount =
          0; //getCount is used to call getJson() only once,and cartCount is used for the cart button on BottomNavbar
  double total_8price = 0,
      total_8calprice = 0,
      total_10price = 0,
      total_10calprice = 0,
      sumprice = 0,
      sumcalprice = 0;
  bool is_received = false;

  getJson() async {
    await validateLogin(context, '/orderHistoryDetail');
    getCount++;
    if (getCount == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final appJson = await http.get(
          Uri.parse(serverUrl +
              '/api/orders/' +
              widget.orderId.toString() +
              '/detail'),
          headers: {'Authorization': prefs.getString('token')});
      if (appJson.statusCode == 200) {
        json.decode(appJson.body)['data'].forEach((e) {
          sumprice += e['price'];
          sumcalprice += e['cal_price'];
          if (e['tax'] == 0.08) {
            total_8price += e['price'];
            total_8calprice += e['cal_price'];
          }
          //if the product is 10% product
          else {
            total_10price += e['price'];
            total_10calprice += e['cal_price'];
          }
        });
        setState(() {
          is_received = true;
          tempData = json.decode(appJson.body)['data'];
        });
      } else
        print('Cannot connect to server');
      ;
    } else
      print('No data from previous screen!');
  }

  var tempData = [];

  List<Widget> lineWidgetsFunc() {
    List<Widget> lineWidgets;
    lineWidgets = tempData
        .map<Widget>((e) => panelWidgetForOrderDetail(data: e))
        .toList();
    lineWidgets.add(Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: [
                          Spacer(
                            flex: 2,
                          ),
                          Expanded(
                            child: Text('8%対象税抜金额:',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 13)),
                            flex: 2,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: Text(total_8price.toString() + '円',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 13)),
                            ),
                            flex: 1,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                flex: 1,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Row(
                        children: [
                          Spacer(
                            flex: 2,
                          ),
                          Expanded(
                            child: Text('8%対象税额:',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 13)),
                            flex: 2,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: Text(total_8calprice.toString() + '円',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 13)),
                            ),
                            flex: 1,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                flex: 1,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: [
                          Spacer(
                            flex: 2,
                          ),
                          Expanded(
                            child: Text('10%対象税抜金额:',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 13)),
                            flex: 2,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: Text((total_10price.toString() + '円'),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 13)),
                            ),
                            flex: 1,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                flex: 1,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Row(
                        children: [
                          Spacer(
                            flex: 2,
                          ),
                          Expanded(
                            child: Text('10%対象税额:',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 13)),
                            flex: 2,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: Text(
                                (total_10calprice.toString() + '円'),
                                style: TextStyle(fontSize: 13),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            flex: 1,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                flex: 1,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: [
                          Spacer(
                            flex: 2,
                          ),
                          Expanded(
                            child: Text('总额（税抜）:',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 13)),
                            flex: 2,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: Text((sumprice.toString() + '円'),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 13)),
                            ),
                            flex: 1,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                flex: 1,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: [
                          Spacer(
                            flex: 2,
                          ),
                          Expanded(
                            child: Text('总额（税込）:',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 13)),
                            flex: 2,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: Text((sumcalprice.toString() + '円'),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 13)),
                            ),
                            flex: 1,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                flex: 1,
              ),
            ],
          ),
        ),
      ],
    ));
    return lineWidgets;
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
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      orderHistoryItem(
                    orderId: widget.orderId,
                    myPoint: widget.myPoint,
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              )
            },
          ),
          title: Container(
            alignment: Alignment(-0.24, 0),
            child: Text("我的 > 订单与积分 > 订单 > 商品详细",
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Colors.black)),
          ),
        ),
//        drawer: Icon(Icons.navigate_before),
        body: ((is_received))
            ? Column(
                children: [
                  Expanded(
                      child: ListView(
                    children: lineWidgetsFunc(),
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        color: myGreyColor,
                        child: GestureDetector(
                          child: Text('消費税10％対象商品名已括号【】来表示。',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13)),
                          onTap: () => {
                            showDialog(
                                context: context,
                                builder: (BuildContext Dialogcontext) {
                                  return AlertDialog(
                                      title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text("10%product explanation",
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
                                            onPressed: () {
                                              Navigator.pop(Dialogcontext);
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
                      ))
                    ],
                  )
                ],
              )
            : Center(
                child: Image.asset('assets/images/animated_loading.gif'),
              ),
        bottomNavigationBar: BottomNav(
          pageName: 'mypage',
        ));
  }
}

class panelWidgetForOrderDetail extends StatelessWidget {
  final Map data;
  panelWidgetForOrderDetail({this.data});

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 5, 10, 0),
      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: myGreyColor))),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              (data['tax'] != 0.08)
                  ? Text(
                      '[',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text(''),
              Text(data['product']['name'], style: TextStyle(fontSize: 13)),
              (data['tax'] != 0.08)
                  ? Text(
                      ']',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text(''),
              Spacer(
                flex: 1,
              ),
            ],
          ),
          Row(
            children: [
              Spacer(
                flex: 4,
              ),
              Expanded(
                child: Text(
                    data['product']['retailsales']['retailsale'].toString() +
                        '円',
                    style: TextStyle(fontSize: 13)),
                flex: 2,
              ),
              Expanded(
                child: Text('X'),
                flex: 1,
              ),
              Expanded(
                child: Text(
                    data['qty'].toString() + data['product']['unit']['name'],
                    style: TextStyle(fontSize: 13)),
                flex: 2,
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Text(data['price'].toString() + '円',
                    style: TextStyle(fontSize: 13)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
