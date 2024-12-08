import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'chartting_element.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import '../env.dart';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

class Chatting extends StatefulWidget {
  Chatting({Key key, this.data, this.receiver, this.flag, this.info})
      : super(key: key);
  ChattingState createState() => ChattingState();
  final List<Map> data;
  final String receiver;
  final bool flag;
  final String info;
}

class ChattingState extends State<Chatting> {
  Map<dynamic, dynamic> chatdata = {
    'text': '',
    'image': '',
    'audio': '',
    'video': '',
    'isuser': true
  };
  bool isRecording = false;

  final Widget recordingImage = Image.asset(
    'assets/images/icons8-sound.gif',
    fit: BoxFit.cover,
  );
  bool flag = true;
  GlobalKey _key = GlobalKey();
  ScrollController _scrollController;
  bool isAtTopOfChatList = true;
  TextEditingController _controller = TextEditingController(text: '');
  var tempJson = [];
  int getCount = 0;
  bool _needsScroll = false;
  String sendText = "";
  int user_id = 0;

  bool isAudioMessage = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    flag = widget.flag;

    http.post(Uri.parse(serverUrl + '/api/getuserinfo'), headers: {
      'Authorization': widget.info
    }).then((http.Response res) async {
      if (res.statusCode == 200) {
        user_id = json.decode(res.body)['user_id'];
        DatabaseReference ref =
            FirebaseDatabase.instance.ref('$dbMessage/${widget.receiver.toString()}');
        ref.onValue.listen((event) {
          if (event.snapshot.exists) {
            Map map = event.snapshot.value;
            var temp = [];
            map.forEach((key, value) {
              temp.add(value);
            });

            temp.sort((a, b) => DateTime.parse(a['datetime']).compareTo(DateTime.parse(b['datetime'])));
            setState(() {
              tempJson = temp;
              _needsScroll = true;
            });
          }
        });
      } else {}
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _scrollToEnd() async {
    _scrollController.animateTo(0,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  void sendMessage(message) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('$dbMessage/${widget.receiver}');
    DatabaseReference newRef = ref.push();
    await newRef.set(message);
    setState(() {
      _needsScroll = true;
    });
  }

  Widget build(BuildContext context) {
    if (_needsScroll) {
      _scrollToEnd();
      _needsScroll = false;
    }
    return Stack(children: <Widget>[
      Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(width: 5, color: myBlueColor),
              right: BorderSide(width: 5, color: myBlueColor),
              bottom: BorderSide(width: 5, color: myBlueColor),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: ListView(
                      controller: _scrollController,
                      reverse: true,
                      children: [
                        Column(
                            children: tempJson
                                .map((e) => ChatElement(
                                    chat_detail: e,
                                    sender_id: user_id.toString(),
                                    receiver_id: widget.receiver,
                                    isGroup: tempJson.indexOf(e) - 1 < 0
                                        ? null
                                        : tempJson[tempJson.indexOf(e) - 1]))
                                .toList(),
                          )
                      ],
                    )),
              ),
              Container(
                height: 70,
                padding: EdgeInsets.all(8.0),
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      child: Icon(
                        isAudioMessage ? Icons.keyboard : Icons.mic_none,
                        size: 30,
                      ),
                      onTap: () {
                        setState(() {
                          isAudioMessage = !isAudioMessage;
                        });
                      }
                    ),
                    SizedBox(width: 10),
                    isAudioMessage
                      ? Expanded(
                          child: GestureDetector(
                            onLongPressStart: (LongPressStartDetails start) {
                              startRecord();
                            },
                            onLongPressEnd: (LongPressEndDetails ending) {
                              stopRecord();
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                "按并 说话",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: TextField(
                            key: _key,
                            controller: _controller,
                            onChanged: (String val) {
                              chatdata['text'] = val;
                            },
                            onEditingComplete: () {
                              final SnackBar sb = SnackBar(
                                content: Text('Please Login Again. Something wrong would happen for Chatting'),
                                duration: Duration(seconds: 4),
                                backgroundColor: Color.fromRGBO(255, 0, 0, 1.0),
                              );
                              if (chatdata['text'] != '') {
                                sendText = chatdata['text'];
                                chatdata['text'] = '';
                                try {
                                  var now = DateTime.now();
                                  var message_object = {
                                    "message": sendText,
                                    "sender_id": user_id.toString(),
                                    "datetime": now.toUtc().toString(),
                                  };
                                  sendMessage(message_object);
                                  http.post(
                                      Uri.parse(serverUrl +
                                          '/api' +
                                          environment['textsend']),
                                      headers: {
                                        'Authorization': widget.info
                                      },
                                      body: {
                                        'message': sendText,
                                        'receiver_id': widget.receiver,
                                      }).then((http.Response res) {
                                    if (res.statusCode == 200) {
                                    // sendText = '';
                                      _controller.clear();
                                      //if you send the message scroll have to go to the bottom
                                      if (_scrollController.positions.isNotEmpty &&
                                          flag) {
                                        Future.delayed(
                                            Duration(milliseconds: 1000),
                                            () => {
                                                  _scrollController.animateTo(
                                                      _scrollController
                                                          .position.maxScrollExtent,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.easeOut),
                                                  flag = false,
                                                });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(sb);
                                    }
                                  });
                                } on Exception catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(sb);
                                }
                              }
                            },
                            decoration: InputDecoration(
                                filled: true,
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.send),
                                  alignment: Alignment.center,
                                  onPressed: () {
                                    final SnackBar sb = SnackBar(
                                      content: Text(
                                          'Please Login Again. Something wrong would happen for Chatting'),
                                      duration: Duration(seconds: 4),
                                      backgroundColor:
                                          Color.fromRGBO(255, 0, 0, 1.0),
                                    );
                                    if (chatdata['text'] != '') {
                                      sendText = chatdata['text'];
                                      try {
                                        var now = DateTime.now();
                                        var message_object = {
                                          "message": chatdata['text'],
                                          "sender_id": user_id.toString(),
                                          "datetime": now.toUtc().toString(),
                                        };
                                        chatdata['text'] = '';
                                        sendMessage(message_object);
                                        http.post(
                                            Uri.parse(serverUrl +
                                                '/api' +
                                                environment['textsend']),
                                            headers: {
                                              'Authorization': widget.info
                                            },
                                            body: {
                                              'message': sendText,
                                              'receiver_id': widget.receiver,
                                            }).then((http.Response res) {
                                          if (res.statusCode == 200) {
                                            sendText = '';
                                            _controller.clear();
                                            //if you send message by clicking send button
                                            if (_scrollController
                                                    .positions.isNotEmpty &&
                                                flag) {
                                              Future.delayed(
                                                  Duration(milliseconds: 1000),
                                                  () => {
                                                        _scrollController.animateTo(
                                                            _scrollController
                                                                .position
                                                                .maxScrollExtent,
                                                            duration: Duration(
                                                                milliseconds: 500),
                                                            curve: Curves.easeOut),
                                                        flag = false,
                                                      });
                                            }
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(sb);
                                          }
                                        });
                                      } on Exception catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(sb);
                                      }
                                    }
                                  },
                                ),
                                fillColor: Colors.black12,
                                hintText: 'Type a message',
                                hintStyle: TextStyle(),
                                isCollapsed: true,
                                contentPadding: EdgeInsets.all(12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                )),
                          ),
                        ),
                    SizedBox(
                      width: 10,
                    ),
                    // GestureDetector(
                    //   child: Icon(Icons.add_circle, color: myBlueColor, size: 30),
                    //   onTap: () async {
                    //     dynamic returnFlag = await showDialog<bool>(
                    //         context: context,
                    //         builder: (BuildContext context) {
                    //           return Dialog(
                    //             insetAnimationCurve: Curves.elasticInOut,
                    //             insetAnimationDuration: Duration(seconds: 2),
                    //             child: SizedBox(
                    //               width: MediaQuery.of(context).size.width * 0.8,
                    //               child: ChooseWay(
                    //                   info: widget.info,
                    //                   sender: user_id.toString(),
                    //                   receiver: widget.receiver),
                    //             ),
                    //           );
                    //         });
                    //     if (returnFlag == true) {
                    //       if (_scrollController.positions.isNotEmpty && flag) {
                    //         Future.delayed(
                    //             Duration(milliseconds: 1000),
                    //             () => {
                    //                   _scrollController.animateTo(
                    //                       _scrollController
                    //                           .position.maxScrollExtent,
                    //                       duration: Duration(milliseconds: 500),
                    //                       curve: Curves.easeOut),
                    //                   flag = false,
                    //                 });
                    //       }
                    //     }
                    //   },
                    // ),
                    // SizedBox(
                    //   width: 10,
                    // )
                  ],
                ),
              )
            ],
          )),
      if (isRecording) Positioned.fill(
        child: Center(
          child: Image.asset(
            'assets/images/icons8-sound.gif',
            fit: BoxFit.cover,
          ),
        ),
      ),
      if (isRecording) ModalBarrier(
        color: Colors.grey.withOpacity(0.5),
        dismissible: false,
      ),
    ]);
  }

  String recordFilePath;

  void startRecord() async {
    setState(() {
      isRecording = true;
    });
    recordFilePath = await getFilePath();
    RecordMp3.instance.start(recordFilePath, (type) {
      setState(() {});
    });
  }

  void stopRecord() async {
    setState(() {
      isRecording = false;
    });
    bool s = RecordMp3.instance.stop();
    if (s) {
      await uploadAudio().then((http.StreamedResponse response) async {
        if (response.statusCode == 200) {
          var res = await http.Response.fromStream(response);
          final result = jsonDecode(res.body) as Map<String, dynamic>;
          var now = DateTime.now();
          var message_object = {
            "message": "audio/" + result["audio"],
            "sender_id": user_id.toString(),
            "datetime": now.toUtc().toString(),
          };
          sendMessage(message_object);
        } else {
          SnackBar sb = SnackBar(
            content: Text('Please record again.'),
            duration: Duration(seconds: 4),
            backgroundColor: Colors.redAccent,
          );
          ScaffoldMessenger.of(context).showSnackBar(sb);
        }
      });
    }
  }

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    var filename = '${sdPath}/test_${getRandomString(8)}.mp3';
    return filename;
  }

  String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<http.StreamedResponse> uploadAudio() async {
    File file = File(recordFilePath);
    String title = "audio";

    var request = http.MultipartRequest(
        "POST", Uri.parse(serverUrl + '/api' + environment[title + 'send']));

    request.headers['Authorization'] = widget.info;
    request.fields[title.toString()] = title;
    request.fields['receiver_id'] = widget.receiver;
    http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
      title,
      await file.readAsBytes(),
      filename: path.basename(file.path),
    );
    request.files.add(multipartFile);
    print(request.fields);
    return await request.send();
  }
}
