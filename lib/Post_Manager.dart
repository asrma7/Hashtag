import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import './Posts.dart';
import './Post_Item.dart';

List<Posts> posts;
bool error = false;

class PostManager extends StatefulWidget {
  final ScrollController scrollcontrol;
  PostManager(this.scrollcontrol);
  @override
  State<StatefulWidget> createState() {
    return _PostManagerState();
  }
}

final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
    new GlobalKey<RefreshIndicatorState>();
final SnackBar snackBar = SnackBar(
    content: Text('No internet connection'), backgroundColor: Colors.red);

class _PostManagerState extends State<PostManager> {
  Dio dio = new Dio();
  Future<List> fetchPost(context) async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    var cj = new PersistCookieJar(tempPath);
    dio.cookieJar = cj;
    await dio
        .get('http://hashtag2.gearhostpreview.com/feed.php')
        .then((response) {
      Scaffold.of(context).removeCurrentSnackBar();
      posts.clear();
      for (int i = 0; i < jsonDecode(response.data).length; i++) {
        Posts post = Posts.fromJson(jsonDecode(response.data)[i]);
        posts.add(post);
      }
    }).catchError((err) {
      error = true;
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Container(
          height: 20.0,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Couldn't fetch feed!"),
                FlatButton(
                  child: Text('Reload'),
                  onPressed: () {
                    fetchPost(context);
                    setState(() => {});
                  },
                )
              ]),
        ),
        backgroundColor: Colors.red,
      ));
    });
    error = false;
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    posts = [];
    return Center(
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: FutureBuilder<List>(
          future: fetchPost(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (error) {
                return GestureDetector(
                  onTap: () {
                    //fetchPost(context);
                    setState(() {});
                  },
                  child: Text("Error Boy!!"),
                );
              }
              return ListView.builder(
                controller: widget.scrollcontrol,
                physics: new ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return PostItem(snapshot.data[index], dio);
                },
                itemCount: snapshot.data.length,
              );
            }
            // By default, show a loading spinner
            return Text(
              'Loading...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<Null> _refresh() {
    return fetchPost(context).then((posts) {
      setState(() => posts = posts);
    });
  }
}
