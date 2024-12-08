import 'package:flutter/material.dart';
import 'home/shopping/mainHome.dart';
import 'mypage/mainMyPage.dart';
import 'cart/mainCart.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'env.dart';

//@author:Yaroslav
//@date:2022-2-8
//@desc: This class is the widget for the bottomNavigationBar.All pages will use this class for the bottomNavbar.
//@params: pageName
//         for example:Scaffold(...bottomNavigationbar:bottonNav('home'))
//         when you use like this,home button will be focused.
class BottomNav extends StatefulWidget {
  final String pageName;
  final int cartCount;
  BottomNav({Key key, this.pageName, this.cartCount=0}) : super(key: key);
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  //getCount means async function should be called first not on every time with build.
  //cartCount means the number that will be displayed on the cart button with the red circle.
  int getCount = 0, cartCount = 0;
  getNavDataFromShared() async {
    getCount++;
    if (getCount == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getInt('cartCount') == null) prefs.setInt('cartCount', 0);
      setState(() {
        cartCount = prefs.getInt('cartCount');
      });
    }
  }

  Widget build(BuildContext context) {
    if (widget.cartCount == 0) {
      getNavDataFromShared();
    } else {
      cartCount = widget.cartCount;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(
                width: 2,
                color: (widget.pageName == 'home' || widget.pageName == 'sign')
                    ? myBlueColor
                    : (((widget.pageName == 'cart')
                    ? Colors.transparent
                    : myGreyColor)),
              ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              if (widget.pageName != 'mainHome') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => mainHome(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }
            },
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 40),
                  child: Icon(
                    widget.pageName == 'home' ||
                        widget.pageName == 'mainHome' ||
                        widget.pageName == 'sign'
                        ? Icons.home
                        : Icons.home_outlined,
                    color: widget.pageName == 'home' ||
                        widget.pageName == 'mainHome' ||
                        widget.pageName == 'sign'
                        ? myBlueColor
                        : Colors.black,
                  ),
                ),
                Positioned(
                  child: Text(
                    '首页',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        .copyWith(color: Colors.grey),
                  ),
                  bottom: 20,
                  left: 21,
                )
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              child: Stack(
                children: [
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 40),
                      child: Icon(
                          ((widget.pageName == 'cart' ||
                              widget.pageName == 'mainCart'))
                              ? Icons.shopping_cart
                              : Icons.shopping_cart_outlined,
                          color: (widget.pageName == 'cart' ||
                              widget.pageName == 'mainCart')
                              ? Color.fromRGBO(247, 150, 70, 1.0)
                              : Colors.black)),
                  Positioned(
                    top: 0,
                    right: 15,
                    child: (cartCount == null ||
                        cartCount == 0)
                        ? Text(
                      '0',
                      style: TextStyle(color: Colors.transparent),
                    )
                        : Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Text(
                        cartCount.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 18,
                    child: Text(
                      '购物车',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          .copyWith(color: Colors.grey),
                    ),
                  )
                ],
              ),
            ),
            behavior: HitTestBehavior.translucent,
            onTap: () => {
              if (widget.pageName != 'sign' && widget.pageName != 'mainCart')
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
            },
          ),
          GestureDetector(
            child: Container(
              child: Stack(
                children: [
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 40),
                      child: Icon(
                          (widget.pageName == 'mypage' ||
                              widget.pageName == 'mainMyPage')
                              ? Icons.person
                              : Icons.person_outline,
                          color: (widget.pageName == 'mypage' ||
                              widget.pageName == 'mainMyPage')
                              ? myBlueColor
                              : Colors.black)),
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
              if (widget.pageName != 'sign' && widget.pageName != 'mainMyPage')
                {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          mainMyPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  )
                }
            },
          )
        ],
      ),
    );
  }
}