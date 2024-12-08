import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dialogContent.dart';
import '../../env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mainHome.dart';
import '../../mypage/mainMyPage.dart';
import '../../cart/mainCart.dart';
import 'detail.dart';
import 'secondCategory.dart';

class exploring extends StatefulWidget {
  final Map sendingData;
  exploring({Key key, this.sendingData}) : super(key: key);
  @override
  _exploringState createState() => _exploringState();
}

class _exploringState extends State<exploring>
    with SingleTickerProviderStateMixin {
  dynamic flagForBack = false;
  bool isReceivedData = false;

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

  int getCount = 0; //getCount is used to call getJson() only once
  int whereCursor = 0;
  bool DESC = true;

  String selectedParentCategoryName = '', selectedChildCategoryName = '';
  int getCountForDrop = 0, cartCount = 0;
  String currentFirstDropName;

  var tempForDropDown1 = [], tempForDropDown2 = [], temp = [];
  Map sendingData;
  dynamic tempValue;

  getJson() async {
    getCountForDrop++;
    Map receivedData = widget.sendingData;
    if (getCountForDrop == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getInt('cartCount') == null) prefs.setInt('cartCount', 0);
      setState(() {
        isReceivedData = true;
        cartCount = prefs.getInt('cartCount');
        tempForDropDown1 = jsonDecode(prefs.getString('parentCategory'));
        tempForDropDown2 = jsonDecode(prefs.getString('childCategory' + receivedData['p_id'].toString()));
        tempForDropDown1.forEach((element) {
          //set max length of the dropdown
          if (element['id'] == receivedData['p_id']) {
            tempValue = element;
            currentFirstDropName = element['name'];
          }
        });
      });

      String cachedProductsList = prefs.getString('productsList' + receivedData['id'].toString());
      if (cachedProductsList != null && cachedProductsList != '') {
        dynamic json = jsonDecode(cachedProductsList);
        var lastProductsListTime = DateTime.fromMillisecondsSinceEpoch(
            prefs.getInt('lastProductsListTime' + receivedData['id'].toString()) ?? 0);

        // Check time difference
        if (DateTime.now().difference(lastProductsListTime).inMinutes <= 30) {
          setState(() {
            isReceivedData = true;
            temp = json;
          });
          return;
        }
      }

      //data for items
      http.get(Uri.parse(serverUrl + '/api/category/' + receivedData['id'].toString() + '/productslist'),
          headers: {'Authorization': (prefs.getString('token') == null) ? '' : prefs.getString('token')})
          .then((http.Response appJson) async {
            if (appJson.statusCode == 200) {
              var cache = json.decode(appJson.body)['data']['data'] as List<dynamic>;
              if (cache != null && cache != []) {
                await prefs.setString('productsList' + receivedData['id'].toString(), jsonEncode(cache));
                await prefs.setInt('lastProductsListTime' + receivedData['id'].toString(), DateTime.now().millisecondsSinceEpoch);
                setState(() {
                  temp = cache;
                });
              }
            } else
              print('Cannot connect to server');
          });
    }
  }

  Widget isMedia(Map checkVal) {
    if (checkVal['medias'].length == 0)
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
    getJson();
    Map receivedData = widget.sendingData;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          child: Icon(Icons.arrow_back, size: 32.0),
          onTap: () => {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    secondCategory(
                  categoryId: receivedData['p_id'],
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            )
          },
        ),
        shadowColor: Colors.transparent,
        titleSpacing: 0,
        backgroundColor: myBlueColor,
        title: (receivedData == null)
            ? Text(
                'Empty',
                style: TextStyle(color: Colors.transparent),
              )
            : Row(
                children: [
                  DropdownButton<dynamic>(
                    dropdownColor: myBlueColor,
                    value: tempValue,
                    underline: Text(
                      '',
                      style: TextStyle(color: Colors.transparent),
                    ),
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.transparent,
                    ),
                    onChanged: (dynamic newValue) {
                      setState(() {
                        tempValue = newValue;
                      });
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              secondCategory(
                            categoryId: tempValue['id'],
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return tempForDropDown1.map((dynamic value) {
                        return DropdownMenuItem<dynamic>(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                border:
                                    Border.all(color: Colors.white, width: 2)),
                            child: Text(
                              currentFirstDropName,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }).toList();
                    },
                    items: tempForDropDown1
                        .map<DropdownMenuItem<dynamic>>((dynamic value) {
                      return DropdownMenuItem<dynamic>(
                        value: value,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(color: Colors.white, width: 2)),
                          child: (receivedData['p_id'] == value['id'])
                              ? Text(value['name'], style: TextStyle(color: Colors.white,))
                              : Text(value['name'] + '(' + value['p_products_count'].toString() + ')', style: TextStyle(color: Colors.white,)),
                        ),
                      );
                    }).toList(),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24,),
                  SizedBox(width: 15,),

                  DropdownButton<String>(
                    dropdownColor: myBlueColor,
                    underline: Text('under', style: TextStyle(color: Colors.transparent)),
                    icon: Icon(Icons.arrow_forward_ios, size: 0,),
                    iconSize: 0,
                    value: receivedData['id'].toString(),
                    items: tempForDropDown2.map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                            child: GestureDetector(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(color: Colors.white, width: 2)),
                                child: (receivedData['id'] == e['id'])
                                    ? Text(e['name'], style: TextStyle(color: Colors.white))
                                    : Text(e['name'] + ' (' + e['c_products_count'].toString() + ')', style: TextStyle(color: Colors.white)),
                              ),
                              onTap: () => {
                                sendingData = {'id': e['id'], 'p_id': e['p_id']},
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            exploring(
                                      sendingData: sendingData,
                                    ),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                )
                              },
                            ),
                            value: e['id'].toString()))
                        .toList(),
                    onChanged: (String val) => print(val),
                  ),
                  Expanded(
                      child: Text(
                    '',
                    style: TextStyle(color: Colors.transparent),
                  )),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 13, 0),
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
                    ),
                    onTap: () => {
                      tempForDropDown1.forEach((element) {
                        Map receivedData = widget.sendingData;
                        if (element['id'].toString() ==
                            receivedData['p_id'].toString())
                          selectedParentCategoryName = element['name'];
                      }),
                      tempForDropDown2.forEach((element) {
                        Map receivedData = widget.sendingData;
                        if (element['id'].toString() ==
                            receivedData['id'].toString())
                          selectedChildCategoryName = element['name'];
                      }),
                      showDialog<void>(
                          context: context,
                          builder: (BuildContext ctx) {
                            return dialogContent(
                                whichPage: selectedParentCategoryName +
                                    '>' +
                                    selectedChildCategoryName,
                                categoryType: 'child',
                                categoryId: receivedData['id'],
                                sendingData: widget.sendingData,
                            );
                          })
                    },
                  )
                ],
              ),
      ),
      body: (receivedData == null)
          ? Center(
              child: Text(
                'Cannot connect to the server!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(bottom: BorderSide(width: 1, color: myBlueColor))),
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
                                  ? Icon((DESC) ? Icons.thumb_down_alt_outlined : Icons.thumb_up_alt_outlined, color: Colors.black, size: 20,)
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
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          var anotherJson = await http.get(
                              Uri.parse(serverUrl + '/api/category/' + receivedData['id'].toString() + '/productslist?field=order&order=' + (DESC ? 'desc' : 'asc')),
                              headers: {'Authorization': (prefs.getString('token') == null) ? '' : prefs.getString('token')});
                          setState(() {
                            if (anotherJson.statusCode == 200) {
                              temp = json.decode(anotherJson.body)['data']['data'];
                            }
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Row(
                            children: [
                              Text('价格排序 '),
                              (whereCursor == 1) ? Icon((DESC) ? Icons.thumb_down_alt_outlined : Icons.thumb_up_alt_outlined, color: Colors.black, size: 20) : Text(' ')
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
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          var anotherJson = await http.get(Uri.parse(serverUrl + '/api/category/' + receivedData['id'].toString() + '/productslist?field=price&order=' + (DESC ? 'desc' : 'asc')),
                              headers: { 'Authorization': (prefs.getString('token') == null) ? '' : prefs.getString('token') });
                          setState(() {
                            if (anotherJson.statusCode == 200) {
                              temp = json.decode(anotherJson.body)['data']['data'];
                            } else
                              print('Cannot connect to server');
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Row(
                            children: [
                              Text('销量排序 '),
                              (whereCursor == 4)
                                  ? Icon((DESC) ? Icons.thumb_down_alt_outlined : Icons.thumb_up_alt_outlined, color: Colors.black, size: 20,)
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
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          var anotherJson = await http.get(
                              Uri.parse(serverUrl + '/api/category/' + receivedData['id'].toString() + '/productslist?field=order_qty&order=' + (DESC ? 'desc' : 'asc')),
                              headers: {
                                'Authorization': (prefs.getString('token') == null) ? '' : prefs.getString('token')
                              });
                          setState(() {
                            if (anotherJson.statusCode == 200) {
                              temp = json.decode(anotherJson.body)['data']['data'];
                            } else
                              print('Cannot connect to server');
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Row(
                            children: [
                              Text('名称排序 '),
                              (whereCursor == 3) ? Icon((DESC) ? Icons.thumb_down_alt_outlined : Icons.thumb_up_alt_outlined, color: Colors.black, size: 20,) : Text(' ')
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
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          var anotherJson = await http.get(Uri.parse(serverUrl + '/api/category/' + receivedData['id'].toString() + '/productslist?field=name&order=' + (DESC ? 'desc' : 'asc')),
                              headers: {
                                'Authorization': (prefs.getString('token') == null) ? '' : prefs.getString('token')
                              });
                          setState(() {
                            if (anotherJson.statusCode == 200) {
                              temp = json.decode(anotherJson.body)['data']['data'];
                            } else
                              print('Cannot connect to server');
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(child: (temp.length == 0)
                        ? Center(child: (!isReceivedData) ? Image.asset('assets/images/animated_loading.gif') : Text(''),)
                        : GridView.extent(
                            maxCrossAxisExtent: 200,
                            children: temp.map((product) => GestureDetector(
                              child: Column(
                                children: [
                                  Expanded(
                                      child: Container(
                                        margin: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(border: Border.all(color: myBlueColor),),
                                        child: Stack(
                                          children: [
                                            // Product Image
                                            (product['images'].isEmpty)
                                                ? Image.asset('assets/images/logo.png', height: 180, fit: BoxFit.cover)
                                                : Image.network(
                                              serverUrl + environment['image_url'] + product['images'][0]['image_src'],
                                              height: 180,
                                              fit: BoxFit.cover,
                                            ),

                                            // Price Text Positioned at Bottom Left
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              child: Text(
                                                product['retailsale'].toString() + '円',
                                                style: TextStyle(
                                                  color: Colors.red, // White text color
                                                  fontSize: 12, // Optional: Adjust font size
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            // Heart Button Positioned at Top Right
                                            Positioned(
                                              top: 3,
                                              right: 3,
                                              height: 25,
                                              width: 25,
                                              child: heartButton(product: product),
                                            ),

                                            // Media Indicator Positioned at Top Right Below Heart Button
                                            Positioned(
                                              top: 40,
                                              right: 8,
                                              height: 25,
                                              width: 25,
                                              child: isMedia(product),
                                            ),

                                            // New Positioned Text Below Media Indicator
                                            if (product['is_irregular'] == 1)
                                              Positioned(
                                              bottom: 0, // Adjust top position as needed
                                              right: 0,
                                              width: 40,
                                              child: Container(
                                                width: 40,
                                                padding: EdgeInsets.all(0), // Optional: Add padding around the text
                                                color: Colors.red, // Red background color
                                                child: Text(
                                                  "不规则", // Replace with your desired text
                                                  style: TextStyle(
                                                    color: Colors.white, // White text color
                                                    fontSize: 9, // Optional: Adjust font size
                                                  ),
                                                  textAlign: TextAlign.center, // Optional: Center align the text
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                          )),
                                          Text(product['name'], style: Theme.of(context).textTheme.bodyText2)
                                        ],
                                      ),
                                      onTap: () async {
                                        Navigator.pushReplacement(context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1, animation2) =>
                                                Detail(productId: product['id'], exploringData: widget.sendingData,
                                            ),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration: Duration.zero,
                                          ),
                                        );
                                      },
                                    )).toList(),
                          )),
              ],
            ),
        bottomNavigationBar: Container(
        height: 80,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 7),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(width: 2, color: Colors.grey,))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              child: Container(
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 40),
                      child: Icon(Icons.home, color: myBlueColor),
                    ),
                    Positioned(
                      child: Text('首页', style: Theme.of(context).textTheme.caption.copyWith(color: Colors.grey),),
                      bottom: 20,
                      left: 21,
                    )
                  ],
                ),
              ),
              behavior: HitTestBehavior.translucent,
              onTap: () => {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        mainHome(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              },
            ),
            GestureDetector(
              child: Container(
                child: Stack(
                  children: [
                    Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 40),
                        child: Icon(Icons.shopping_cart_outlined,
                            color: Colors.black)),
                    Positioned(
                      child: (cartCount == null || cartCount == 0)
                          ? Text('0', style: TextStyle(color: Colors.transparent),)
                          : AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: animation.value,
                                  child: InkWell(
                                      onTap: () {
                                        //_controller.forward();
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                        child: Text(cartCount.toString(), style: TextStyle(color: Colors.white)),
                                      )),
                                );
                              },
                            ),
                      top: 0,
                      right: 15,
                    ),
                    Positioned(
                      child: Text(
                        '购物车',
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            .copyWith(color: Colors.grey),
                      ),
                      bottom: 20,
                      left: 18,
                    )
                  ],
                ),
              ),
              behavior: HitTestBehavior.translucent,
              onTap: () => {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        mainCart(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              },
            ),
            GestureDetector(
              child: Container(
                child: Stack(
                  children: [
                    Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 40),
                        child: Icon(Icons.person_outline, color: Colors.black)),
                    Positioned(
                      child: Text(
                        '我的',
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            .copyWith(color: Colors.grey),
                      ),
                      bottom: 20,
                      left: 21,
                    )
                  ],
                ),
              ),
              behavior: HitTestBehavior.translucent,
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
            )
          ],
        ),
      ),
    );
  }
}

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
    originalFlag = (widget.product['favorites'] == null || widget.product['favorites'].length == 0) ? 0 : 1;
    calculateFlag() {
      if (count == 0) flag = originalFlag;
      count++;
      return flag;
    }

    return (calculateFlag() == 1)
        ? GestureDetector(
      child: Icon(
        Icons.favorite,
        color: myBlueColor,
        size: 25,
      ),
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
              'Favorite Remove Successful') {
            setState(() {
              flag = 0;
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
    ) : GestureDetector(
      child: Icon(
        Icons.favorite_border,
        color: myBlueColor,
        size: 25,
      ),
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
