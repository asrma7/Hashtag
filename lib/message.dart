import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hashtag/msg.dart';
import 'package:intl/intl.dart';

class MessageView extends StatefulWidget {
  final Messages messages;
  final String username;
  MessageView(this.messages, this.username);
  @override
  State<StatefulWidget> createState() {
    return _MessagesState();
  }
}

class _MessagesState extends State<MessageView> {
  bool showtime = false;
  @override
  Widget build(BuildContext context) {
    Messages messages = widget.messages;
    DateTime dd = new DateTime.fromMillisecondsSinceEpoch(messages.time);
    var formatter = new DateFormat('hh:mm a');
    String formatted = formatter.format(dd);
    if (messages.text == "::hash::") {
      return Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: messages.author == widget.username
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          Flex(
            direction: Axis.vertical,
            children: <Widget>[
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Icon(FontAwesomeIcons.solidHeart,size: 35.0,color: Colors.red[600],),
                ),
                onTap: () {
                  setState(() {
                    showtime = !showtime;
                  });
                },
              ),
              Opacity(
                opacity: showtime ? 1.0 : 0.0,
                child: Text(
                  formatted,
                  style: TextStyle(fontSize: 10.0, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: messages.author == widget.username
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: <Widget>[
        Flex(
          direction: Axis.vertical,
          children: <Widget>[
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                margin: EdgeInsets.symmetric(vertical: 2.5),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: messages.author == widget.username
                    ? BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                      )
                    : BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                      ),
                child:
                    Text(messages.text, style: TextStyle(color: Colors.black)),
              ),
              onTap: () {
                setState(() {
                  showtime = !showtime;
                });
              },
            ),
            Opacity(
              opacity: showtime ? 1.0 : 0.0,
              child: Text(
                formatted,
                style: TextStyle(fontSize: 10.0, color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
