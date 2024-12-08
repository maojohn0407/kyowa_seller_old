import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../env.dart';
import 'dart:convert';
import '../../BottomNav.dart';
import 'newsList.dart';
import '../shopping/mainHome.dart';
class newsCategory extends StatefulWidget {
  newsCategory({Key key}) : super(key: key);
  @override
  _newsCategoryState createState()=>_newsCategoryState();
}

class _newsCategoryState extends State<newsCategory> {
  SharedPreferences prefs;
  int getCount=0,cartCount=0;
  var temp=[];
  int newsCount=0;
  getJson() async{
    getCount++;
    if(getCount==1){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if(prefs.getInt('cartCount')==null) prefs.setInt('cartCount', 0);
      final appJson = await http.get(Uri.parse(serverUrl+'/api/newscategory'));
      setState(() {
        cartCount=prefs.getInt('cartCount');
        if(appJson.statusCode==200) {
          temp=json.decode(appJson.body)['data'];
        }
        else print('Cannot connect to server');
      });
    }
  }

  Future<int> getNewsID() async{
    prefs = await SharedPreferences.getInstance();
    return http.get(Uri.parse(serverUrl+'/api/newstitles')).then((http.Response res){
      if(res.statusCode == 200){
        var newsList = jsonDecode(res.body)['data'];
        List<String> newsids = prefs.getStringList('newsIds')??[];
        List<String> templist = [];
        if(newsids == null || newsids.length < 1){
          return jsonDecode(res.body)['data'].length;
        }
        else{
          int count = 0;
          newsList.forEach((element){
            if(!newsids.contains(element['id'].toString())){
              count++;
            }
            templist.add(element['id'].toString());
          });
          newsids.removeWhere((element) => !templist.contains(element));
          prefs.setStringList('newsIds', newsids);
          return count;
        }
      }
      return -1;
    });
  }

  Widget isZero(Map data){
    if(newsCount == 0) return Container(
      padding: EdgeInsets.all(5.0),
      child: Text(''),
    );
    else if(data['id'] == 1) return Container(
      padding: EdgeInsets.all(3.0),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: Text(newsCount.toString(),style: TextStyle(color: Colors.white),),
      ),
    );
    else return Container();
  }

  Widget build(BuildContext context){
    getJson();
    return
      Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: GestureDetector(
              child: Icon(Icons.arrow_back, size: 32.0),
              onTap: ()=>{
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
            title: Container(
              alignment: Alignment(-0.24,0),
              child: Text('关于京和',style:TextStyle(color: Colors.white)),
            ),backgroundColor: myBlueColor,
          ),
          body:Container(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: (temp.length==0)?
                Center(
                  child: Image.asset('assets/images/animated_loading.gif'),
                )
                :
            FutureBuilder<int>(
                future: getNewsID(),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot){
                  if(snapshot.hasData){
                    if(snapshot.data == -1){
                      return Container();
                    }
                    newsCount = snapshot.data;
                    return
                      Column(
                      children: temp.map((e) =>GestureDetector(
                        child:
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border(
                                  bottom: BorderSide(width: 1,color: myBlueColor)
                              )
                          ),
                          padding: EdgeInsets.fromLTRB(0, 13, 0, 12),
                          margin: EdgeInsets.fromLTRB(15, 0, 10, 5),
                          child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(child: Text(e['name'],style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black),)),
                              isZero(e),
                              Icon(Icons.arrow_forward_ios,color: myBlueColor,)
                            ],
                          ),
                        ),
                          onTap: ()=>
                          {
                            Navigator.pushReplacement(
                                context, PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) => newsList(id:e['id'],count: newsCount,),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              )
                          },
                        )).toList(),
                      );
                  }
                  return Container();
                }
            ),
          ),
          bottomNavigationBar: BottomNav(pageName: 'home',)
      );
  }

}

