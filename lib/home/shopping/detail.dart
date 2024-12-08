import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'mainHome.dart';
import 'secondCategory.dart';
import '../../mypage/mainMyPage.dart';
import '../../cart/mainCart.dart';
import 'exploring.dart';
import '../news/newsCategory.dart';
import '../../mypage/favorite/favorite.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

class Detail extends StatefulWidget {
  final int productId;
  final Map exploringData;
  Detail({Key key, this.productId, this.exploringData}) : super(key: key);
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> animation;
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  final GlobalKey widgetKey = GlobalKey();
  Function(GlobalKey) runAddToCartAnimation;

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

  Future<bool> canAddToCart() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (pref.getString('token') == null || pref.getString('token') == "") {
      return false;
    }

    final res = await http.get(Uri.parse(serverUrl + '/api/clientChat'), headers: {'Authorization': pref.getString('token')});
    if (res.statusCode == 200) {
      String unique =  jsonDecode(res.body)['unique'];
      if (unique != null && unique.isNotEmpty) {
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int getCount = 0,
      cartCount = 0,
      selectedTag = 0,
      number = 1;
  var tempArray = [], tempData;
  List<Widget> buttonGroup = [];

  getJson() async {
    getCount++;
    if (getCount == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      http.get(
          Uri.parse(serverUrl + '/api/product/' + widget.productId.toString()),
          headers: {
            'Authorization': (prefs.getString('token') == null)
                ? ''
                : prefs.getString('token')
          }).then((http.Response appJson) => {
            setState(() {
              cartCount = prefs.getInt('cartCount');
              if (appJson.statusCode == 200) {
                tempArray = json.decode(appJson.body)['related_data'];
                tempArray.forEach((element) {
                  if (element['id'] == widget.productId) {
                    selectedTag = tempArray.indexOf(element);
                  }
                });
                tempData = json.decode(appJson.body)['data'];
              } else {
                prefs.setString('token', '');
                tempArray = json.decode(appJson.body)['related_data'];
                tempArray.forEach((element) {
                  if (element['id'] == widget.productId) {
                    selectedTag = tempArray.indexOf(element);
                  }
                });
                tempData = json.decode(appJson.body)['data'];
              }
            }),
          });
    } else
      print('No data from previous screen!');
  }

  Widget build(BuildContext context) {
    getJson();

    Widget coloredBox(Map temp) {
      if (tempArray.indexOf(temp) == selectedTag)
        return GestureDetector(
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 10, 20, 0),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: Color.fromRGBO(220, 230, 242, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                border: Border.all(width: 2, color: myBlueColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    temp['name'] +
                        '[' +
                        temp['gauge'] +
                        ' X ' +
                        temp['qty'].toString() +
                        '本]',
                    style: TextStyle(color: Colors.red),
                  ),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 3),
                ),
                Row(
                  children: [
                    Text(
                      ((temp['retailsales']['retailsale'] / temp['qty']).ceil())
                              .toString() +
                          '円/本',
                      style: TextStyle(color: Colors.red),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Text(temp['retailsales']['retailsale'].toString() + '円',
                        style: TextStyle(color: Colors.red))
                  ],
                )
              ],
            ),
          ),
          onTap: () => {
            print('nothing to do')
            //because this tag is selected colored box in detail page
          },
        );
      else
        return GestureDetector(
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 10, 20, 0),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                border: Border.all(width: 2, color: Colors.grey)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    temp['name'] +
                        '[' +
                        temp['gauge'] +
                        ' X ' +
                        temp['qty'].toString() +
                        '本]',
                  ),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 3),
                ),
                Row(
                  children: [
                    Text(
                      (temp['retailsales']['retailsale'] / temp['qty'])
                              .ceil()
                              .toString() +
                          '円/本',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Text(
                      temp['retailsales']['retailsale'].toString() + '円',
                    )
                  ],
                )
              ],
            ),
          ),
          onTap: () => {
            setState(() {
              selectedTag = tempArray.indexOf(temp);
              tempData['qty'] = tempArray[selectedTag]['qty'];
              tempData['retailsales']['retailsale'] =
                  tempArray[selectedTag]['retailsales']['retailsale'];
            })
          },
        );
    }

    setState(() {
      buttonGroup = tempArray.map<Widget>((e) => coloredBox(e)).toList();
    });

    Widget tagForComplex(int flag) {
      if (flag == 1)
        return Column(children: buttonGroup);
      else
        return Container(height: 1);
    }

    Widget widgetForBottom() {
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          decoration: BoxDecoration(color: Color.fromRGBO(198, 217, 241, 1.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Spacer(
                flex: 1,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (number > 1) number--;
                  });
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(1.0)),
                  backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(79, 129, 189, 1.0)),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    CircleBorder(),
                  ),
                ),
                child: Icon(
                  Icons.remove,
                  color: Colors.white,
                ),
              ),
              Spacer(
                flex: 1,
              ),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: myBlueColor,
                  ),
                ),
                child: Text('$number', style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
              ),
              Spacer(
                flex: 1,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    number++;
                  });
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(1.0)),
                  backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(79, 129, 189, 1.0)),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    CircleBorder(),
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              Spacer(
                flex: 2,
              ),
              ElevatedButton(
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.only(
                //     topLeft: Radius.circular(4.0),
                //     topRight: Radius.circular(4.0),
                //     bottomLeft: Radius.circular(4.0),
                //     bottomRight: Radius.circular(4.0),
                //   ),
                // ),
                // color: Colors.red,
                // textColor: Colors.white,
                child: Container(
                  margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: Text('加入购物车'),
                ),
                onPressed: () async {
                  SharedPreferences pref =
                  await SharedPreferences.getInstance();
                  if (pref.getString('token') == null || pref.getString('token') == "") {
                    Navigator.pushNamed(context, "/login");
                    return;
                  }
                  bool canEdit = await canAddToCart();
                  if (!canEdit) {
                    showDialog(
                      context: context,
                      builder: (BuildContext Dialogcontext) {
                        return AlertDialog(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "您已经拥有正在与卖家讨论的产品。",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () { Navigator.pop(context);},
                                      child: Text(
                                        '确认',
                                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: myBlueColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0),),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                    return;
                  }

                  int product_id, qty;
                  if (tempArray.length == 1) {
                    product_id = tempData['id'];
                    qty = number;
                  } else {
                    product_id = tempArray[selectedTag]['id'];
                    qty = number;
                  }
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  var response = await http.post(
                      Uri.parse(serverUrl + '/api/addtocart'),
                      headers: {'Authorization': prefs.getString('token')},
                      body: {'product_id': '${product_id}', 'qty': '${qty}'});
                  if (response.statusCode == 200) {
                    await runAddToCartAnimation(widgetKey);
                    await prefs.setInt('lastApiCallTime', 100);
                    if (json.decode(response.body)['message'] != 'Proudct is irregular') {
                      //if the message is success
                      if (json.decode(response.body)['message'] == 'Product has been added to your cart') {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setInt('cartCount', cartCount + 1);
                        setState(() {
                          cartCount = prefs.getInt('cartCount');
                          _controller.forward();
                        });
                      }
                    }
                    //if it failed because it is the irregualr product that is already in your cart
                    else {
                      print('failed to add to cart:case of regular product');
                      // ignore: use_build_context_synchronously
                      showDialog(
                          context: context,
                          builder: (BuildContext Dialogcontext) {
                            return AlertDialog(
                                title: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                    "此商品之前已经加入到购物车。此商品是【不规则商品】。订单提交之前不规则商品必须输入基本要求(数量等)。",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyText2),
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
                                      child: Text('确定',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.popAndPushNamed(
                                          context, '/login',
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
              ),
              Spacer(
                flex: 1,
              ),
            ],
          ),
      );
    }

    Widget isMedia(Map checkVal) {
      if (checkVal['medias'].length == 0)
        return Text(
          '1',
          style: TextStyle(color: Colors.transparent),
        );
      else
        return GestureDetector(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Icon(
              Icons.arrow_right,
              color: Colors.white,
              size: 40,
            ),
          ),
          onTap: () => {
            showDialog<void>(
                context: context,
                builder: (BuildContext ctx) {
                  return dialogContentForVideo(
                      videoUrl: checkVal['medias'][0]['media_src']);
                })
          },
        );
    }

    List<Widget> carouselArray(List data) {
      List<Widget> ImageGroup = [];
      data.forEach((element) => {
            ImageGroup.add(Image.network(
              serverUrl + environment['image_url'] + element['image_src'],
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitHeight,
            ))
          });
      return ImageGroup;
    }

    return AddToCartAnimation(
      cartKey: cartKey,
      height: 10,
      width: 10,
      opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(
        rotation: true,
      ),
      jumpAnimation: const JumpAnimationOptions(
        active: false,
        curve: Curves.slowMiddle,
      ),
      createAddToCartAnimation: (runAddToCartAnimation) {
        // You can run the animation by addToCartAnimationMethod, just pass trough the the global key of  the image as parameter
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: GestureDetector(
              child: Icon(Icons.arrow_back, size: 32.0),
              onTap: () => {
                if (widget.exploringData['id'] == 0)
                  {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            newsCategory(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    )
                  }
                else if (widget.exploringData['id'] ==
                    -1) //from mainCart page(by clicking product image)
                  {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            mainCart(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    )
                  }
                else if (widget.exploringData['id'] ==
                      -2) //from PayCart page(by clicking product image)
                    {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => mainCart(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      )
                    }
                  else if (widget.exploringData['id'] == -3)
                      {
                        //from my favortie page
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                favorite(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        )
                      }
                    else if (widget.exploringData['id'] == -4)
                        {
                          // from search page
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  mainHome(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          )
                        }
                      else if (widget.exploringData['id'] == -5)
                          {
                            // from search page of second category
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) =>
                                    secondCategory(
                                      categoryId: widget.exploringData['p_id'],
                                    ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            )
                          }
                        else if (widget.exploringData['id'] == -6)
                            {
                              // from search page of main home
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) =>
                                      mainHome(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              )
                            }
                          else
                            {
                              Navigator.pushReplacement(
                                //from exploring page(by clicking product image)
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) =>
                                      exploring(
                                        sendingData: widget.exploringData,
                                      ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              )
                            }
              },
            ),
            shadowColor: Colors.transparent,
            title: Container(
              alignment: Alignment(-0.24, 0),
              child: Text('商品详细'),
            ),
            backgroundColor: myBlueColor,
          ),
          bottomNavigationBar: Container(
            height: 80,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 7),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(
                      width: 2,
                      color: Colors.grey,
                    ))),
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
                          child: Text(
                            '首页',
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
                            mainHome(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    )
                  },
                ),
                GestureDetector(
                  child: Container(
                    key: cartKey,
                    child: Stack(
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 40),
                            child: Icon(Icons.shopping_cart_outlined,
                                color: Colors.black)),
                        Positioned(
                          child: (cartCount == null || cartCount == 0)
                              ? Text(
                            '0',
                            style: TextStyle(color: Colors.transparent),
                          )
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
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: Text(
                                        cartCount.toString(),
                                        style:
                                        TextStyle(color: Colors.white),
                                      ),
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
                            child:
                            Icon(Icons.person_outline, color: Colors.black)),
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
          body: (tempArray.length == 0)
              ? Center(
            child: Image.asset('assets/images/animated_loading.gif'),
          )
              : Column(
            children: [
              Expanded(
                child:
                Stack(children: [
                  Positioned(
                    top: 40, right: 50, left: 50,
                    child: Container(
                      key: widgetKey,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                width: 2,
                                color: myBlueColor,
                              ))),
                      child: LayoutBuilder(builder: (BuildContext context,
                          BoxConstraints constraints) {
                        return Stack(
                          children: [
                            (tempData['images'].length == 0)
                                ? Image.asset(
                              'assets/images/logo.png',
                              width:
                              MediaQuery.of(context).size.width - 100,
                              fit: BoxFit.fitHeight,
                            )
                                : SizedBox(
                                width: MediaQuery.of(context).size.width - 100,
                                height: MediaQuery.of(context).size.height * 0.5 - 80,
                                child: Carousel(
                                  images:
                                  carouselArray(tempData['images']),
                                  dotSize: 4.0,
                                  dotSpacing: 15.0,
                                  indicatorBgPadding: 10.0,
                                  dotBgColor:
                                  Colors.black.withOpacity(0.3),
                                )),
                            Positioned(
                              child: isMedia(tempData),
                              left: constraints.constrainWidth() / 2 - 25,
                              top: constraints.constrainWidth() / 2 - 25,
                              height: 50,
                              width: 50,
                            ),
                            Positioned(
                                child: heartButton(
                                  product: tempData,
                                ),
                                bottom: 25,
                                right: 25)
                          ],
                        );
                      }),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: ListView(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                    width: 2,
                                    color: myBlueColor,
                                  ))),
                          child: LayoutBuilder(builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Stack(
                              children: [
                                (tempData['images'].length == 0)
                                    ? Image.asset(
                                  'assets/images/logo.png',
                                  width:
                                  MediaQuery.of(context).size.width,
                                  fit: BoxFit.fitHeight,
                                )
                                    : SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: Carousel(
                                      images:
                                      carouselArray(tempData['images']),
                                      dotSize: 4.0,
                                      dotSpacing: 15.0,
                                      indicatorBgPadding: 10.0,
                                      dotBgColor:
                                      Colors.black.withOpacity(0.3),
                                    )),
                                Positioned(
                                  child: isMedia(tempData),
                                  left: constraints.constrainWidth() / 2 - 25,
                                  top: constraints.constrainWidth() / 2 - 25,
                                  height: 50,
                                  width: 50,
                                ),
                                Positioned(
                                    child: heartButton(
                                      product: tempData,
                                    ),
                                    bottom: 25,
                                    right: 25)
                              ],
                            );
                          }),
                        ),
                        tagForComplex((tempArray.length == 1) ? 0 : 1),
                        (tempArray.length == 1)
                            ? Textline('商品名', tempData['name'], 0)
                            : Container(
                          margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                          height: 10,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                    width: 1,
                                    color: myBlueColor,
                                  ))),
                        ),
                        Textline(
                            '规格',
                            tempData['gauge'] + '/' + tempData['unit']['name'],
                            0),
                        Textline('零售单位', tempData['qty'].toString() + '本', 1),
                        Container(
                            margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1.0, color: myBlueColor))),
                            child: Container(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
                              child: Row(
                                children: [
                                  Expanded(child: Text('价格（税前）')),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                                    child: Text(
                                      '价格（税后）: ' +
                                          (tempData['retailsales']
                                          ['retailsale'] +
                                              tempData['retailsales']
                                              ['retailsale'] *
                                                  tempData['tax'])
                                              .toString() +
                                          '円',
                                      style:
                                      Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                                  Text(
                                    tempData['retailsales']['retailsale']
                                        .toString() +
                                        '円',
                                    style: TextStyle(color: Colors.red),
                                  )
                                ],
                              ),
                            )),
                        Textline('品牌', tempData['mark'], 0),
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1.0, color: myBlueColor))),
                          child: (tempData['description'] != null &&
                              tempData['description'] != '')
                              ? Container(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Container(
                                  margin:
                                  EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [Text('description')],
                                  ),
                                ),
                                Container(
                                  margin:
                                  EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Text(
                                              tempData['description']))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                              : SizedBox(
                            height: 100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              widgetForBottom(),
            ],
          )),
    );
  }
}

class Textline extends StatelessWidget {
  String title, content;
  int is_red;
  Textline(this.title, this.content, this.is_red);
  Widget returnText(int flag) {
    if (flag == 0)
      return Text(content);
    else
      return Text(
        content,
        style: TextStyle(color: Colors.red),
      );
  }

  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1.0, color: myBlueColor))),
        child: Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
          child: Row(
            children: [Expanded(child: Text(title)), returnText(is_red)],
          ),
        ));
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
    originalFlag = (widget.product['favorites_count'] == null ||
            widget.product['favorites_count'] == 0)
        ? 0
        : 1;
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

//@author:Yaroslav
//@date:2022-2-11
//@desc: sample video playing widget
//@params: video url

class VideoApp extends StatefulWidget {
  String videoUrl;
  VideoApp(this.videoUrl);
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        serverUrl + environment['video_url'] + widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

//@author:Yaroslav
//@date:2022-2-11
//@desc: dialog class when appears you click media button
//@params: video url

class dialogContentForVideo extends StatefulWidget {
  String videoUrl;

  dialogContentForVideo({Key key, this.videoUrl}) : super(key: key);
  @override
  _dialogContentForVideoState createState() => _dialogContentForVideoState();
}

class _dialogContentForVideoState extends State<dialogContentForVideo> {
  Widget build(BuildContext context) {
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
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Text(
                      'Empty',
                      style: TextStyle(color: Colors.transparent),
                    )),
                    Icon(Icons.close, color: Colors.white)
                  ],
                ),
              ),
              onTap: () => Navigator.pop(context),
            )),
            Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: VideoApp(widget.videoUrl),
            ),
            Expanded(
                child: GestureDetector(
              child: null,
              onTap: () => Navigator.pop(context),
            )),
          ],
        ),
      ),
    );
  }
}
