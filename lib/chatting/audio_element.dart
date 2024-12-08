import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../env.dart';
import 'package:flutter/cupertino.dart';
import 'Constants.dart';

class AudioElement extends StatelessWidget {
  final Map<dynamic, dynamic> data;
  final String receiver_id;
  final String sender_id;
  final bool isGroup;
  final bool isNew;
  AudioElement(
      {Key key, this.data, this.receiver_id, this.sender_id, this.isGroup, this.isNew});

  Widget build(BuildContext context) {

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

    DateTime tempTime = DateTime.parse(data['datetime']).toLocal();
    return (sender_id == data['sender_id'].toString())
        ? Column(children: [
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
                        child: Stack(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(149, 236, 105, 1.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0))),
                                margin: EdgeInsets.fromLTRB(
                                    MediaQuery.of(context).size.width * 0.55,
                                    7,
                                    10,
                                    10),
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                alignment: Alignment.center,
                                child: AudioApp(data['message'])),
                            Positioned(
                              top: 15,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                color: Color.fromRGBO(149, 236, 105, 1.0),
                                transform: new Matrix4.identity()
                                  ..rotateZ(45 * 3.1415927 / 180),
                              ),
                            )
                          ],
                        ),
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
                                width: MediaQuery.of(context).size.width * 0.1,
                              ),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.1,
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            )
                    ],
                  ),
                ),
              ])
        : Column(
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
                                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
                        child: Stack(
                          children: [
                            Positioned(
                              top: 15,
                              left: 10,
                              child: Container(
                                width: 10,
                                height: 10,
                                color: Color.fromRGBO(149, 236, 105, 1.0),
                                transform: new Matrix4.identity()
                                  ..rotateZ(45 * 3.1415927 / 180),
                              ),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(149, 236, 105, 1.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0))),
                                margin: EdgeInsets.fromLTRB(
                                    10,
                                    7,
                                    MediaQuery.of(context).size.width * 0.55,
                                    10),
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                alignment: Alignment.center,
                                child: AudioApp(data['message'])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
  }
}

class AudioApp extends StatefulWidget {

  final String videoUrl;
  AudioApp(this.videoUrl);

  @override
  _AudioAppState createState() => _AudioAppState();
}

class _AudioAppState extends State<AudioApp> {
  VideoPlayerController _controller;
  int isPlaying = 0;
  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
        Uri.parse(serverUrl + environment['chat_audio_url'] + widget.videoUrl))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _controller.addListener(checkVideo);
      });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${_controller.value.duration.inSeconds} "'),
                      _controller.value.isPlaying && isPlaying == 0
                          ? Image.asset(
                        'assets/images/playing_audio.gif',
                        width: 16,
                      )
                          : Image.asset(
                        'assets/images/normal_audio.png',
                        width: 16,
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    });
                  },
                )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('0 "'),
                      Image.asset(
                        'assets/images/normal_audio.png',
                        width: 16,
                      ),
                    ],
                  ),
          )
        ],
      );
    });
  }

  void checkVideo(){
    // Implement your calls inside these conditions' bodies :
    if(_controller.value.position == Duration(seconds: 0, minutes: 0, hours: 0)) {
      setState(() {
        isPlaying = 0;
      });
    }

    if(_controller.value.position == _controller.value.duration) {
      setState(() {
        isPlaying = 1;
      });
    }

  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
