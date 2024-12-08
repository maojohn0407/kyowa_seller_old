import 'package:client/mypage/addresss/addressInput.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../env.dart';
import 'dart:convert';
import '../../BottomNav.dart';
import '../mainMyPage.dart';
import 'addressConfirm.dart';
import '../../tokenValidate.dart';
import 'dart:async';

class addressList extends StatefulWidget {
  addressList({Key key}) : super(key: key);
  @override
  _addressListState createState() => _addressListState();
}

class _addressListState extends State<addressList> {
  int getCount = 0,
      cartCount =
          0; //getCount is used to call getJson() only once,and cartCount is used for the cart button on BottomNavbar
  var temp = [];
  int dialogAppearingCount = 0;
  bool receivedFromApi = false;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    getJson();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      dialogAppearingCount = 0;
      showDialogIfAddressPassed(context);
    });
  }

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

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  getJson() async {
    getCount++;
    if (getCount == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final appJson = await http.get(Uri.parse(serverUrl + '/api/address'),
          headers: {'Authorization': prefs.getString('token')});
      setState(() {
        cartCount = prefs.getInt('cartCount');
        receivedFromApi = true;
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

    var random = new Random();
    int phoneNumber = random.nextInt(90000000) + 100000000;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.black),
          shadowColor: Colors.transparent,
          backgroundColor: myGreyColor,
          title: Row(
            children: [
              Spacer(
                flex: 1,
              ),
              Container(
                child: Text("我的 > 地址", style: TextStyle(color: Colors.black)),
              ),
              Spacer(
                flex: 1,
              ),
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle, border: Border.all(width: 1)),
                child: GestureDetector(
                  //if you click this,you can go to the phone validate page
                  child: Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 20,
                  ),
                  onTap: () => {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            addressInput(
                                phoneNumber: phoneNumber.toString()),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    )
                  },
                ),
              )
            ],
          ),
          leading: GestureDetector(
            child: Icon(Icons.arrow_back, size: 32.0),
            onTap: () => {
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
        ),
//        drawer: Icon(Icons.navigate_before),
        body: (temp.length == 0 && receivedFromApi == false)
            ? Center(
                child: Image.asset('assets/images/animated_loading.gif'),
              )
            : (temp.length == 0 && receivedFromApi == true)
                ? Container()
                : Container(
                    child: ListView(
                      children: temp
                          .map((e) => GestureDetector(
                                child: panelWidgetForAddress(data: e),
                                onTap: () => {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1,
                                              animation2) =>
                                          addressConfirm(
                                              addressId: e['id'].toString()),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  )
//                    Navigator.pushNamed(context, '/addressConfirm',arguments: e['id'])
                                },
                              ))
                          .toList(),
                    ),
                  ),
        bottomNavigationBar: BottomNav(
          pageName: 'mypage',
        ));
  }
}

class panelWidgetForAddress extends StatelessWidget {
  final Map data;
  panelWidgetForAddress({this.data});
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 5, 10, 0),
      padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: myGreyColor))),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '姓名: ' + data['name'].toString(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.black),
                ),
                flex: 5,
              ),
              Expanded(
                child: Text(''), // Text(data['delivery_type'].toString()), // Text('电话: ' + data['phone'].toString()),
                flex: 5,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      (data['is_verified'] == 1)
                          ? Text(
                              '审查中',
                              style: TextStyle(color: Colors.red),
                            )
                          : Icon(
                              Icons.check,
                              color: Color.fromRGBO(0, 163, 68, 1.0),
                            )
                    ],
                  ),
                ),
                flex: 2,
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(shortText(data['area_name'].toString(), 28)),
                flex: 8,
              ),
              Text(
                DateTime.parse(data['created_at']).year.toString() +
                    '/' +
                    DateTime.parse(data['created_at']).month.toString() +
                    '/' +
                    DateTime.parse(data['created_at']).day.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: myGreyColor),
              ),
            ],
          )
        ],
      ),
    );
  }
}
