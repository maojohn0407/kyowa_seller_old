// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, non_constant_identifier_names, camel_case_types, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../tokenValidate.dart';
import '../../BottomNav.dart';
import 'orderHistoryDetail.dart';
import 'orderHistoryList.dart';

class orderHistoryItem extends StatefulWidget {
  final String orderId;
  final String myPoint;
  const orderHistoryItem({Key key, this.orderId, this.myPoint})
      : super(key: key);
  @override
  _orderHistoryItemState createState() => _orderHistoryItemState();
}

class _orderHistoryItemState extends State<orderHistoryItem> {
  SharedPreferences pref;
  int getCount = 0, cartCount = 0;
  //getCount is used to call getJson() only once,and cartCount is used for the cart button on BottomNavbar
  bool is_received = false;
  getJson() async {
    await validateLogin(context, '/orderHistoryItem');
    getCount++;
    if (getCount == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final appJson = await http.get(
          Uri.parse('$serverUrl/api/orders/${widget.orderId}'),
          headers: {'Authorization': prefs.getString('token')});
      setState(() {
        if (appJson.statusCode == 200) {
          is_received = true;
          tempData = json.decode(appJson.body)['data'];
          print('tempdata = $tempData');
        } else {
          print('Cannot connect to server');
        }
      });
    } else {
      print('No data from previous screen!');
    }
  }

  var tempData;
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
            child: const Icon(Icons.arrow_back, size: 32.0),
            onTap: () => {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      orderHistoryList(
                    myPoint: widget.myPoint,
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              )
            },
          ),
          title: Container(
            alignment: const Alignment(-0.24, 0),
            child: Text("我的 > 订单与积分 > 订单",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    .copyWith(color: Colors.black)),
          ),
        ),
        body: ((is_received))
            ? ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 5, 10, 0),
                    padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: myGreyColor))),
                    child: Column(
                      children: [
                        GestureDetector(
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: Text('订单总额: '),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Expanded(
                                flex: 1,
                                child: Text(
                                  '',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              const Spacer(
                                flex: 1,
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Text('${tempData['orderprice']}円'),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: myGreyColor,
                              )
                            ],
                          ),
                          onTap: () => {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        orderHistoryDetail(
                                  orderId: widget.orderId,
                                  myPoint: widget.myPoint,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            )
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 5, 10, 0),
                    padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: myGreyColor))),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('邮费:'),
                                  //                            Text('123123123',style: TextStyle(color: myGreyColor),)
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          """最小订单3000円
5000円免邮费""",
                                          style: TextStyle(color: myGreyColor),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: Text('${tempData['freight']}円',
                                              textAlign: TextAlign.right),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 5, 10, 0),
                    padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: myGreyColor))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('支付:'),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'PayPay支付:',
                                      style: TextStyle(color: myGreyColor),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 10, 0),
                                      child: Text(
                                          '${tempData['orderprice'] + tempData['freight'] - 100*tempData['orderpoint']} 円',
                                          textAlign: TextAlign.right),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        '本次使用积分 :',
                                        style: TextStyle(color: myGreyColor),
                                        textAlign: TextAlign.right,
                                      )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 10, 0),
                                      child: Text('${tempData['orderpoint']} 分',
                                          textAlign: TextAlign.right),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '支付总额:',
                                      style: TextStyle(color: myGreyColor),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 10, 0),
                                      child: Text(
                                          '${tempData['orderprice'] + tempData['freight']}円',
                                          textAlign: TextAlign.right),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 5, 10, 0),
                    padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: myGreyColor))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('积分:'),
                              Text(
                                '订单额（税抜）的1%.',
                                style: TextStyle(color: myGreyColor),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '上次积分余额:',
                                      style: TextStyle(color: myGreyColor),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 10, 0),
                                      child: Text('${tempData['totalpoint']}円',
                                          textAlign: TextAlign.right),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '本次使用积分:',
                                      style: TextStyle(color: myGreyColor),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 10, 0),
                                      child: Text(
                                          '${(tempData['orderpoint'] == 0) ? '' : '-'}${tempData['orderpoint']}円',
                                          textAlign: TextAlign.right),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '本次产生积分:',
                                      style: TextStyle(color: myGreyColor),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 10, 0),
                                      child: Text('${tempData['getpoint']}円',
                                          textAlign: TextAlign.right),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '本次积分余额:',
                                      style: TextStyle(color: myGreyColor),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 10, 0),
                                      child: Text(
                                          '${tempData['getpoint'] + tempData['totalpoint'] - tempData['orderpoint']}円',
                                          textAlign: TextAlign.right),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.fromLTRB(15, 20, 0, 0),
                      padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('客户留言:'),
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                            child: Text(
                              '希望肉和鱼都切成片。',
                              style: TextStyle(color: myGreyColor),
                            ),
                          ),
                        ],
                      )),
                  Container(
                      margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                      padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('客服留言:'),
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                            child: Text(
                              '鱼肉切片完毕。',
                              style: TextStyle(color: myGreyColor),
                            ),
                          ),
                        ],
                      )),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.end,
                    // children: [
                    //   const Spacer(),
                    //   Padding(
                    //     padding: const EdgeInsets.only(right: 10.0),
                    //     child: ElevatedButton(
                    //       style: ButtonStyle(
                    //         backgroundColor:
                    //             MaterialStateProperty.all(Colors.black),
                    //       ),
                    //       child: Text('再 次 购 买',
                    //           style: Theme.of(context)
                    //               .textTheme
                    //               .headlineSmall
                    //               .copyWith(
                    //                 color: Colors.white,
                    //                 fontSize: 15.0,
                    //               )),
                    //       onPressed: () => {
                    //         showDialog(
                    //             context: context,
                    //             builder: (BuildContext Dialogcontext) {
                    //               return AlertDialog(
                    //                   title: Column(
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.stretch,
                    //                 children: [
                    //                   Text("本次订单放到购物车。确定要再次购买吗？",
                    //                       textAlign: TextAlign.center,
                    //                       style: Theme.of(context)
                    //                           .textTheme
                    //                           .bodyMedium),
                    //                   const SizedBox(
                    //                     height: 20,
                    //                   ),
                    //                   Center(
                    //                       child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.spaceEvenly,
                    //                     children: [
                    //                       Container(
                    //                         color: Colors.black,
                    //                         child: TextButton(
                    //                           child: Text('确定',
                    //                               style: Theme.of(context)
                    //                                   .textTheme
                    //                                   .bodyMedium
                    //                                   .copyWith(
                    //                                       color: Colors.white)),
                    //                           onPressed: () async {
                    //                             SharedPreferences pref =
                    //                                 await SharedPreferences
                    //                                     .getInstance();
                    //                             var response = await http.put(
                    //                               Uri.parse(
                    //                                   '$serverUrl/api/reorders/${widget.orderId}'),
                    //                               headers: {
                    //                                 'Authorization':
                    //                                     pref.getString('token')
                    //                               },
                    //                             );
                    //                             if (response.statusCode ==
                    //                                 200) {
                    //                               Navigator.pop(Dialogcontext);
                    //                               print('success');
                    //                             } else {}
                    //                           },
                    //                         ),
                    //                       ),
                    //                       Container(
                    //                           color: Colors.black,
                    //                           child: TextButton(
                    //                             child: Text('取消',
                    //                                 style: Theme.of(context)
                    //                                     .textTheme
                    //                                     .bodyMedium
                    //                                     .copyWith(
                    //                                         color:
                    //                                             Colors.white)),
                    //                             onPressed: () => {
                    //                               Navigator.pop(Dialogcontext),
                    //                             },
                    //                           ))
                    //                     ],
                    //                   )),
                    //                 ],
                    //               ));
                    //             })
                    //       },
                    //     ),
                    //   ),
                    // ],
                  // ),
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
