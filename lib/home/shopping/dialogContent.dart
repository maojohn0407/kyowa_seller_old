import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final Map sendingData;

  dialogContent({Key key, this.whichPage, this.categoryType, this.categoryId, this.sendingData})
      : super(key: key);
  @override
  _dialogContentState createState() => _dialogContentState();
}

class _dialogContentState extends State<dialogContent> with SingleTickerProviderStateMixin {
  //@description about whereCursor
  // 0: Default
  // 1: Price
  // 2: Saled
  // 3: Name
  //@description about DESC
  // 0: asc
  // 1: desc
  int whereCursor = 0;
  bool DESC = true;
  int getCountForDrop = 0, cartCount = 0;
  AnimationController _controller;
  Animation<double> animation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _controller.addListener(() {
      setState(() {
        //do something
      });
    });
    animation = Tween<double>(begin: 1.0, end: 3).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String productName = '', lprice = '', hprice = '';
  var temp = [];
  List<Widget> buttonGroup = [];

  int flag = 0;

  Widget isMedia(Map checkVal) {
    if (checkVal['medias'] == null || checkVal['medias'].length == 0)
      return Text(
        '',
        style: TextStyle(color: Colors.transparent),
      );
    else
      return Container(
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Icon(
          Icons.arrow_right,
          color: Colors.white,
        ),
      );
  }

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
                                SharedPreferences prefs = await SharedPreferences.getInstance();

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
                                debugPrint("*** Search Result = ${response.body}");
                                if (response.statusCode == 200) {
                                  //array rearrange so that make convenient for the display buttons
                                  var responseBody = [];
                                  String categoryName = '';
                                  responseBody =json.decode(response.body)['data'];

                                  setState(() {
                                    whereCursor = 0;
                                    DESC = true;
                                    temp = responseBody;
                                    cartCount = prefs.getInt('cartCount');
                                  });
                                } else {
                                  print('您的网络有问题。');
                                }
                              }),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      //itemList start
                      child:
                      (temp.length ==0) ? Center(child: Text('您的搜索中没有产品。'),) :
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border(
                                    bottom: BorderSide(width: 1, color: myBlueColor))),
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                    child: Row(
                                      children: [
                                        Text('默认排序 '),
                                        (whereCursor == 0)
                                            ? Icon(
                                          (DESC)
                                              ? Icons.thumb_down_alt_outlined
                                              : Icons.thumb_up_alt_outlined,
                                          color: Colors.black,
                                          size: 20,
                                        )
                                            : Text(' ')
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    if (whereCursor == 0)
                                      setState(() {
                                        DESC = !DESC;
                                      });
                                    else
                                      setState(() {
                                        whereCursor = 0;
                                        DESC = true;
                                      });
                                    SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                    // New fetching code
                                    var body;
                                    if (widget.categoryType == 'entire') {
                                      body = {
                                        'content': '${productName}',
                                        'lprice': '${lprice}',
                                        'hprice': '${hprice}',
                                        'field' : 'order',
                                        'order' : (DESC ? 'desc' : 'asc')
                                      };
                                    }
                                    if (widget.categoryType == 'parent') {
                                      body = {
                                        'content': '${productName}',
                                        'lprice': '${lprice}',
                                        'hprice': '${hprice}',
                                        'pcategory': '${widget.categoryId}',
                                        'field' : 'order',
                                        'order' : (DESC ? 'desc' : 'asc')
                                      };
                                    }
                                    if (widget.categoryType == 'child') {
                                      body = {
                                        'content': '${productName}',
                                        'lprice': '${lprice}',
                                        'hprice': '${hprice}',
                                        'category': '${widget.categoryId}',
                                        'field' : 'order',
                                        'order' : (DESC ? 'desc' : 'asc')
                                      };
                                    }
                                    var response = await http.post(
                                        Uri.parse(serverUrl + '/api/search'),
                                        body: body);
                                    if (response.statusCode == 200) {
                                      //array rearrange so that make convenient for the display buttons
                                      var responseBody = [];
                                      responseBody = json.decode(response.body)['data'];
                                      setState(() {
                                        temp = responseBody;
                                      });
                                    } else {
                                      print('您的网络有问题。');
                                    }
                                    //   end of new fetching code
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                    child: Row(
                                      children: [
                                        Text('价格排序 '),
                                        (whereCursor == 1)
                                            ? Icon(
                                          (DESC)
                                              ? Icons.thumb_down_alt_outlined
                                              : Icons.thumb_up_alt_outlined,
                                          color: Colors.black,
                                          size: 20,
                                        )
                                            : Text(' ')
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    if (whereCursor == 1)
                                      setState(() {
                                        DESC = !DESC;
                                      });
                                    else
                                      setState(() {
                                        whereCursor = 1;
                                        DESC = true;
                                      });
                                    SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                    // New fetching code
                                    var body;
                                    if (widget.categoryType == 'entire') {
                                      body = {
                                        'content': '${productName}',
                                        'lprice': '${lprice}',
                                        'hprice': '${hprice}',
                                        'field' : 'price',
                                        'order' : (DESC ? 'desc' : 'asc')
                                      };
                                    }
                                    if (widget.categoryType == 'parent') {
                                      body = {
                                        'content': '${productName}',
                                        'lprice': '${lprice}',
                                        'hprice': '${hprice}',
                                        'pcategory': '${widget.categoryId}',
                                        'field' : 'price',
                                        'order' : (DESC ? 'desc' : 'asc')
                                      };
                                    }
                                    if (widget.categoryType == 'child') {
                                      body = {
                                        'content': '${productName}',
                                        'lprice': '${lprice}',
                                        'hprice': '${hprice}',
                                        'category': '${widget.categoryId}',
                                        'field' : 'price',
                                        'order' : (DESC ? 'desc' : 'asc')
                                      };
                                    }
                                    var response = await http.post(
                                        Uri.parse(serverUrl + '/api/search'),
                                        body: body);
                                    if (response.statusCode == 200) {
                                      //array rearrange so that make convenient for the display buttons
                                      var responseBody = [];
                                      responseBody = json.decode(response.body)['data'];
                                      setState(() {
                                        temp = responseBody;
                                      });
                                    } else {
                                      print('您的网络有问题。');
                                    }
                                    //   end of new fetching code
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                    child: Row(
                                      children: [
                                        Text('销量排序 '),
                                        (whereCursor == 4)
                                            ? Icon(
                                          (DESC)
                                              ? Icons.thumb_down_alt_outlined
                                              : Icons.thumb_up_alt_outlined,
                                          color: Colors.black,
                                          size: 20,
                                        )
                                            : Text(' ')
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    if (whereCursor == 4)
                                      setState(() {
                                        DESC = !DESC;
                                      });
                                    else
                                      setState(() {
                                        whereCursor = 4;
                                        DESC = true;
                                      });
                                    SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                    // New fetching code
                                    var body;
                                    if (widget.categoryType == 'entire') {
                                      body = {
                                        'content': '${productName}',
                                        'lprice': '${lprice}',
                                        'hprice': '${hprice}',
                                        'field' : 'order_qty',
                                        'order' : (DESC ? 'desc' : 'asc')
                                      };
                                    }
                                    if (widget.categoryType == 'parent') {
                                      body = {
                                        'content': '${productName}',
                                        'lprice': '${lprice}',
                                        'hprice': '${hprice}',
                                        'pcategory': '${widget.categoryId}',
                                        'field' : 'order_qty',
                                        'order' : (DESC ? 'desc' : 'asc')
                                      };
                                    }
                                    if (widget.categoryType == 'child') {
                                      body = {
                                        'content': '${productName}',
                                        'lprice': '${lprice}',
                                        'hprice': '${hprice}',
                                        'category': '${widget.categoryId}',
                                        'field' : 'order_qty',
                                        'order' : (DESC ? 'desc' : 'asc')
                                      };
                                    }
                                    var response = await http.post(
                                        Uri.parse(serverUrl + '/api/search'),
                                        body: body);
                                    if (response.statusCode == 200) {
                                      //array rearrange so that make convenient for the display buttons
                                      var responseBody = [];
                                      responseBody = json.decode(response.body)['data'];
                                      setState(() {
                                        temp = responseBody;
                                      });
                                    } else {
                                      print('您的网络有问题。');
                                    }
                                    //   end of new fetching code
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                    child: Row(
                                      children: [
                                        Text('名称排序 '),
                                        (whereCursor == 3)
                                            ? Icon(
                                          (DESC)
                                              ? Icons.thumb_down_alt_outlined
                                              : Icons.thumb_up_alt_outlined,
                                          color: Colors.black,
                                          size: 20,
                                        )
                                            : Text(' ')
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    if (whereCursor == 3)
                                      setState(() {
                                        DESC = !DESC;
                                      });
                                    else
                                      setState(() {
                                        whereCursor = 3;
                                        DESC = true;
                                      });
                                    SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                    // New fetching code
                                    var body;
                                    if (widget.categoryType == 'entire') {
                                      body = {
                                        'content': '${productName}',
                                        'lprice': '${lprice}',
                                        'hprice': '${hprice}',
                                        'field' : 'name',
                                        'order' : (DESC ? 'desc' : 'asc')
                                      };
                                    }
                                    if (widget.categoryType == 'parent') {
                                      body = {
                                        'content': '${productName}',
                                        'lprice': '${lprice}',
                                        'hprice': '${hprice}',
                                        'pcategory': '${widget.categoryId}',
                                        'field' : 'name',
                                        'order' : (DESC ? 'desc' : 'asc')
                                      };
                                    }
                                    if (widget.categoryType == 'child') {
                                      body = {
                                        'content': '${productName}',
                                        'lprice': '${lprice}',
                                        'hprice': '${hprice}',
                                        'category': '${widget.categoryId}',
                                        'field' : 'name',
                                        'order' : (DESC ? 'desc' : 'asc')
                                      };
                                    }
                                    var response = await http.post(
                                        Uri.parse(serverUrl + '/api/search'),
                                        body: body);
                                    if (response.statusCode == 200) {
                                      //array rearrange so that make convenient for the display buttons
                                      var responseBody = [];
                                      responseBody = json.decode(response.body)['data'];
                                      setState(() {
                                        temp = responseBody;
                                      });
                                    } else {
                                      print('您的网络有问题。');
                                    }
                                    //   end of new fetching code
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                              child:
                              GridView.extent(
                                maxCrossAxisExtent: 200,
                                children: temp.map((product) => GestureDetector(
                                  child: Column(
                                    children: [
                                      Expanded(
                                          child: Container(
                                            margin: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: myBlueColor),
                                            ),
                                            child: Stack(
                                              children: [
                                                (product['images'] == null)
                                                    ? Image.asset(
                                                  'assets/images/logo.png',
                                                  height: 180,
                                                  fit: BoxFit.cover,
                                                )
                                                    : Image.network(
                                                  serverUrl +
                                                      environment[
                                                      'image_url'] +
                                                      product['images'][0]
                                                      ['image_src'],
                                                  height: 180,
                                                  fit: BoxFit.cover,
                                                ),
//                            Positioned(child: Image.asset('assets/images/logo.png'),top: 0,left: 0,height: 30,width: 30,),
                                                Positioned(
                                                    child: Text(
                                                      product['retailsale']
                                                          .toString() +
                                                          '円',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          .copyWith(
                                                          color:
                                                          Colors.red),
                                                    ),
                                                    bottom: 5,
                                                    left: 5),
                                                Positioned(
                                                  child: heartButton(
                                                    product: product,
                                                  ),
                                                  top: 10,
                                                  right: 13,
                                                  height: 25,
                                                  width: 25,
                                                ),
                                                Positioned(
                                                  child: isMedia(product),
                                                  top: 40,
                                                  right: 13,
                                                  height: 25,
                                                  width: 25,
                                                ),
                                              ],
                                            ),
                                          )),
                                      Text(product['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2)
                                    ],
                                  ),
                                  onTap: () async {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation1,
                                            animation2) =>
                                            Detail(
                                              productId: product['id'],
                                              exploringData: widget.sendingData,
                                            ),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                        Duration.zero,
                                      ),
                                    );
                                  },
                                ))
                                    .toList(),
                              )),
                        ],
                      ),)
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
//@desc: the class for the heart button of the product item
//@params: product data

class heartButton extends StatefulWidget {
  Map product;
  int isAdded;
  heartButton({Key key, this.product}) : super(key: key);
  @override
  _heartButtonState createState() => _heartButtonState();
}

class _heartButtonState extends State<heartButton> {
  int flag = 0, originalFlag, count = 0;
  Widget build(BuildContext context) {
    originalFlag = (widget.product['favorites'] == null ||
        widget.product['favorites'].length == 0)
        ? 0
        : 1;
    calculateFlag() {
      if (count == 0) flag = originalFlag;
      count++;
      return flag;
    }

    return (calculateFlag() == 1)
        ? Icon(
      Icons.favorite,
      color: myBlueColor,
      size: 25,
    )
//      Image.asset('assets/images/heart_full.png',width: 18,height: 18,)
        : GestureDetector(
      child: Icon(
        Icons.favorite_border,
        color: myBlueColor,
        size: 25,
      ),
//      Image.asset('assets/images/heart-empty.png',width: 18,height: 18,),
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var response = await http.post(
            Uri.parse(serverUrl +
                '/api/product/' +
                widget.product['id'].toString() +
                '/favorite'),
            headers: {'Authorization': prefs.getString('token')});
        if (response.statusCode == 200) {
          if (json.decode(response.body)['message'] ==
              'Favorite Successful') {
            setState(() {
              flag = 1;
            });
          } else {
            print('failed to add to the favorite');
          }
        } else {
          showDialog(
              context: context,
              builder: (BuildContext Dialogcontext) {
                return AlertDialog(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                            "You have to signin to add favorites.Do you want to signin?",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyText2),
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.popAndPushNamed(context, '/login',
                                        arguments: '/home');
                                  },
                                  // color: myBlueColor,
                                  child: Text('Signin',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
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
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(Dialogcontext);
                                  },
                                  // color: myBlueColor,
                                  child: Text('No',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
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
                              ],
                            ))
                      ],
                    ));
              });
        }
      },
    );
  }
}
