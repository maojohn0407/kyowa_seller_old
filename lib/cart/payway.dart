import 'package:flutter/material.dart';
import 'payway/pay_component.dart';

class payDialog extends StatefulWidget {
  var payBank;
  var price;
  payDialog({Key key, this.payBank, this.price}) : super(key: key);
  payDialogState createState() => payDialogState();
}

class payDialogState extends State<payDialog> {
  int i = -1;
  List<bool> flags = [];

  initialize() {
    int i = 0;
    while (i < widget.payBank.length) {
      flags.add(false);
      i++;
    }
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
                onTap: () => Navigator.pop(context, -1),
              ),
            ),
            Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(top: 10, right: 10),
                    child: GestureDetector(
                      child: Text('X', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),),
                      onTap: () => Navigator.pop(context, -1),
                    ),
                  ),
                  Text('支付方式：', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),),
                  Expanded(
                    child: GridView.count(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      crossAxisCount: 1,
                      children: widget.payBank.map<Widget>((e) => GestureDetector(
                        child: PayComponent(data: e, flag: flags[widget.payBank.indexOf(e)]),
                        onTap: () {
                          flags.fillRange(0, flags.length - 1, false);
                          setState(() {
                            if (flags[widget.payBank.indexOf(e)] == false) {
                              flags[widget.payBank.indexOf(e)] = true;
                              i = widget.payBank.indexOf(e);
                            } else {
                              flags[widget.payBank.indexOf(e)] = false;
                              i = -1;
                            }
                          });
                        },
                      )).toList(),
                      shrinkWrap: false,
                      childAspectRatio: 5,
                    ),
                  ),
                  Container(
                    height: 60,
                    color: Colors.orange,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 20.0),
                              child: Text(
                                "总和：   ${widget.price.toInt().toString()}円",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        // Spacer to push button to the right
                        Spacer(),
                        // Right side button
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, i < 0 ? -1 : i);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                            child: Text('确认支付'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
