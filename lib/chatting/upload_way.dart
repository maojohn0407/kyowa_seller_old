import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import '../env.dart';
import 'package:http/http.dart' as http;
import 'dart:core';
import 'dart:convert';

class ChooseWay extends StatefulWidget {
  ChooseWay({Key key, this.info, this.sender, this.receiver}) : super(key: key);
  ChooseWayState createState() => ChooseWayState();
  final String info;
  final String receiver;
  final String sender;
}

class ChooseWayState extends State<ChooseWay> {
  int _searchValue = -1;
  String filename = '未选择文件。';
  String title = '';
  PlatformFile file;
  bool flagForWait = false;
  Future<http.StreamedResponse> uploadFile(
      String title, PlatformFile file) async {
    var request = http.MultipartRequest(
        "POST", Uri.parse(serverUrl + '/api' + environment[title + 'send']));

    request.headers['Authorization'] = widget.info;
    request.fields[title.toString()] = title;
    request.fields['receiver_id'] = widget.receiver;
    http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
      title,
      file.bytes,
      filename: file.name,
    );
    request.files.add(multipartFile);
    print(request.fields);
    return await request.send();
  }

  void sendMessage(message) async {

    DatabaseReference ref =
        FirebaseDatabase.instance.ref('$dbMessage/' + widget.receiver.toString());
    DatabaseReference newRef = ref.push();
    newRef.set(message);
  }

  Widget build(BuildContext context) {
    return (flagForWait)
        ? SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
            child: Image.asset('assets/images/loading.gif'),
          )
        : Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.audiotrack_rounded,
                            color: _searchValue == 0
                                ? Colors.blueAccent
                                : Colors.black,
                          ),
                          Text('Audio',
                              style: TextStyle(
                                color: _searchValue == 0
                                    ? Colors.blueAccent
                                    : Colors.black,
                              )),
                        ],
                      ),
                      onTap: () async {
                        if (_searchValue != 0) {
                          setState(() {
                            _searchValue = 0;
                          });
                          FilePickerResult result =
                              await FilePicker.platform.pickFiles(
                            withData: true,
                            type: FileType.audio,
                            allowMultiple: false,
                          );

                          if (result != null) {
                            file = result.files.first;
                            title = 'audio';
                            setState(() {
                              filename = file.name;
                            });
                          } else {
                            // User canceled the picker
                            setState(() {
                              filename = '未选择文件。';
                            });
                          }
                        } else {
                          title = '';
                          setState(() {
                            _searchValue = -1;
                            filename = '';
                          });
                        }
                      },
                    ),
                    GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            color: _searchValue == 1
                                ? Colors.blueAccent
                                : Colors.black,
                          ),
                          Text('Image',
                              style: TextStyle(
                                color: _searchValue == 1
                                    ? Colors.blueAccent
                                    : Colors.black,
                              )),
                        ],
                      ),
                      onTap: () async {
                        if (_searchValue != 1) {
                          setState(() {
                            _searchValue = 1;
                          });
                          FilePickerResult result =
                              await FilePicker.platform.pickFiles(
                            withData: true,
                            type: FileType.image,
                            allowMultiple: false,
                          );

                          if (result != null) {
                            file = result.files.first;
                            title = 'image';
                            setState(() {
                              filename = file.name;
                            });
                          } else {
                            // User canceled the picker
                            setState(() {
                              filename = '未选择文件。';
                            });
                          }
                        } else {
                          title = '';
                          setState(() {
                            _searchValue = -1;
                            filename = '';
                          });
                        }
                      },
                    ),
                    GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.ondemand_video,
                            color: _searchValue == 2
                                ? Colors.blueAccent
                                : Colors.black,
                          ),
                          Text('Video',
                              style: TextStyle(
                                color: _searchValue == 2
                                    ? Colors.blueAccent
                                    : Colors.black,
                              )),
                        ],
                      ),
                      onTap: () async {
                        if (_searchValue != 2) {
                          setState(() {
                            _searchValue = 2;
                          });
                          FilePickerResult result =
                              await FilePicker.platform.pickFiles(
                            withData: true,
                            type: FileType.video,
                            allowMultiple: false,
                          );

                          if (result != null) {
                            file = result.files.first;
                            title = 'video';
                            setState(() {
                              filename = file.name;
                            });
                          } else {
                            // User canceled the picker
                            setState(() {
                              filename = '未选择文件。';
                            });
                          }
                        } else {
                          title = '';
                          setState(() {
                            _searchValue = -1;
                            filename = '';
                          });
                        }
                      },
                    ),
                  ],
                ),
                Container(
                  child: Text(
                    filename,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4),
                  width: 150,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20)),
                ),
                TextButton(
                  onPressed: () async {
                    if (title != '' &&
                        file != null &&
                        filename != '未选择文件。') {
                      setState(() {
                        flagForWait = true;
                        filename = '未选择文件。';
                      });
                      uploadFile(title, file)
                          .then((http.StreamedResponse response) async {
                        if (response.statusCode == 200) {
                          var res = await http.Response.fromStream(response);
                          final result =
                              jsonDecode(res.body) as Map<String, dynamic>;
                          await http.post(
                              Uri.parse(serverUrl + '/api/getuserinfo'),
                              headers: {
                                'Authorization': widget.info
                              }).then((http.Response res) {
                            if (res.statusCode == 200) {
                              var user_id = json.decode(res.body)['user_id'];
                              var now = DateTime.now();
                              var message_object = {
                                "message": title + "/" + result[title],
                                "sender_id": user_id.toString(),
                                "receiver_id": widget.receiver,
                                "datetime": now.toUtc().toString(),
                              };
                              sendMessage(message_object);
                            } else {}
                          });
                          setState(() {
                            flagForWait = false;
                          });
                          title = '';
                          file = null;
                          Navigator.pop(context, true);
                        } else {
                          SnackBar sb = SnackBar(
                            content: Text('Please choose a file again.'),
                            duration: Duration(seconds: 4),
                            backgroundColor: Colors.redAccent,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(sb);
                        }
                      });
                    } else {
                      SnackBar sb = SnackBar(
                        content: Text('Please choose a file correctly.'),
                        duration: Duration(seconds: 4),
                        backgroundColor: Colors.redAccent,
                      );
                    }
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )
              ],
            ),
          );
  }
}
