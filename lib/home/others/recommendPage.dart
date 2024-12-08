import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../../env.dart';
import '../shopping/mainHome.dart';
import '../../mypage/addresss/phoneValidate.dart';

class recommendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.white,
          title: Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.fitHeight,
                      width: 50,
                    ),
                  ),
                  Text('KYOWA',
                      style: Theme.of(context).textTheme.overline.copyWith(
                          color: Colors.black, fontWeight: FontWeight.bold))
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Text("京和商城",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                      color: myBlueColor, fontWeight: FontWeight.bold)),
            ],
          ))),
      body: Container(
          margin: EdgeInsets.fromLTRB(
              0, MediaQuery.of(context).size.height * 0.2, 0, 0),
          padding: EdgeInsets.all(10.0),
          alignment: Alignment(0, 0),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Text("购买需要输入地址信息，地址验证需要大约1小时～1天的时间，您现在要输入地址信息吗？",
                    style: Theme.of(context).textTheme.headline6),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    // color: myBlueColor,
                    // textColor: Colors.white,
                    // elevation: 0.0,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 4, 10, 6),
                      child: Text("现在输入地址",
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: Colors.white)),
                    ),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            phoneValidate(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
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
                  ),
                  ElevatedButton(
                    // color: myBlueColor,
                    // textColor: Colors.white,
                    // elevation: 0.0,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 4, 10, 6),
                      child: Text("以后再说",
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: Colors.white)),
                    ),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            mainHome(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
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
                  ),
                ],
              )
            ],
          )),
    );
  }
}
