import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../env.dart';
import 'dart:convert';
import '../../BottomNav.dart';
import 'newsCategory.dart';
import 'newsDetail.dart';
class newsList extends StatefulWidget {
  final int id,count;
  newsList({Key key,this.id,this.count}) : super(key: key);
  @override
  _newsListState createState()=>_newsListState();
}

class _newsListState extends State<newsList> {
  dynamic flagForBack=false;
  int getCount=0,cartCount=0;
  var temp=[];  SharedPreferences prefs;

  getJson(BuildContext context) async{
    getCount++;
    prefs = await SharedPreferences.getInstance();
    if(getCount==1 ){

      if(widget.id!=null){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if(prefs.getInt('cartCount')==null) prefs.setInt('cartCount', 0);
        final appJson = await http.get(Uri.parse(serverUrl+'/api/newstitlesbycategoryid/'+widget.id.toString()));
        setState(() {
          cartCount=prefs.getInt('cartCount');
          if(appJson.statusCode==200) {
            temp=json.decode(appJson.body)['data'];
          }
          else print('Cannot connect to server');
        });
      }
    }
  }

  initializePref () async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  controlPageNavigate(int id) async{
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => newsDetail(id: id,listId: widget.id,listCount: widget.count,),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
//    flagForBack = await Navigator.pushNamed(context, '/newsDetail',arguments: id);
//    if (flagForBack == 'newsDetail') Navigator.popAndPushNamed(context, '/newsList',arguments: ModalRoute.of(context).settings.arguments);
  }

  Widget build(BuildContext context){

    getJson(context);

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
                    pageBuilder: (context, animation1, animation2) => newsCategory(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              },
            ),
            shadowColor: Colors.transparent,
            title: Container(
              alignment: Alignment(-0.24,0),
              child: Text('关于京和  >  通知',style:TextStyle(color: Colors.white)),
            ),backgroundColor: myBlueColor,
          ),
          body:
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: (temp.length==0)?
              Center(
                child: Image.asset('assets/images/animated_loading.gif'),
              ):
            ListView(
              children: temp.map((e) => GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                            bottom:BorderSide(
                                width: 1,color: myBlueColor
                            )
                        )
                    ),
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                    margin: EdgeInsets.fromLTRB(15,0, 10, 5),
                    child:
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(e['title'],style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black)),
                                )
                                ,if(e['created_at']!=null)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(DateTime.parse(e['created_at']).year.toString()+'/'+DateTime.parse(e['created_at']).month.toString()+'/'+DateTime.parse(e['created_at']).day.toString(),style: Theme.of(context).textTheme.overline.copyWith(color: Colors.grey,),textAlign: TextAlign.right),
                                    ],
                                  )
                              ],
                            )),
                        FutureBuilder<dynamic>(
                          future: initializePref(),
                          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
                            if(snapshot.hasData){
                              SharedPreferences pref = snapshot.data;
                              List<String> temp = pref.getStringList('newsIds')??[];
                              if((widget.count??0)==0 || e['category_id']!=1) return Container(
                                padding: EdgeInsets.all(5.0),
                                child: Text(''),
                              );
                              else if(!temp.contains(e['id'].toString())) return Container(
                                padding: EdgeInsets.all(10.0),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  child: Text('1',style: TextStyle(color: Colors.white),),
                                ),
                              );
                              else return Container();
                            }
                            return Container();
                          },
                        ),
                        Icon(Icons.arrow_forward_ios,color: myBlueColor,)
                      ],
                    ),
                  ),
                  onTap: () async{
                    List<String> temp = prefs.getStringList('newsIds')??[];
                    if(!temp.contains(e['id'].toString())){
                      temp.add(e['id'].toString());
                    }
                    prefs.setStringList('newsIds', temp).then(
                            (bool flag){
                          if(flag){
                            controlPageNavigate(e['id']);
                          }
                        }
                    );
                  }
              )
              ).toList(),
            ),
          ),
          bottomNavigationBar: BottomNav(pageName: 'home',)
      );
  }

}

