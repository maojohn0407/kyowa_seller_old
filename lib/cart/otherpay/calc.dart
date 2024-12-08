import 'package:flutter/material.dart';

class Calc extends StatefulWidget {
  Calc({Key key, this.point, this.price}) : super(key: key);
  CalcState createState() => CalcState();
  final int point;
  final double price;
}

class CalcState extends State<Calc> {
  int pointbyuse = 0;
  Widget build(BuildContext context) {
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
              onTap: () => Navigator.pop(context, 0),
            )),
            Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.65,
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
                      onTap: () => {Navigator.pop(context, 0)},
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Table(
                            children: [
                              TableRow(children: [
                                Text(
                                  'Total:',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 17, height: 2),
                                ),
                                Text(
                                  '${widget.point}  point',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 17, height: 2),
                                )
                              ]),
                              TableRow(children: [
                                Text(
                                  'Rest:',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 17, height: 2),
                                ),
                                Text(
                                  '${(widget.point - pointbyuse) > 0 ? widget.point - pointbyuse : 0}  point',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 17, height: 2),
                                )
                              ]),
                              TableRow(children: [
                                Text(
                                  'Usage:',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 17, height: 2),
                                ),
                                Text(
                                  '${pointbyuse > widget.point ? widget.point : pointbyuse}  point',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 17,
                                      height: 2,
                                      decoration: TextDecoration.underline),
                                )
                              ]),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.92,
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.all(5),
                          color: Colors.black26,
                          child: Table(
                            defaultColumnWidth: FractionColumnWidth(0.33),
                            children: [
                              TableRow(children: [
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text(
                                      '1',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (pointbyuse * 10 + 1 > widget.point) {
                                        pointbyuse = widget.point;
                                      } else {
                                        pointbyuse = pointbyuse * 10 + 1;
                                      }
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text(
                                      '2',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (pointbyuse * 10 + 2 > widget.point) {
                                        pointbyuse = widget.point;
                                      } else {
                                        pointbyuse = pointbyuse * 10 + 2;
                                      }
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text(
                                      '3',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (pointbyuse * 10 + 3 > widget.point) {
                                        pointbyuse = widget.point;
                                      } else {
                                        pointbyuse = pointbyuse * 10 + 3;
                                      }
                                    });
                                  },
                                )
                              ]),
                              TableRow(children: [
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text(
                                      '4',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (pointbyuse * 10 + 4 > widget.point) {
                                        pointbyuse = widget.point;
                                      } else {
                                        pointbyuse = pointbyuse * 10 + 4;
                                      }
                                    });
                                  },
                                ),
                                GestureDetector(
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 2),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Text(
                                        '5',
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (pointbyuse * 10 + 5 >
                                            widget.point) {
                                          pointbyuse = widget.point;
                                        } else {
                                          pointbyuse = pointbyuse * 10 + 5;
                                        }
                                      });
                                    }),
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text(
                                      '6',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (pointbyuse * 10 + 6 > widget.point) {
                                        pointbyuse = widget.point;
                                      } else {
                                        pointbyuse = pointbyuse * 10 + 6;
                                      }
                                    });
                                  },
                                )
                              ]),
                              TableRow(children: [
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text(
                                      '7',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (pointbyuse * 10 + 7 > widget.point) {
                                        pointbyuse = widget.point;
                                      } else {
                                        pointbyuse = pointbyuse * 10 + 7;
                                      }
                                    });
                                  },
                                ),
                                GestureDetector(
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 2),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Text(
                                        '8',
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (pointbyuse * 10 + 8 >
                                            widget.point) {
                                          pointbyuse = widget.point;
                                        } else {
                                          pointbyuse = pointbyuse * 10 + 8;
                                        }
                                      });
                                    }),
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text(
                                      '9',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (pointbyuse * 10 + 9 > widget.point) {
                                        pointbyuse = widget.point;
                                      } else {
                                        pointbyuse = pointbyuse * 10 + 9;
                                      }
                                    });
                                  },
                                )
                              ]),
                              TableRow(children: [
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text(
                                      'Total',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (widget.price.toInt() < widget.point) {
                                        pointbyuse = widget.price.toInt();
                                      } else {
                                        pointbyuse = widget.point;
                                      }
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text(
                                      '0',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (pointbyuse * 10 > widget.point) {
                                        pointbyuse = widget.point;
                                      } else {
                                        pointbyuse = pointbyuse * 10;
                                      }
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 2),
                                    decoration: BoxDecoration(
                                        color: Color.fromRGBO(189, 189, 189, 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Icon(
                                      Icons.backspace,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      pointbyuse = (pointbyuse / 10).toInt();
                                    });
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      pointbyuse = 0;
                                    });
                                  },
                                )
                              ]),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20, bottom: 20),
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: Text(
                        '确认',
                        style: TextStyle(height: 3.5),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, pointbyuse);
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
