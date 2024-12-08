import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../env.dart';
import 'detail.dart';
import 'exploring.dart';

//@author:Yaroslav
//@date:2022-2-8
//@desc:returns true if we have to go to the signin screen and returns token if we have correct token in shared preferences
//@params: -whichPage:the page Name that called this class  -categoryId:the category id will be used during search

class dialogContent extends StatefulWidget {
  String whichPage, categoryType;
  int categoryId;

  dialogContent({Key key, this.whichPage, this.categoryType, this.categoryId})
      : super(key: key);
  @override
  _dialogContentState createState() => _dialogContentState();
}

class _dialogContentState extends State<dialogContent> {
  String productName = '', lprice = '', hprice = '';
  var temp = [];
  List<Widget> buttonGroup = [];

  int flag = 0;

  Widget build(BuildContext context) {
    TextEditingController _name, _from, _to;
    Map sendingData;
    var searchTemp = [];
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            Expanded(
                child: GestureDetector(
              child: null,
              onTap: () => Navigator.pop(context),
            )),
            Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.fromLTRB(0, 15, 15, 0),
                    decoration: BoxDecoration(),
                    child: GestureDetector(
                      child: Icon(
                        Icons.clear,
                        size: 20,
                      ),
                      onTap: () => {Navigator.pop(context)},
                    ),
                  ),
                  Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: (widget.whichPage == 'mainHome')
                          ? Text(
                              '查询所有商品',
                              style: Theme.of(context).textTheme.caption,
                            )
                          : Text(
                              '查询所有商品 -[' + widget.whichPage + ']',
                              style: Theme.of(context).textTheme.caption,
                            )),
                  Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: TextField(
                          controller: _name,
                          decoration: InputDecoration(
                              hintText: '输入商品名，或者，分类的名称',
                              isCollapsed: true,
                              contentPadding: EdgeInsets.all(10),
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(color: Colors.grey),
//                            labelText: 'item name',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: myBlueColor,
                                  ),
                                  borderRadius: BorderRadius.circular(5))),
                          onChanged: (String val) => {
                                setState(() {
                                  productName = val;
                                })
                              })),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            flex: 2,
                            child: TextField(
                                keyboardType: TextInputType.number,
                                controller: _from,
                                decoration: InputDecoration(
                                    hintText: '最低价',
                                    isCollapsed: true,
                                    contentPadding: EdgeInsets.all(10),
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(color: Colors.grey),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: myBlueColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                onChanged: (String val) => {
                                      setState(() {
                                        lprice = val;
                                      })
                                    })),
                        Expanded(flex: 1, child: Text('  ~  ')),
                        Expanded(
                            flex: 2,
                            child: TextField(
                                controller: _to,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: '最高价',
                                    isCollapsed: true,
                                    contentPadding: EdgeInsets.all(10),
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(color: Colors.grey),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: myBlueColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                onChanged: (String val) => {
                                      setState(() {
                                        hprice = val;
                                      })
                                    })),
                        Spacer(
                          flex: 1,
                        ),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                              // color: myBlueColor,
                              // textColor: Colors.white,
                              // elevation: 0,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(0, 7, 0, 7),
                                child: Text(
                                  '收索',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.only(
                              //     topLeft: Radius.circular(4.0),
                              //     topRight: Radius.circular(4.0),
                              //     bottomLeft: Radius.circular(4.0),
                              //     bottomRight: Radius.circular(4.0),
                              //   ),
                              // ),
                              onPressed: () async {
                                //search body
                                String category, pcategory;
                                var body;
                                if (widget.categoryType == 'entire') {
                                  body = {
                                    'content': '${productName}',
                                    'lprice': '${lprice}',
                                    'hprice': '${hprice}'
                                  };
                                }
                                if (widget.categoryType == 'parent') {
                                  body = {
                                    'content': '${productName}',
                                    'lprice': '${lprice}',
                                    'hprice': '${hprice}',
                                    'pcategory': '${widget.categoryId}'
                                  };
                                }
                                if (widget.categoryType == 'child') {
                                  body = {
                                    'content': '${productName}',
                                    'lprice': '${lprice}',
                                    'hprice': '${hprice}',
                                    'category': '${widget.categoryId}'
                                  };
                                }
                                var response = await http.post(
                                    Uri.parse(serverUrl + '/api/search'),
                                    body: body);
                                if (response.statusCode == 200) {
                                  //array rearrange so that make convenient for the display buttons
                                  var responseBody = [];
                                  var temp = [];
                                  String categoryName = '';
                                  responseBody =
                                      json.decode(response.body)['data'];
                                  int index = 0;
                                  //this is used for convenient json search data
                                  responseBody.forEach((e) => {
                                        index++,
                                        if (index == 1)
                                          categoryName =
                                              e['category_id'].toString(),
                                        if (categoryName ==
                                            e['category_id'].toString())
                                          {
                                            temp.add(e),
                                          }
                                        else
                                          {
                                            categoryName =
                                                e['category_id'].toString(),
                                            searchTemp.add(temp),
                                            temp = [],
                                            temp.add(e)
                                          },
                                        if (index == responseBody.length)
                                          {
                                            searchTemp.add(temp),
                                          }
                                      });
                                } else {
                                  print('您的网络有问题。');
                                }

                                setState(() {
                                  //@desc: when buttonGroup have changed the screen will be rendered again.It contains all necessary
                                  //        buttons that represents small category and also products
                                  //@params: searchTemp data-i have rearraned data from web server and it is inserted to the searchTemp
                                  buttonGroup = searchTemp
                                      .map((e) => Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: TextButton(
                                                  // color: myBlueColor,
                                                  // textColor: Colors.white,
                                                  onPressed: () => {
                                                    sendingData = {
                                                      'id': e[0]['category_id'],
                                                      'p_id': e[0]['category']
                                                          ['p_id']
                                                    },
                                                    Navigator.pushReplacement(
                                                      context,
                                                      PageRouteBuilder(
                                                        pageBuilder: (context,
                                                                animation1,
                                                                animation2) =>
                                                            exploring(
                                                                sendingData:
                                                                    sendingData),
                                                        transitionDuration:
                                                            Duration.zero,
                                                        reverseTransitionDuration:
                                                            Duration.zero,
                                                      ),
                                                    ),
                                                  },
                                                  child: Text(
                                                      e[0]['category']
                                                              ['parent_name'] +
                                                          " > " +
                                                          e[0]['category']
                                                              ['name'],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .caption
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
                                                alignment: Alignment.topLeft,
                                                margin: EdgeInsets.fromLTRB(
                                                    20, 0, 20, 0),
                                              ),
                                              buttonInnerGroup(receivingData: e)
                                            ],
                                          ))
                                      .toList();
                                });
                              }),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: ListView(
                    children: buttonGroup,
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

//@author:Yaroslav
//@date:2022-2-11
//@desc: buttonInnerGroup is button array that is included inside the child category
//@params: product array which is included in the same child-category

class buttonInnerGroup extends StatelessWidget {
  final List<dynamic> receivingData;
  buttonInnerGroup({this.receivingData});
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 40),
        //@desc:(receivingData.length/3).ceil() --> means the number of button layers for example if there are 7 buttons it is 3
        //      (MediaQuery.of(context).size.width-70)/9.ceil()+15 -->here 15 is margin and  (MediaQuery.of(context).size.width-70)/9 means height of one button..
        //      here button height is 1/3 of the width and there are 3 buttons,so the height of the button can calculated from width of the screen.
        height: ((MediaQuery.of(context).size.width - 70) / 9.ceil() + 15) *
            ((receivingData.length / 3).ceil()),
        child: GridView.count(
          crossAxisCount: 3,
          children: receivingData
              .map((baby) => Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                    child: TextButton(
                      // color: myBlueColor,
                      // textColor: Colors.white,
                      onPressed: () => {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                Detail(
                              productId: baby['id'],
                              exploringData: {'id': -4},
                            ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        )
                      },
                      child: Text(baby['name'],
                          style: Theme.of(context)
                              .textTheme
                              .caption
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
                  ))
              .toList(),
          childAspectRatio: 3,
        ));
  }
}
