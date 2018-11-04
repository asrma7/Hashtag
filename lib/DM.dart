import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hashtag/ChatDB.dart';
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
  ChatDB chatDB = new ChatDB();
  Dio dio = new Dio();
  DBHelper dbHelper = new DBHelper();
  bool send = false;
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  List<Messages> messages = [];
  List<Messages> webmsg = [];
  Future<List<Messages>> getdata(user) async {
    String types;
    messages.clear();
    webmsg.clear();
    var session = await dbHelper.getSession();
    List<Cookie> cookies = [new Cookie("PHPSESSID", session)];
    var cj = new CookieJar();
    cj.saveFromResponse(
        Uri.parse('http://hashtag2.gearhostpreview.com'), cookies);
    dio.cookieJar = cj;
    await dio
        .get('http://hashtag2.gearhostpreview.com/getmobilechat.php?user=' +
            user)
        .timeout(Duration(seconds: 15))
        .then((response) {
      var res = jsonDecode(response.data);
      for (int i = 0; i < res.length; i++) {
        types = res[i]["author"] == user ? "recieved" : "sent";
        Messages msg = Messages.fromJson(res[i], types);
        webmsg.add(msg);
      }
    });
    if (webmsg!=null) {
      messages = webmsg;
      savemsg(webmsg);
    }
    return messages;
  }

  void savemsg(List<Messages> webmsg) async {
    chatDB.deleteChats(widget.user);
    for (int i = 0; i < webmsg.length; i++) {
      chatDB.addchat(
          widget.user, webmsg[i].text, webmsg[i].time, webmsg[i].type);
    }
  }

  Future<List<Messages>> getdbdata(String user) async{
    return chatDB.getChats(user);
  }

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
    getdata(widget.user);
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
        title: Text(widget.user),
      ),
      body: Stack(
        children: <Widget>[
          Container(
              color: Colors.white,
              child: FutureBuilder(
                future: getdbdata(widget.user),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var msg = snapshot.data;
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.only(
                          top: 8.0, bottom: 60.0, right: 10.0, left: 10.0),
                      itemCount: msg.length,
                      itemBuilder: (context, index) {
                        return MessageView(msg[index]);
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error in connection!'),
                    );
                  }
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                },
              )),
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
    String username = await dbHelper.getUsername();
    users = username;
    socketChannel = IOWebSocketChannel.connect('wss://strong-roarer.glitch.me');
    socketChannel.sink.add('{"type":"username","content":"' + username + '"}');
    socketChannel.stream.listen((message) {
      if (jsonDecode(message)['type'] == 'message') {
        var data = jsonDecode(message)['data'];
        setState(() {
          if (data['author'] == username) {
            chatDB.addchat(widget.user, data['text'], data['time'], 'sent');
            messages.add(Messages.fromJson(data, 'sent'));
          } else {
            chatDB.addchat(widget.user, data['text'], data['time'], 'recieved');
            messages.add(Messages.fromJson(data, 'recieved'));
          }
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
