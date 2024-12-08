import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'dialogContent.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../env.dart';
import '../../BottomNav.dart';
import 'mainHome.dart';
import 'exploring.dart';

class secondCategory extends StatefulWidget {
  final int categoryId;
  secondCategory({Key key, this.categoryId}) : super(key: key);
  @override
  _secondCategoryState createState() => _secondCategoryState();
}

class _secondCategoryState extends State<secondCategory> {
  int getCount = 0, cartCount = 0;
  bool isReceivedData = false;
  //@author:Yaroslav
  //@date:2022-2-11
  //@desc: getJson is used for receive data from web server.It receives data for child category and dropdown button

  getJson() async {
    getCount++;
    if (getCount == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getInt('cartCount') == null) prefs.setInt('cartCount', 0);

      final appJsonForDropDown = jsonDecode(prefs.getString('parentCategory'));
      String cachedChildCategory = prefs.getString('childCategory' + widget.categoryId.toString());
      if (cachedChildCategory != null && cachedChildCategory != '') {
        dynamic json = jsonDecode(cachedChildCategory);
        var lastChildCategoryTime = DateTime.fromMillisecondsSinceEpoch(
            prefs.getInt('lastChildCategoryTime' + widget.categoryId.toString()) ?? 0);

        // Check time difference
        if (DateTime.now().difference(lastChildCategoryTime).inMinutes <= 30) {
          // Use cached data
          setState(() {
            isReceivedData = true;
            temp = json;
            tempForDropDown = appJsonForDropDown;
          });
          return;
        }
      }

      final appJson = await http.get(Uri.parse(serverUrl + '/api/parentcategory/' + widget.categoryId.toString() + '/childcategory'));
      if (appJson.statusCode == 200) {
        setState(() {
          isReceivedData = true;
          cartCount = prefs.getInt('cartCount');
          temp = json.decode(appJson.body)['data'];
          tempForDropDown = appJsonForDropDown;
        });

        await prefs.setString('childCategory' + widget.categoryId.toString(), jsonEncode(temp));
        await prefs.setInt('lastChildCategoryTime' + widget.categoryId.toString(), DateTime.now().millisecondsSinceEpoch);
      } else
        print('Cannot connect to server');
    }
  }

  var temp = [], tempForDropDown = [];
  Map sendingData; //data for next page-exploring page(item list)
  String selectedParentCategoryName = '';
  Widget build(BuildContext context) {
    getJson();
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.arrow_back, size: 32.0),
            onTap: () => {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => mainHome(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              )
            },
          ),
          shadowColor: Colors.transparent,
          titleSpacing: 0,
          backgroundColor: myBlueColor,
          title: Row(
//            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (tempForDropDown.length == 0)
                  ? Text(
                      '空的',
                      style: TextStyle(color: Colors.transparent),
                    )
                  : DropdownButton<String>(
                      dropdownColor: myBlueColor,
                      underline: Text(
                        '在下面',
                        style: TextStyle(color: Colors.transparent),
                      ),
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 0,
                      ),
                      value: widget.categoryId.toString(),
                      items: tempForDropDown
                          .map<
                              DropdownMenuItem<
                                  String>>((e) => DropdownMenuItem<String>(
                              child: GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      border: Border.all(
                                          color: Colors.white, width: 2)),
                                  child: (widget.categoryId == e['id'])
                                      ? Text(e['name'],
                                          style: TextStyle(color: Colors.white))
                                      : Text(
                                          e['name'] +
                                              ' (' +
                                              e['p_products_count'].toString() +
                                              ')',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                                onTap: () => {
//                          Navigator.pushNamed(context, '/secondCategory',arguments:e['id'])
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1,
                                              animation2) =>
                                          secondCategory(categoryId: e['id']),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  )
                                },
                              ),
                              value: e['id'].toString()))
                          .toList(),
                      onChanged: (String val) => print(val),
                    ),
              Expanded(
                  child: Text(
                'Expan',
                style: TextStyle(color: Colors.transparent),
              )),
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 13, 0),
                  child: Transform(
                    transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                    alignment: Alignment.center,
                    transformHitTests: false,
                    child: Icon(
                      Icons.search_sharp,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                onTap: () => {
                  tempForDropDown.forEach((element) {
                    if (element['id'].toString() ==
                        widget.categoryId.toString())
                      selectedParentCategoryName = element['name'];
                  }),
                  showDialog<void>(
                      context: context,
                      builder: (BuildContext ctx) {
                        return dialogContent(
                            whichPage: selectedParentCategoryName,
                            categoryType: 'parent',
                            categoryId: widget.categoryId,
                            sendingData: {
                              'id': -5,
                              'p_id': widget.categoryId
                            },
                        );
                      })
                },
              )
            ],
          ),
        ),
        body: Container(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: (temp.length != 0)
              ? ListView(
                  children: temp
                      .map((e) => GestureDetector(
                          child: panelWidget(data: e),
                          onTap: () => {
                                sendingData = {
                                  'id': e['id'],
                                  'p_id': e['p_id']
                                },
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            exploring(sendingData: sendingData),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                )
                              }))
                      .toList())
              : Center(
                  child: (!isReceivedData)
                      ? Image.asset('assets/images/animated_loading.gif')
                      : Text(''),
                ),
        ),
        bottomNavigationBar: BottomNav(
          pageName: 'home',
        ));
  }
}

//@author:Yaroslav
//@date:2022-2-11
//@desc: the row component associated with the child category button

class panelWidget extends StatelessWidget {
  final Map data;
  panelWidget({this.data});
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(bottom: BorderSide(width: 1, color: myBlueColor))),
      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
      margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              child: Text(
            data['name'] + " (" + data['c_products_count'].toString() + ")",
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.black),
          )),
          Icon(
            Icons.arrow_forward_ios,
            color: myBlueColor,
          )
        ],
      ),
    );
  }
}
