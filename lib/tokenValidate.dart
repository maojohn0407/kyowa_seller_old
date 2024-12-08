import 'dart:convert';

import 'dart:core';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'env.dart';

String token;

//@author:Yaroslav
//@date:2022-2-4
//@desc: go to the login page if it has no token,or has expired token.
//       you can use this inside the async function that is associated with the http.get or post with token
//       for example:
//        initialize() async {
//          await validateLogin(context);
//          pref = await SharedPreferences.getInstance(); pref..setBool('flag', false)..setBool('payEnable', true)..setDouble('irregular_total', 0);
//          http.get(Uri.parse(serverUrl+'/api/'+environment['cart']), headers:{'Authorization': pref.getString('token')}).then(
//          ......
//          }
//       this initialize function will be called firstly on the Widget build() method...
// @params: BuildContext context -this variable will be needed to use in Navigator.pushNamed
//          forwardPageUrl- the page Url after we go if login success
validateLogin(BuildContext context, String forwardPageUrl) {
  tokenValidate().then((value) => {
        if (value == false)
          {
            Navigator.popAndPushNamed(context, '/login',
                arguments: forwardPageUrl),
          }
        else
          {
            token = value,
          },
      });
}

//@author:Yaroslav
//@date:2022-2-4
//@desc:returns true if we have to go to the signin screen and returns token if we have correct token in shared preferences
//@params: empty
Future tokenValidate() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString('token') == null ||
      prefs.getString('token').length == 0) {
    prefs.setString('token', '');
    return false;
  } else {
    //test api to check token
    return prefs.getString('token');
    // var testJson = await http.get(Uri.parse(serverUrl + '/api/favorites'),
    //     headers: {'Authorization': prefs.getString('token')});
    // if (testJson.statusCode != 200)
    //   return false;
    // else
    //   return prefs.getString('token');
  }
}
