import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../env.dart';
import '../../home/shopping/detail.dart';
import 'package:firebase_database/firebase_database.dart';

class IrregularProducts extends StatefulWidget {
  IrregularProducts({Key key, this.data, this.onValueChanged})
      : super(key: key);
  final Map<dynamic, dynamic> data;
  final ValueChanged<String> onValueChanged;

  IrregularProductsState createState() => IrregularProductsState(data: data);
}

class IrregularProductsState extends State<IrregularProducts> {
  final Map<dynamic, dynamic> data;
  dynamic flagForBack = false;

  TextEditingController svrcontroller;
  TextEditingController usrcontroller;
  String usrInfo;
  String unique;
  bool delete = false;
  bool readOnly = false;

  SharedPreferences pref;

  IrregularProductsState({this.data}) {
    svrcontroller = TextEditingController(text:
        ' X ${data['qty']}${data['product']['unit']['name']} = ${data['qty'] * data['product']['retailsales']['retailsale']}円');
    initialize();
  }

  initialize() async {
    pref = await SharedPreferences.getInstance();
    // pref..setBool('payEnable', pref.getBool('payEnable') & svrFlag);
    pref..setBool('payEnable', true);
    unique = await pref.getString('unique') ?? "";
    if (unique == "") {
      setState(() {
        readOnly = false;
      });
      return;
    }
    setState(() {
      readOnly = true;
    });

    DatabaseReference ref = FirebaseDatabase.instance.ref('products/${unique}/' + data['id'].toString());
    ref.onValue.listen((event) {
      if (event.snapshot.exists) {
        Map map = event.snapshot.value;
        if (map['qty'] == null) {
          svrcontroller = TextEditingController(text: '???');
        } else {
          double quantity = double.parse(map['qty']);
          svrcontroller = TextEditingController(text: ' X ${map['qty']}${data['product']['unit']['name']} = ${quantity * data['product']['retailsales']['retailsale']}円');
        }
      }
    });
  }

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(top: 10, right: 20, bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromRGBO(247, 150, 70, 1.0)),
                  ),
                  child: widget.data['product']['images'].length > 0
                      ? Image.network('${serverUrl}' + environment['image_url'] + '${widget.data['product']['images'][0]['image_src']}',
                    width: MediaQuery.of(context).size.width * 0.1428 + 1,
                  )
                      : Image.asset('assets/images/item3.png', width: MediaQuery.of(context).size.width * 0.1428 + 1),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          Detail(
                            productId: widget.data['product']['id'],
                            exploringData: {'id': -1},
                          ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data['product']['name']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text('${data['product']['retailsales']['retailsale']}円（税抜）', style: TextStyle(fontSize: 11), textAlign: TextAlign.left,),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: svrcontroller,
                                  decoration: InputDecoration(
                                    enabled: false,
                                    isCollapsed: true,
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  readOnly: true,
                                ),
                              ),
                              // Container(
                              //   margin: EdgeInsets.only(left: 5),
                              //   padding: EdgeInsets.all(0.0),
                              //   child: svrFlag
                              //       ? Container(
                              //     child: Image.asset(
                              //       'assets/images/total_check.png',
                              //       width: 25,
                              //     ),
                              //   )
                              //       : SizedBox(
                              //     width: 25,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
