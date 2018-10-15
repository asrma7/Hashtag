import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hashtag/Search_Item.dart';
import 'package:hashtag/Users.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';

List<Users> users;

Future<List> fetchUser(String searchstring, context) async {
  Dio dio = new Dio();
  Directory tempDir = await getApplicationDocumentsDirectory();
  String tempPath = tempDir.path;
  var cj = new PersistCookieJar(tempPath);
  dio.cookieJar = cj;
  if (searchstring.isNotEmpty) {
    final response = await dio.get(
        'http://hashtag2.gearhostpreview.com/search.php?query=' + searchstring);
    users.clear();
    for (int i = 0; i < jsonDecode(response.data).length; i++) {
      Users user = Users.fromJson(jsonDecode(response.data)[i]);
      users.add(user);
    }
  } else {
    users.clear();
  }
  return users;
}

class Searcher extends StatefulWidget {
  final Function changepage, removepage;
  Searcher(this.changepage, this.removepage);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearcherState();
  }
}

class _SearcherState extends State<Searcher> {
  String searchstring = "";
  @override
  Widget build(BuildContext context) {
    users = [];
    return Scaffold(
      //resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: (val) {
            setState(() {
              searchstring = val;
            });
          },
          decoration:
              InputDecoration(border: InputBorder.none, hintText: 'Search'),
        ),
      ),
      body: Center(
        child: FutureBuilder<List>(
          future: fetchUser(searchstring, context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                physics: new ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return SearchItem(
                    snapshot.data[index],
                    widget.changepage,
                  );
                },
                itemCount: snapshot.data.length,
              );
            } else if (snapshot.hasError) {
              return Text('Internal error occured!');
            }
            return Text('');
          },
        ),
      ),
    );
  }
}
