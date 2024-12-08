import 'package:flutter/material.dart';
import 'Constants.dart';

class TextElement extends StatelessWidget {
  final Map<dynamic, dynamic> data;
  final String receiver_id;
  final String sender_id;
  final bool isGroup;
  final bool isNew;

  TextElement({
    Key key,
    this.data,
    this.sender_id,
    this.receiver_id,
    this.isGroup,
    this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    DateTime tempTime = DateTime.parse(data['datetime']).toLocal();

    return (sender_id == data['sender_id'].toString())
        ? buildSenderMessage(context, tempTime)
        : buildReceiverMessage(context, tempTime);
  }

  Widget buildSenderMessage(BuildContext context, DateTime tempTime) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildDateContainer(context, tempTime),
          if (!isNew) buildSenderMessageDetails(context, tempTime),
          buildSenderMessageContent(context),
        ],
      ),
    );
  }

  Widget buildReceiverMessage(BuildContext context, DateTime tempTime) {
    return Container(
      child: Column(
        children: [
          buildDateContainer(context, tempTime),
          if (!isNew) buildReceiverMessageDetails(context, tempTime),
          buildReceiverMessageContent(context),
        ],
      ),
    );
  }

  Widget buildDateContainer(BuildContext context, DateTime tempTime) {
    return Container(
      margin: !isGroup ? EdgeInsets.symmetric(horizontal: MessageConstants.horizontalMargin) : null,
      decoration: !isGroup
          ? BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/strike.png'),
          fit: BoxFit.fill,
        ),
      )
          : null,
      width: MediaQuery.of(context).size.width,
      padding: !isGroup
          ? EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * MessageConstants.strikeImageWidth,
      )
          : null,
      child: !isGroup
          ? Container(
        color: Colors.white,
        child: Text(
          '${weekday[tempTime.weekday - 1] + ', ' + month[tempTime.month - 1] + '  ' + tempTime.day.toString() + ', ' + tempTime.year.toString()}',
          textAlign: TextAlign.center,
          style: TextStyle(height: 2, color: Colors.black38),
        ),
      )
          : Container(),
    );
  }

  Widget buildSenderMessageDetails(BuildContext context, DateTime tempTime) {
    return Container(
      alignment: Alignment.center, // Center the content
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the row content
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
          // Container removed
        ],
      ),
    );
  }

  Widget buildSenderMessageContent(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * MessageConstants.strikeImageWidth,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topRight,
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(241, 245, 248, 1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '${data['message']}',
                        softWrap: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          !isGroup || !isNew
              ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
            padding: EdgeInsets.only(top: 0),
            child: Image.asset(
              'assets/images/avatar3.png',
              width: 40,
              height: 40,
            ),
          )
              : Container(
            width: 40,
            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
          ),
        ],
      ),
    );
  }

  Widget buildReceiverMessageDetails(BuildContext context, DateTime tempTime) {
    return Container(
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.topLeft,
              child: buildMessageTime(context, tempTime),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReceiverMessageContent(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !isGroup || !isNew ? Container(
              decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
            padding: EdgeInsets.only(top: 0),
            child: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
            ),
          ) : Container(
            width: 40,
            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topLeft,
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(241, 245, 248, 1),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '${data['message']}',
                        softWrap: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * MessageConstants.strikeImageWidth,
          ),
        ],
      ),
    );
  }

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
}

class MessageConstants {
  static const double horizontalMargin = 7.0;
  static const double strikeImageWidth = 0.2;
// Add more constants as needed
}
