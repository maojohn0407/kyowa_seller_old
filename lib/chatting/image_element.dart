import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../env.dart';
import 'package:flutter/cupertino.dart';
import 'Constants.dart';

class ImageElement extends StatelessWidget {
  final Map<dynamic, dynamic> data;
  final String receiver_id;
  final String sender_id;
  final bool isGroup;
  double width;
  final bool isNew;

  ImageElement({Key key, this.data, this.sender_id, this.receiver_id, this.isGroup, this.isNew});

  Widget build(BuildContext context) {
    DateTime tempTime = DateTime.parse(data['datetime']).toLocal();
    width = MediaQuery.of(context).size.width * 0.5;

    Widget buildMessageTime(BuildContext context, DateTime tempTime) {
      return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width, // Set the width to the full width
        child: Text(
          '${tempTime.hour < 13 ? tempTime.hour : tempTime.hour - 12}' +
              ' : ' +
              '${tempTime.minute < 10 ? '0' + tempTime.minute.toString() : tempTime.minute.toString()}' +
              '${tempTime.hour < 13 ? '  AM' : '  PM'}',
          textAlign: TextAlign.center, // Center-align the text
          softWrap: true,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
        ),
      );
    }

    return (sender_id == data['sender_id'].toString())
        ? Container(
            child: Column(
              children: [
                !isGroup
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/strike.png'),
                              fit: BoxFit.fill),
                        ),
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.2,
                        ),
                        child: Container(
                            color: Colors.white,
                            child: Text(
                              '${weekday[tempTime.weekday - 1] + ', ' + month[tempTime.month - 1] + '  ' + tempTime.day.toString() + ', ' + tempTime.year.toString()}',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(height: 2, color: Colors.black38),
                            )))
                    : Container(),
                !isNew
                    ? Container(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: Container(
                                  alignment: Alignment.center, // Center the text
                                  child: buildMessageTime(context, tempTime),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                Container(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                            alignment: Alignment.topRight,
                            width: width,
                            margin: EdgeInsets.fromLTRB(
                                MediaQuery.of(context).size.width * 0.3,
                                7,
                                5,
                                10),
                            padding: EdgeInsets.all(5),
                            child: (data['message'].toString().split('/')[0] ==
                                    "video")
                                ? VideoApp(
                                    data['message'].toString().split('/')[1])
                                : Image.network(
                                    serverUrl +
                                        environment['chat_image_url'] +
                                        data['message']
                                            .toString()
                                            .split('/')[1],
                                    width: width,
                                  )),
                      ),
                      !isGroup || !isNew
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(right: 5),
                              padding: EdgeInsets.only(top: 0),
                              child: Image.asset(
                                'assets/images/avatar3.png',
                                width: 40,
                                height: 40,
                              ),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.1,
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            )
                    ],
                  ),
                ),
              ],
            ),
          )
        :

        //if this mail is other people's message it should be rendered to the other side
        Container(
            child: Column(
              children: [
                !isGroup
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/strike.png'),
                              fit: BoxFit.fill),
                        ),
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.2,
                        ),
                        child: Container(
                            color: Colors.white,
                            child: Text(
                              '${weekday[tempTime.weekday - 1] + ', ' + month[tempTime.month - 1] + '  ' + tempTime.day.toString() + ', ' + tempTime.year.toString()}',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(height: 2, color: Colors.black38),
                            )))
                    : Container(),
                !isNew
                    ? Container(
                        alignment: Alignment.topLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: Container(
                                  alignment: Alignment.center, // Center the text
                                  child: buildMessageTime(context, tempTime),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                Container(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      !isGroup || !isNew
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5),
                              padding: EdgeInsets.only(top: 0),
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 40,
                                height: 40,
                              ),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.1,
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            ),
                      Expanded(
                        child: Container(
                            alignment: Alignment.topRight,
                            width: width,
                            margin: EdgeInsets.fromLTRB(5, 7,
                                MediaQuery.of(context).size.width * 0.3, 10),
                            padding: EdgeInsets.all(5),
                            child: (data['message'].toString().split('/')[0] ==
                                    "video")
                                ? VideoApp(
                                    data['message'].toString().split('/')[1])
                                : Image.network(
                                    serverUrl +
                                        environment['chat_image_url'] +
                                        data['message']
                                            .toString()
                                            .split('/')[1],
                                    width: width,
                                  )),
                      ),
                    ],
                  ),
                ),
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
    _controller = VideoPlayerController.network(serverUrl + environment['chat_video_url'] + widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
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
          Positioned(
            child: GestureDetector(
              child: Container(
                decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, _controller.value.isPlaying ? 0.2 : 0.2), borderRadius: BorderRadius.all(Radius.circular(100)), border: Border.all(color: Color.fromRGBO(255, 255, 255, _controller.value.isPlaying ? 0.5 : 1.0), width: 1.0)),
                child: (_controller.value.isPlaying) ? Icon(Icons.pause, color: Color.fromRGBO(255, 255, 255, 0.5), size: 20) : Icon(Icons.play_arrow, color: Color.fromRGBO(255, 255, 255, 1.0), size: 20),
              ),
              onTap: () => {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                })
              },
            ),
            left: constraints.constrainWidth() / 2 - 20,
            top: 30,
            height: 30,
            width: 30,
          ),
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
