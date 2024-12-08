import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mypage/addresss/addressList.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String phoneNumber, otp;
  bool otpSent = false;
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  sendOtp(String phonenumber) async {
    var response = await http.post(Uri.parse(serverUrl + '/api/sendsmscode'),
        body: {'phone_number': phoneNumber});
    var bodyData = json.decode(response.body);
    if (bodyData['message'] == 'Verification code sent') {
      setState(() {
        phoneNumber = phonenumber;
        otpSent = true;
      });
    } else {
      otpSent = false;
    }
  }

  verifyOtp(String phoneNumber, String otp, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(serverUrl + '/api/verifycode'),
        body: {'phone_number': phoneNumber, 'code': otp});
    debugPrint("*** Search Result = ${response.body}");
    var bodyData = json.decode(response.body);
    if (bodyData['message'] == 'Login Successful') {
      await prefs.setString('token', bodyData['token']);
      bool verified = bodyData['verified'] ?? false;
      await prefs.setBool('VIPUser', verified);
      // Fetch cart count or other user-specific data
      await fetchCartCount(bodyData['token'], prefs);
      bool goAddress = await prefs.getBool("goAddress");
      if (goAddress && !verified) {
        prefs.setBool("goAddress", false);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                addressList(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        if (ModalRoute.of(context).settings.arguments == null)
          Navigator.popAndPushNamed(context, '/home');
        else
          Navigator.popAndPushNamed(
              context, ModalRoute.of(context).settings.arguments.toString());
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext DialogContext) {
            return AlertDialog(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Invalid OTP",
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
                              onPressed: () => Navigator.pop(DialogContext),
                              child: Text('OK',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(color: Colors.white)),
                              style: TextButton.styleFrom(
                                backgroundColor: myBlueColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                ),
                              ),
                            ),
                          ],
                        ))
                  ],
                ));
          });
    }
  }

  Future<void> fetchCartCount(String token, SharedPreferences prefs) async {
    var response = await http.get(Uri.parse(serverUrl + '/api/cart'), headers: {
      'Authorization': token
    });
    if (response.statusCode == 200) {
      var bodyData = json.decode(response.body);
      prefs.setInt('cartCount', bodyData['regular'].length + bodyData['irregular'].length);
    } else {
      prefs.setInt('cartCount', 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.arrow_back, size: 32.0),
            onTap: () => {
              Navigator.pop(context)
              // Navigator.pushReplacement(
              //   context,
              //   PageRouteBuilder(
              //     pageBuilder: (context, animation1, animation2) => mainHome(),
              //     transitionDuration: Duration.zero,
              //     reverseTransitionDuration: Duration.zero,
              //   ),
              // )
            },
          ),
          backgroundColor: myBlueColor,
          shadowColor: Colors.transparent,
          title: Container(
            alignment: Alignment(-0.24, 0),
            child: Text('身份验证'),
          )),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 100, 30, 0),
        child: Column(
          children: [
            Text(
              "京和商城提示：需要身份验证， \n请输入您的电话号码",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: '电话号码',
                hintText: '请输入您的电话号码',
                icon: Icon(
                  Icons.phone,
                  color: Colors.red,
                ),
              ),
              onChanged: (value) => {
                phoneNumber = value,
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String val) {
                return (val.length == 10 || val.length == 11) ? null : "确保您的电话号码正确。";
              },
            ),
            otpSent
                ? TextFormField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: '一次性密码',
                hintText: '请输入 OTP',
                icon: Icon(
                  Icons.lock_outline,
                  color: Colors.red,
                ),
              ),
              onChanged: (value) => {
                otp = value,
              },
            )
                : Container(),
            Container(
              margin: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => {
                      if (!otpSent)
                        sendOtp(phoneNumber)
                      else
                        verifyOtp(phoneNumber, otp, context),
                    },
                    child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Text(
                            otpSent ? '验证 OTP  ' : '发送 OTP  ',
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            otpSent ? Icons.check : Icons.send,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: myBlueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
