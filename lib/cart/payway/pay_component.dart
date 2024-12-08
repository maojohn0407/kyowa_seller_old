import 'package:flutter/material.dart';

class PayComponent extends StatelessWidget{
  final Map data; final bool flag;

  PayComponent({Key key, this.data, this.flag});

  Widget build(BuildContext context){
    return Container(
      margin: EdgeInsets.all(10),
      padding:EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: flag?Colors.deepOrangeAccent:Colors.white,
          border: Border.fromBorderSide(
                    BorderSide(color: Colors.deepOrangeAccent,
                      width: 2.0,
                      style: BorderStyle.solid,)
          ),
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(flex: 2,),
          Image.asset('assets/images/payPal.png', width: MediaQuery.of(context).size.width*0.08,),
          Spacer(flex: 1,),
          Text('${data["name"]}',),
          Spacer(flex: 2,),
        ],
      ),
    );
  }
}