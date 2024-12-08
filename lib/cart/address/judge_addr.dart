import 'package:flutter/material.dart';
import 'addr_component.dart';

class JudgeAddress extends StatefulWidget {
  final List<dynamic> addr_info;
  final int flag;
  JudgeAddress({Key key, this.addr_info, this.flag}) : super(key: key);
  JudgeAddressState createState() => JudgeAddressState();
}

class JudgeAddressState extends State<JudgeAddress> {
  int i = -1;
  List<dynamic> tempAddress = [];
  List<bool> temp = [];
  bool flag = true;

  initialize() {
    int j = 0;
    setState(() {
      tempAddress = widget.addr_info;
      while (j < widget.addr_info.length) {
        temp.add(false);
        j++;
      }
      if (widget.flag > -1 && flag == true) {
        temp[widget.flag] = true;
        flag = false;
      }
    });
  }

  Widget build(BuildContext context) {
    initialize();
    return Material(
      animationDuration: Duration(seconds: 2),
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
              child: null,
              onTap: () => Navigator.pop(context, -1),
            )),
            Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                    decoration: BoxDecoration(),
                    child: GestureDetector(
                      child: Text(
                        'X',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      onTap: () => {Navigator.pop(context, -1)},
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: tempAddress
                          .map((e) => GestureDetector(
                                child: Container(
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: temp[tempAddress.indexOf(e)]
                                          ? Colors.deepOrangeAccent
                                          : Colors.white,
                                      border: Border.all(
                                          color: Colors.deepOrangeAccent,
                                          width: 2,
                                          style: BorderStyle.solid),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: AddressComponent(
                                      addr_comp: e,
                                      flag: temp[tempAddress.indexOf(e)],
                                    )),
                                onTap: () {
                                  setState(() {
                                    i = tempAddress.indexOf(e);
                                    tempAddress.forEach((element) => {
                                          if (tempAddress.indexOf(element) == i)
                                            {
                                              if (temp[i] == false)
                                                {temp[i] = true}
                                              else
                                                {temp[i] = false}
                                            }
                                          else
                                            {
                                              temp[tempAddress
                                                  .indexOf(element)] = false
                                            }
                                        });
                                  });
                                },
                                onDoubleTap: () {},
                                onLongPress: () {},
                              ))
                          .toList(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, right: 20, bottom: 20),
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: Text('确认'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, i);
                      },
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
