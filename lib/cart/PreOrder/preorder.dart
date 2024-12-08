import 'package:flutter/material.dart';
import '../../env.dart';
import '../../home/shopping/detail.dart';

class PreOrder extends StatelessWidget{
  var data;
  dynamic flagForBack=false;
  PreOrder({Key key, this.data});
  Widget build(BuildContext context){
    return Container(
      margin: EdgeInsets.only(left: 0, top: 15, bottom: 10, right: 8),
      child: Row(
        children: [
          GestureDetector(
            child: Container(
              child: data['product']['images'].length>0? Container(child: Image.network(serverUrl+environment['image_url']+data['product']['images'][0]['image_src'],width: MediaQuery.of(context).size.width*0.1428,),
                decoration: BoxDecoration(
                    border:Border.all(
                      color: Color.fromRGBO(247, 150, 70, 1.0),
                    )
                ),
              )
                  :Container(child: Image.asset('assets/images/item3.png', width: MediaQuery.of(context).size.width*0.1428,),
                decoration: BoxDecoration(
                    border: Border.all(color: Color.fromRGBO(247, 150, 70, 1.0),)
                ),
              ),
              margin: EdgeInsets.only(
                  right: 30
              ),
            ),
            onTap: (){
//              flagForBack= await Navigator.pushNamed(context, '/detail',arguments: data['product']['id']);
//              if(flagForBack== 'detail') Navigator.pushNamed(context, '/cart/payCart');
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => Detail(productId:data['product']['id'],exploringData: {'id':-2},),//on the case of newsDetail page
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
            },

          ),
          Expanded(

            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['product']['name']??'',style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(child: Text('${data['product']['retailsales']['retailsale']??0}円'),flex: 1,),
                    Expanded(child:  Text('${data['qty']??0}${data['product']['unit']['name']}', textAlign: TextAlign.end,),flex: 1,),
                    SizedBox(width: 20,),
                    Expanded(child:  Container(
                      padding: EdgeInsets.all(5.0),
                      child: Text('${data['price']??0}円',textAlign: TextAlign.end,style: Theme.of(context).textTheme.button,),
                    ),flex: 1,),
                  ],
                )
              ],
            ),)
        ],
      ),
    );
  }
}