import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../env.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';
import '../../BottomNav.dart';
import 'newsList.dart';
import '../shopping/detail.dart';
class newsDetail extends StatefulWidget {
  final int id;final int listId,listCount;
  newsDetail({Key key,this.id,this.listId,this.listCount}) : super(key: key);
  @override
  _newsDetailState createState()=>_newsDetailState();
}

class _newsDetailState extends State<newsDetail> {
  int getCount=0,cartCount=0;
  var temp=[];

  getJson() async{
    getCount++;
    if(getCount==1 ){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if(prefs.getInt('cartCount')==null) prefs.setInt('cartCount', 0);
      final appJson = await http.get(Uri.parse(serverUrl+'/api/newscontentbyid/'+widget.id.toString()));
      setState(() {
        cartCount=prefs.getInt('cartCount');
        if(appJson.statusCode==200) {
          temp=json.decode(appJson.body)['data'];
        }
        else print('Cannot connect to server');
      });
    }
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
                    pageBuilder: (context, animation1, animation2) => newsList(id:widget.listId,count: widget.listCount,),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              },
            ),
            shadowColor: Colors.transparent,
            title: Container(
              alignment: Alignment(-0.24,0),
              child: Text('关于京和 > 通知 > 新商品期间优惠通…',style:TextStyle(color: Colors.white)),
            ),backgroundColor: myBlueColor,
          ),
          body:Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: (temp.length==0)?
                  Center(
                    child: Image.asset('assets/images/animated_loading.gif'),
                  )
                : ListView(
                    children: temp.map((e) => itemWidgetForDetail(data:e,index: temp.indexOf(e),)).toList(),
                  ),
          ),
          bottomNavigationBar: BottomNav(pageName: 'home',)
      );
  }
}

class itemWidgetForDetail extends StatelessWidget{
  final Map data;
  final int index;
  itemWidgetForDetail({this.data,this.index});
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 10, 5),
      margin: EdgeInsets.fromLTRB(5,5, 0, 5),
      child:
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child:Text((index+1).toString()+".  "+data['content'],style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black),)
              )
            ],
          ),
          (data['product_id']!=null&& data['product_id']!=0)?
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                child: Text('查看商品详细',style: Theme.of(context).textTheme.bodyText1.copyWith(color: myBlueColor,decoration: TextDecoration.underline,fontStyle: FontStyle.italic)),
                onTap:()=> {

                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => Detail(productId:data['product_id'],exploringData: {'id':0},),//on the case of newsDetail page
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  )
                },
              )
            ],
          ):Text('Empty',style: TextStyle(color: Colors.transparent),),
          (data['media']!=null && data['media']!='')?Container(
            margin: EdgeInsets.fromLTRB(30, 5, 40, 5),
            child: VideoApp(data['media']),
          ):
          (data['image']!=null && data['image']!='')
              ?Container(
            margin: EdgeInsets.fromLTRB(30, 5, 40, 5),
            child: Image.network(serverUrl+environment['news_image_url'] +data['image'], width: MediaQuery.of(context).size.width*0.7,fit: BoxFit.fitHeight,),
          ):Container(height: 1,)
        ],
      ),
    );
  }
}


class VideoApp extends StatefulWidget {
  String videoUrl;
  VideoApp(this.videoUrl);
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        serverUrl+environment['news_video_url']+widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context,BoxConstraints constraints){
      return Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : Container(),
          ),
          Positioned(child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 0, 0, _controller.value.isPlaying ? 0.2 : 1.0),
                  borderRadius: BorderRadius.all(
                      Radius.circular(5.0)
                  )
              ),
              child: (_controller.value.isPlaying)?
              Icon(Icons.pause,color:Color.fromRGBO(255, 255, 255, 0.2),size: 30):
              Icon(Icons.play_arrow,color:Color.fromRGBO(255, 255, 255, 1.0),size: 30),
            ),
            onTap: ()=>{
              setState(() {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              })
            },
          ),left:constraints.constrainWidth()/2-20,top:50,height: 40,width: 40,),
        ],
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}


