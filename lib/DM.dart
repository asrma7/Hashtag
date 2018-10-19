import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DM extends StatefulWidget {
  final WebSocketChannel socketChannel;
  DM({@required this.socketChannel});
  @override
  State<StatefulWidget> createState() {
    return _DMState();
  }
}

class _DMState extends State<DM> {
  bool send = false;
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  List<Messages> messages = [];
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
    _controller.dispose();
    super.dispose();
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
                return Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: index % 3 == 0
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                      margin: EdgeInsets.symmetric(vertical: 2.5),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: index % 3 == 0
                          ? BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                            )
                          : BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                            ),
                      child: Text(messages[index].text,
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                );
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
                              widget.socketChannel.sink.add('#');
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
      widget.socketChannel.sink.add(_controller.text);
      _controller.clear();
    }
  }

  void _getMessage() async {
    widget.socketChannel.stream.listen((message) {
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

class Messages {
  final String text, author;
  final int time;
  Messages({
    this.time,
    this.text,
    this.author,
  });
  factory Messages.fromJson(Map<String, dynamic> json) {
    return Messages(
        time: json['time'], text: json['text'], author: json['author']);
  }
}
