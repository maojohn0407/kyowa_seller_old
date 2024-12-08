import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../env.dart';
import '../../tokenValidate.dart';
import '../../BottomNav.dart';
import 'addressList.dart';

class addressConfirm extends StatefulWidget {
  final String addressId;
  addressConfirm({Key key, this.addressId}) : super(key: key);
  addressConfirmState createState() => addressConfirmState();
}

class addressConfirmState extends State<addressConfirm> {
  SharedPreferences pref;
  int getCount = 0,
      cartCount =
          0; //getCount is used to call getJson() only once,and cartCount is used for the cart button on BottomNavbar
  String phone, name, mailNo, address, buildingName;
  bool is_received = false;
  int deliveryType;
  var deliverys = [];
  int deliveryId = 0;
  TextEditingController _phone, _name, _mailNo, _address, _buildingName;

  getJson() async {
    getCount++;
    if (getCount == 1) {
      await validateLogin(context, '/addressConfirm');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final appJson = await http.get(
          Uri.parse(serverUrl + '/api/address/' + widget.addressId.toString()),
          headers: {'Authorization': prefs.getString('token')});
      setState(() {
        if (appJson.statusCode == 200) {
          debugPrint("*** ${appJson.body}");
          is_received = true;
          deliverys = json.decode(appJson.body)['deliverys'];
          tempData = json.decode(appJson.body)['data'];
          phone = tempData[0]['phone'].toString();
          deliveryId = tempData[0]['deliverymethod'];
          name = tempData[0]['name'].toString();
          deliveryType = tempData[0]['delivery_type'];
          mailNo = tempData[0]['email_number'].toString();
          address = tempData[0]['area_name'].toString();
          buildingName = tempData[0]['building_name'].toString();
          _phone = TextEditingController(text: phone);
          _name = TextEditingController(text: name);
          _mailNo = TextEditingController(text: mailNo);
          _address = TextEditingController(text: address);
          _buildingName = TextEditingController(text: buildingName);
        } else
          print('Cannot connect to server');
      });
    } else
      print('No data from previous screen!');
  }

  var tempData;

  Widget build(BuildContext context) {
    getJson();
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
                  child: Text("我的 > 地址 > 查看",
                      style: TextStyle(color: Colors.black)),
                ),
                Spacer(
                  flex: 1,
                ),
                // Container(
                //   child: GestureDetector(
                //     child: Icon(
                //       Icons.edit_location_outlined,
                //       size: 20,
                //     ),
                //     onTap: () => {
                //       if (tempData[0]['is_verified'] != 1)
                //         {
                //           showDialog(
                //               context: context,
                //               builder: (BuildContext Dialogcontext) {
                //                 return AlertDialog(
                //                     title: Column(
                //                   crossAxisAlignment:
                //                       CrossAxisAlignment.stretch,
                //                   children: [
                //                     Text(
                //                         "一旦您的地址被传递给管理员用户，您就无法更正信息。",
                //                         textAlign: TextAlign.center,
                //                         style: Theme.of(context)
                //                             .textTheme
                //                             .bodyText2),
                //                     SizedBox(
                //                       height: 20,
                //                     ),
                //                     Center(
                //                         child: Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.spaceEvenly,
                //                       children: [
                //                         TextButton(
                //                           onPressed: () {
                //                             Navigator.pop(Dialogcontext);
                //                           },
                //                           // color: myBlueColor,
                //                           child: Text('确定',
                //                               style: Theme.of(context)
                //                                   .textTheme
                //                                   .bodyText2
                //                                   .copyWith(
                //                                       color: Colors.white)),
                //                           style: TextButton.styleFrom(
                //                             backgroundColor: myBlueColor,
                //                             shape: RoundedRectangleBorder(
                //                               borderRadius: BorderRadius.only(
                //                                 topLeft: Radius.circular(4.0),
                //                                 topRight: Radius.circular(4.0),
                //                                 bottomLeft:
                //                                     Radius.circular(4.0),
                //                                 bottomRight:
                //                                     Radius.circular(4.0),
                //                               ),
                //                             ),
                //                           ),
                //                         ),
                //                       ],
                //                     ))
                //                   ],
                //                 ));
                //               })
                //         }
                //       else
                //         {
                //           showDialog(
                //               context: context,
                //               builder: (BuildContext Dialogcontext) {
                //                 return AlertDialog(
                //                     title: Column(
                //                   crossAxisAlignment:
                //                       CrossAxisAlignment.stretch,
                //                   children: [
                //                     Text(
                //                         "If you have modify your address,you have to wait for the company investigation.Are you sure to modify?",
                //                         textAlign: TextAlign.center,
                //                         style: Theme.of(context)
                //                             .textTheme
                //                             .bodyText2),
                //                     SizedBox(
                //                       height: 20,
                //                     ),
                //                     Center(
                //                         child: Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.spaceEvenly,
                //                       children: [
                //                         TextButton(
                //                           onPressed: () async {
                //                             pref = await SharedPreferences
                //                                 .getInstance();
                //                             var response = await http.put(
                //                                 Uri.parse(serverUrl +
                //                                     '/api/address/' +
                //                                     widget.addressId
                //                                         .toString()),
                //                                 headers: {
                //                                   'Authorization':
                //                                       pref.getString('token')
                //                                 },
                //                                 body: {
                //                                   'phone': '${phone}',
                //                                   'name': '${name}',
                //                                   'email_number': '${mailNo}',
                //                                   'area_name': '${address}',
                //                                   'building_name':
                //                                       '${buildingName}'
                //                                 });
                //                             if (response.statusCode == 200) {
                //                               Navigator.pop(Dialogcontext);
                //                               print('success');
                //                               showDialog(
                //                                   context: context,
                //                                   builder: (BuildContext
                //                                       Dialogcontext) {
                //                                     return AlertDialog(
                //                                         title: Column(
                //                                       crossAxisAlignment:
                //                                           CrossAxisAlignment
                //                                               .stretch,
                //                                       children: [
                //                                         Text(
                //                                             "Successfully created your address.Please wait until your address is verified.",
                //                                             textAlign: TextAlign
                //                                                 .center,
                //                                             style: Theme.of(
                //                                                     context)
                //                                                 .textTheme
                //                                                 .bodyText2),
                //                                         SizedBox(
                //                                           height: 20,
                //                                         ),
                //                                         Center(
                //                                             child: Row(
                //                                           mainAxisAlignment:
                //                                               MainAxisAlignment
                //                                                   .spaceEvenly,
                //                                           children: [
                //                                             TextButton(
                //                                               onPressed: () =>
                //                                                   Navigator
                //                                                       .pushReplacement(
                //                                                 context,
                //                                                 PageRouteBuilder(
                //                                                   pageBuilder: (context,
                //                                                           animation1,
                //                                                           animation2) =>
                //                                                       addressList(),
                //                                                   transitionDuration:
                //                                                       Duration
                //                                                           .zero,
                //                                                   reverseTransitionDuration:
                //                                                       Duration
                //                                                           .zero,
                //                                                 ),
                //                                               ),
                //                                               // color:
                //                                               //     myBlueColor,
                //                                               child: Text('确定',
                //                                                   style: Theme.of(
                //                                                           context)
                //                                                       .textTheme
                //                                                       .bodyText2
                //                                                       .copyWith(
                //                                                           color:
                //                                                               Colors.white)),
                //                                               style: TextButton
                //                                                   .styleFrom(
                //                                                 backgroundColor:
                //                                                     myBlueColor,
                //                                                 shape:
                //                                                     RoundedRectangleBorder(
                //                                                   borderRadius:
                //                                                       BorderRadius
                //                                                           .only(
                //                                                     topLeft: Radius
                //                                                         .circular(
                //                                                             4.0),
                //                                                     topRight: Radius
                //                                                         .circular(
                //                                                             4.0),
                //                                                     bottomLeft:
                //                                                         Radius.circular(
                //                                                             4.0),
                //                                                     bottomRight:
                //                                                         Radius.circular(
                //                                                             4.0),
                //                                                   ),
                //                                                 ),
                //                                               ),
                //                                             ),
                //                                           ],
                //                                         ))
                //                                       ],
                //                                     ));
                //                                   });
                //                             } else {
                //                               Navigator.pop(Dialogcontext);
                //                               print(
                //                                   '您的网络有问题。');
                //                               showDialog(
                //                                   context: context,
                //                                   builder: (BuildContext
                //                                       Dialogcontext) {
                //                                     return AlertDialog(
                //                                         title: Column(
                //                                       crossAxisAlignment:
                //                                           CrossAxisAlignment
                //                                               .stretch,
                //                                       children: [
                //                                         Text(
                //                                             "您的网络有问题。",
                //                                             textAlign: TextAlign
                //                                                 .center,
                //                                             style: Theme.of(
                //                                                     context)
                //                                                 .textTheme
                //                                                 .bodyText2),
                //                                         SizedBox(
                //                                           height: 20,
                //                                         ),
                //                                         Center(
                //                                             child: Row(
                //                                           mainAxisAlignment:
                //                                               MainAxisAlignment
                //                                                   .spaceEvenly,
                //                                           children: [
                //                                             TextButton(
                //                                               onPressed: () =>
                //                                                   Navigator.pop(
                //                                                       Dialogcontext),
                //                                               // color:
                //                                               //     myBlueColor,
                //                                               child: Text('确定',
                //                                                   style: Theme.of(
                //                                                           context)
                //                                                       .textTheme
                //                                                       .bodyText2
                //                                                       .copyWith(
                //                                                           color:
                //                                                               Colors.white)),
                //                                               style: TextButton
                //                                                   .styleFrom(
                //                                                 backgroundColor:
                //                                                     myBlueColor,
                //                                                 shape:
                //                                                     RoundedRectangleBorder(
                //                                                   borderRadius:
                //                                                       BorderRadius
                //                                                           .only(
                //                                                     topLeft: Radius
                //                                                         .circular(
                //                                                             4.0),
                //                                                     topRight: Radius
                //                                                         .circular(
                //                                                             4.0),
                //                                                     bottomLeft:
                //                                                         Radius.circular(
                //                                                             4.0),
                //                                                     bottomRight:
                //                                                         Radius.circular(
                //                                                             4.0),
                //                                                   ),
                //                                                 ),
                //                                               ),
                //                                             ),
                //                                           ],
                //                                         ))
                //                                       ],
                //                                     ));
                //                                   });
                //                             }
                //                           },
                //                           // color: myBlueColor,
                //                           child: Text('Yes',
                //                               style: Theme.of(context)
                //                                   .textTheme
                //                                   .bodyText2
                //                                   .copyWith(
                //                                       color: Colors.white)),
                //                           style: TextButton.styleFrom(
                //                             backgroundColor: myBlueColor,
                //                             shape: RoundedRectangleBorder(
                //                               borderRadius: BorderRadius.only(
                //                                 topLeft: Radius.circular(4.0),
                //                                 topRight: Radius.circular(4.0),
                //                                 bottomLeft:
                //                                     Radius.circular(4.0),
                //                                 bottomRight:
                //                                     Radius.circular(4.0),
                //                               ),
                //                             ),
                //                           ),
                //                         ),
                //                         TextButton(
                //                           onPressed: () =>
                //                               Navigator.pop(Dialogcontext),
                //                           // color: myBlueColor,
                //                           child: Text('No',
                //                               style: Theme.of(context)
                //                                   .textTheme
                //                                   .bodyText2
                //                                   .copyWith(
                //                                       color: Colors.white)),
                //                           style: TextButton.styleFrom(
                //                             backgroundColor: myBlueColor,
                //                             shape: RoundedRectangleBorder(
                //                               borderRadius: BorderRadius.only(
                //                                 topLeft: Radius.circular(4.0),
                //                                 topRight: Radius.circular(4.0),
                //                                 bottomLeft:
                //                                     Radius.circular(4.0),
                //                                 bottomRight:
                //                                     Radius.circular(4.0),
                //                               ),
                //                             ),
                //                           ),
                //                         )
                //                       ],
                //                     ))
                //                   ],
                //                 ));
                //               })
                //         }
                //     },
                //   ),
                // )
              ],
            )),
        body: (is_received)
            ? ListView(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 15, 10, 0),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: myGreyColor))),
                    child: Row(
                      children: [
                        Text('姓名:' + ' ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Colors.black)),
                        Expanded(
                            child: TextField(
                                controller: _name,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.all(2),
                                  alignLabelWithHint: true,
                                  hintText: '请输入收件人姓名',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                                onChanged: (String val) => {
                                      setState(() {
                                        name = val;
                                      })
                                    }))
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 15, 10, 0),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: myGreyColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        // First Text: Fixed "交货类型:"
                        Text(
                          '交货类型:' + ' ',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.copyWith(color: Colors.black),
                        ),
                        Expanded(
                          // Second Text: Dynamic text based on deliveryType
                          child: Text(
                            deliveryType == 0
                                ? 'ヤマト便' // If deliveryType is 0, show "Yamato"
                                : deliveryType == 1
                                ? '京和便' // If deliveryType is 1, show "Kyowa"
                                : '未知', // For any other value, show "Unknown"
                            textAlign: TextAlign.end,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 15, 10, 0),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: myGreyColor))),
                    child: Row(
                      children: [
                        Text('邮编:' + ' ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Colors.black)),
                        Expanded(
                            child: TextField(
                                controller: _mailNo,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  hintText: '请输入连续的7位数字',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.all(2),
                                ),
                                onChanged: (String val) => {
                                      setState(() {
                                        mailNo = val;
                                      })
                                    }))
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 15, 10, 0),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: myGreyColor))),
                    child: Row(
                      children: [
                        Text('地址:' + ' ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Colors.black)),
                        Expanded(
                            child: TextField(
                                controller: _address,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  hintText: '输入邮编会自动显示',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.all(2),
                                ),
                                onChanged: (String val) => {
                                      setState(() {
                                        address = val;
                                      })
                                    }))
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 15, 10, 0),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: myGreyColor))),
                    child: Row(
                      children: [
                        Text('建物名:' + ' ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Colors.black)),
                        Expanded(
                            child: TextField(
                                controller: _buildingName,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  hintText: '请输入建筑物名，屋号',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.all(2),
                                ),
                                onChanged: (String val) => {
                                      setState(() {
                                        buildingName = val;
                                      })
                                    }))
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 10, 0),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: myGreyColor))),
                    child: Row(
                      children: [
                        Text('审查状态:',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Colors.black)),
                        Expanded(
                            flex: 4,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                              child: GestureDetector(
                                child: Row(
                                  children: [
                                    Text(
                                      '审查? ',
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: Text(
                                        '?',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () => {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext Dialogcontext) {
                                        return AlertDialog(
                                            title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text("""审查完的地址信息不能直接修改。
想修改地址或删除此地址请跟客服联系。""",
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
                                                    Navigator.pop(
                                                        Dialogcontext);
                                                  },
                                                  // color: myBlueColor,
                                                  child: Text('确定',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .copyWith(
                                                              color: Colors
                                                                  .white)),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        myBlueColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                4.0),
                                                        topRight:
                                                            Radius.circular(
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
                                      })
                                },
                              ),
                            )),
                        (tempData[0]['is_verified'] == 1
                            ? Text(
                                '未审查',
                                style: TextStyle(color: Colors.red),
                              )
                            : Text(
                                '审查完',
                                style: TextStyle(color: myBlueColor),
                              )),
                        Icon(Icons.check,
                            color: (tempData[0]['is_verified'] == 1)
                                ? Colors.transparent
                                : Colors.lightGreenAccent)
                      ],
                    ),
                  ),
                  (tempData[0]['is_verified'] != 1 && deliveryType == 1) ? Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 15, 10, 5),
                        child: Text(
                          '审查结果:',
                          style: TextStyle(color: myBlueColor),
                        ),
                      ),
                      // Wrapping Table with margin
                      Container(
                        margin: EdgeInsets.all(20), // Adds margin around the table
                        child: Table(
                          border: TableBorder.all(), // Optional: Adds borders to the table
                          children: [
                            // Table Header
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('最小订单', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('邮费', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('免费', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ]),
                            // Dynamic rows based on delivery data
                            ...deliverys.map((delivery) {
                              bool isSelected = delivery['id'] == deliveryId; // Check if this is the selected delivery
                              return TableRow(children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  color: isSelected ? Colors.green : Colors.transparent, // Highlight row if selected
                                  child: Text(delivery['min_price'].toString()),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  color: isSelected ? Colors.green : Colors.transparent, // Highlight row if selected
                                  child: Text(delivery['delivery_fee'].toString()),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  color: isSelected ? Colors.green : Colors.transparent, // Highlight row if selected
                                  child: Text(delivery['max_price'].toString()),
                                ),
                              ]);
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ) : Container(child: Text('Nothing', style: TextStyle(color: Colors.transparent),),)
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
