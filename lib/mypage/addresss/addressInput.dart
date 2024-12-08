import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../env.dart';
import '../../tokenValidate.dart';
import '../../BottomNav.dart';
import 'addressList.dart';

class addressInput extends StatefulWidget {
  final String phoneNumber;
  addressInput({Key key, this.phoneNumber}) : super(key: key);
  @override
  _addressInputState createState() => _addressInputState();
}

class _addressInputState extends State<addressInput> {
  SharedPreferences pref;
  String name = '', mailNo = '', address = '', buildingName = '';
  int delivery_type = 0;
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextEditingController _phone =
        TextEditingController(text: widget.phoneNumber);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            iconTheme:
                Theme.of(context).iconTheme.copyWith(color: Colors.black),
            shadowColor: Colors.transparent,
            backgroundColor: myGreyColor,
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
            title: Row(
              children: [
                Spacer(
                  flex: 1,
                ),
                Container(
                    child: Text("我的 > 地址 > 新增",
                        style: TextStyle(color: Colors.black))),
                Spacer(
                  flex: 2,
                ),
              ],
            )),
        body: ListView(
          children: [
            // Container(
            //   margin: EdgeInsets.fromLTRB(20, 15, 10, 0),
            //   padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            //   decoration: BoxDecoration(
            //       border:
            //           Border(bottom: BorderSide(width: 1, color: myGreyColor))),
            //   child: Row(
            //     children: [
            //       SizedBox(
            //         width: 50,
            //         child: Text('电话:' + ' ',
            //             style: Theme.of(context)
            //                 .textTheme
            //                 .bodyText1
            //                 .copyWith(color: Colors.black)),
            //       ),
            //       Expanded(
            //           child: TextField(
            //         controller: _phone,
            //         enabled: false,
            //         textAlign: TextAlign.start,
            //         decoration: InputDecoration(
            //           alignLabelWithHint: true,
            //           border: OutlineInputBorder(borderSide: BorderSide.none),
            //           isCollapsed: true,
            //           contentPadding: EdgeInsets.all(2),
            //         ),
            //       ))
            //     ],
            //   ),
            // ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 15, 10, 0),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(width: 1, color: myGreyColor))),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text('姓名:' + ' ',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Colors.black)),
                  ),
                  Expanded(
                      child: TextField(
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            hintText: '请输入收件人姓名',
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            isCollapsed: true,
                            contentPadding: EdgeInsets.all(2),
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
                  border:
                      Border(bottom: BorderSide(width: 1, color: myGreyColor))),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text('邮编:' + ' ',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Colors.black)),
                  ),
                  Expanded(
                      child: TextField(
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            hintText: '请输入连续的7位数字',
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            isCollapsed: true,
                          ),
                          onChanged: (String val) => {
                                setState(() {
                                  mailNo = val;
                                })
                              }),
                    flex: 5,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: TextButton(
                      // color: myBlueColor,
                      // disabledColor: Color.fromRGBO(79, 129, 189, 0.5),
                      onPressed: () async {
                        pref = await SharedPreferences.getInstance();
                        var response = await http.get(Uri.parse("https://zipcloud.ibsnet.co.jp/api/search?zipcode=$mailNo"));
                        if (response.statusCode == 200) {
                          var resp = jsonDecode(response.body)["results"];
                          debugPrint("Address = $resp");
                          if (resp != null && resp.isNotEmpty) {
                            var result = resp[0];
                            address = '${result['address1']}${result['address2']}${result['address3']}';
                            _addressController.text = address.trim();
                          }
                        } else {
                          print('无法獲得地址。');
                        }
                      },
                      child: Text('搜索',
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
              margin: EdgeInsets.fromLTRB(20, 15, 10, 0),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(width: 1, color: myGreyColor))),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text('地址:' + ' ',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Colors.black)),
                  ),
                  Expanded(
                      child: TextField(
                          controller: _addressController,
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            hintText: '输入邮编会自动显示',
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            isCollapsed: true,
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
                  border:
                      Border(bottom: BorderSide(width: 1, color: myGreyColor))),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text('建物名:' + ' ',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Colors.black)),
                  ),
                  Expanded(
                      child: TextField(
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            hintText: '请输入建筑物名，屋号',
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            isCollapsed: true,
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
                  border:
                      Border(bottom: BorderSide(width: 1, color: myGreyColor))),
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
                              Text('审查? ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(color: Colors.black)),
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
                                      Text("您的地址需要管理员批准。请等待批准。",
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
                                            // disabledColor: myGreyColor,
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
//                          );
                                })
                          },
                        ),
                      )),
                  Text('未审查',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: Colors.red))
                ],
              ),
            ),
            // Container(
            //   margin: EdgeInsets.fromLTRB(20, 10, 10, 0),
            //   padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            //   decoration: BoxDecoration(
            //       border:
            //           Border(bottom: BorderSide(width: 1, color: myGreyColor))),
            //   child: Row(
            //     children: [
            //       const SizedBox(
            //         width: 50,
            //         child: const Text(
            //           '运输方式',
            //           style: TextStyle(color: Colors.black),
            //         ),
            //       ),
            //       Expanded(
            //           child: Row(
            //         children: [
            //           Expanded(
            //             flex: 1,
            //             child: ListTile(
            //               horizontalTitleGap: 0,
            //               title: const Text(
            //                 'Yamato便',
            //                 style: TextStyle(fontSize: 12),
            //               ),
            //               leading: Radio<int>(
            //                 value: 0,
            //                 groupValue: delivery_type,
            //                 onChanged: (int value) {
            //                   setState(() {
            //                     delivery_type = value;
            //                   });
            //                 },
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             flex: 1,
            //             child: ListTile(
            //                 horizontalTitleGap: 0,
            //                 title: const Text(
            //                   '京和便',
            //                   style: TextStyle(fontSize: 12),
            //                 ),
            //                 leading: Radio<int>(
            //                   value: 1,
            //                   groupValue: delivery_type,
            //                   onChanged: (int value) {
            //                     setState(() {
            //                       delivery_type = value;
            //                     });
            //                   },
            //                 )),
            //           )
            //         ],
            //       ))
            //     ],
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: TextButton(
                    // color: myBlueColor,
                    // disabledColor: Color.fromRGBO(127, 127, 127, 1.0),
                    child: Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(12, 7, 12, 7),
                          child: Text(
                            '保存',
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                    onPressed: (widget.phoneNumber == null ||
                            name.length == 0 ||
                            mailNo.length == 0 ||
                            address.length == 0 ||
                            buildingName.length == 0)
                        ? null
                        : () async {
                            pref = await SharedPreferences.getInstance();
                            var a = {
                              'phone': '12222',
                              'name': '${name}',
                              'email_number': '${mailNo}',
                              'area_name': '${address}',
                              'building_name': '${buildingName}',
                              'delivery_type': '${delivery_type}'
                            };
                            debugPrint("*** Address = $a");
                            var response = await http.post(
                                Uri.parse(serverUrl + '/api/address'),
                                headers: {
                                  'Authorization': pref.getString('token')
                                },
                                body: {
                                  'phone': '12222',
                                  'name': '${name}',
                                  'email_number': '${mailNo}',
                                  'area_name': '${address}',
                                  'building_name': '${buildingName}',
                                  'delivery_type': '${delivery_type}'
                                });
                            debugPrint("*** Address = ${response.statusCode}");
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
                                            "已成功创建您的地址。 \n请等待您的地址验证完成。",
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
                                                  Navigator.pushNamed(
                                                      context, '/addressList'),
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
                )
              ],
            )
          ],
        ),
        bottomNavigationBar: BottomNav(
          pageName: 'mypage',
        ));
  }
}
