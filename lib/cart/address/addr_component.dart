import 'package:flutter/material.dart';

class AddressComponent extends StatefulWidget{
  AddressComponent({ Key key, this.addr_comp, this.flag}): super(key: key);
  final Map<dynamic, dynamic> addr_comp; bool flag = false;
  AddressComponentState createState()=> AddressComponentState();
}

class AddressComponentState extends State<AddressComponent>{
  Widget build(BuildContext context){
  DateTime time = DateTime.parse(widget.addr_comp['created_at']);
    return Table(
            children: [
              TableRow(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('姓名: ${widget.addr_comp['name']}', softWrap: true, overflow: TextOverflow.fade, style: TextStyle(color: widget.flag?Colors.white:Colors.black),),
                          flex: 3,
                        ),
                        Expanded(child: Text('电话: ${widget.addr_comp['phone']}', style: TextStyle(color: widget.flag?Colors.white:Colors.black), softWrap: true, overflow: TextOverflow.clip),flex: 3,),
                        Expanded(child: Container(
                          alignment: Alignment.centerRight,
                          child: Image.asset(widget.addr_comp['delivery_type'] == 1 ? 'assets/images/logo.png' : 'assets/images/yamato.png', width: MediaQuery.of(context).size.width*0.07,),
                        ),flex: 1,)
                      ],
                    ),
                  ]
              ),
              TableRow(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${widget.addr_comp['area_name']}', style: TextStyle(color: widget.flag?Colors.white:Colors.black), softWrap: true, overflow: TextOverflow.fade),
                        Text('${time.year}/${time.month}/${time.day}', style: TextStyle(color: widget.flag?Colors.white:Colors.black),)
                      ],
                    )
                  ]
              )
            ],
            columnWidths: {
              0: FractionColumnWidth(0.75),
            },
          );
    }
}