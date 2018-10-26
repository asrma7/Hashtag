import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:hashtag/ChatDB.dart';
import 'package:hashtag/DM.dart';

class DirectMessages extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DirectMessagesState();
  }
}

class _DirectMessagesState extends State<DirectMessages> {
  @override
  Widget build(BuildContext context) {
    ChatDB chatDB = new ChatDB();
    Future<List> _getchats() async {
      return await chatDB.getchats();
    }

    return Scaffold(
      appBar: new AppBar(
        title: Text('Direct'),
      ),
      body: FutureBuilder(
        future: _getchats(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            List list = snapshot.data;
            String chatuser;
            //chatDB.addchat('User');
            return ListView.builder(
              itemBuilder: (context, ind) {
                chatuser = list[ind]['name'];
                if (chatuser != 'android_metadata') {
                  return GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12)),
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        chatuser,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17.0),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DM(
                                user: list[ind]['name'],
                              )));
                    },
                  );
                } else {
                  return Container();
                }
              },
              itemCount: list.length,
            );
          } else if (snapshot.hasError) {
            return Text('No Direct Messages');
          }
          return CupertinoActivityIndicator();
        },
      ),
    );
  }
}
