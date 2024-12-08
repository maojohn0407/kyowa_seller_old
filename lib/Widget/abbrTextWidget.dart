import 'package:flutter/material.dart';

Widget abbrTextWidget(String str, {BuildContext context, double size}){
  double width = 0; double count = 0;
  if(context != null){
    width = context??MediaQuery.of(context).size.width;
  }
  double textsize = size?? 12.0;
  if(width>0){
    if(width <= str.length*textsize){
      count = width/textsize - 3 ;
      String temp = str.substring(0, count.toInt()-1)+'...';
      return Text(temp, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: textsize),);
    } else {
      return Text(str, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: textsize),);
    }
  } else{
    count = 14;
    if(str.length > count){
      String temp = str.substring(0, count.toInt()-3)+'...';
      return Text(temp, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: textsize),);
    } else{
      return Text(str, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: textsize),);
    }
  }
}