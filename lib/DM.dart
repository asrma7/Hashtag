import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hashtag/DBHelper.dart';
import 'package:hashtag/message.dart';
import 'package:hashtag/msg.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DM extends StatefulWidget {
  final String user;
  DM({@required this.user});
  @override
  State<StatefulWidget> createState() {
    return _DMState();
  }
}

class _DMState extends State<DM> {
  String users;
  bool send = false;
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  List<Messages> messages = [];
  WebSocketChannel socketChannel;
  @override
  void initState() {
    _controller.addListener(() {
      if (_controller.text.length == 0) {
        setState(() {
          send = false;
        });
      } else {
        setState(() {
          send = true;
        });
      }
    });
    _getMessage();
    super.initState();
  }

  @override
  void dispose() {
    socketChannel.sink.close();
    _controller.dispose();
    super.dispose();
  }
  @override
  void deactivate() {
    socketChannel.sink.close();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text("Direct"),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(
                  top: 8.0, bottom: 60.0, right: 10.0, left: 10.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageView(messages[index], users);
              },
            ),
          ),
          Positioned(
            bottom: 0.0,
            child: Container(
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 10.0),
                      width: MediaQuery.of(context).size.width - 70.0,
                      child: TextFormField(
                        controller: _controller,
                        onFieldSubmitted: (val) {
                          _sendMessage();
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Message',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(send ? Icons.send : FontAwesomeIcons.heart),
                      onPressed: send
                          ? _sendMessage
                          : () {
                              socketChannel.sink.add(
                                  '{"type":"message", "content":"::hash::", "to":"' +
                                      widget.user +
                                      '"}');
                            },
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      socketChannel.sink.add('{"type":"message", "content":"' +
          _controller.text +
          '", "to":"' +
          widget.user +
          '"}');
      _controller.clear();
    }
  }

  void _getMessage() async {
    DBHelper dbHelper = new DBHelper();
    String username = await dbHelper.getUsername();
    users = username;
    socketChannel = IOWebSocketChannel.connect('wss://strong-roarer.glitch.me');
    socketChannel.sink.add('{"type":"username","content":"' + username + '"}');
    socketChannel.stream.listen((message) {
      if (jsonDecode(message)['type'] == 'message') {
        setState(() {
          messages.add(Messages.fromJson(jsonDecode(message)['data']));
        });
        if (_scrollController.position.maxScrollExtent > 50 &&
            _scrollController.position.pixels - 50 <
                _scrollController.position.maxScrollExtent) {
          _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent + 50);
        }
      } else if (jsonDecode(message)['type'] != null) {
        print(message);
      }
    });
  }
}
