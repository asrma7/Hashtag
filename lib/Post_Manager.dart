import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:hashtag/DBHelper.dart';
import 'dart:convert';

import 'package:hashtag/Posts.dart';
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
    DBHelper dbhandler = DBHelper();
    var session = await dbhandler.getSession();
    List<Cookie> cookies = [new Cookie("PHPSESSID", session)];
    var cj = new CookieJar();
    cj.saveFromResponse(
        Uri.parse('http://hashtag2.gearhostpreview.com'), cookies);
    dio.cookieJar = cj;
    var count = await dbhandler.postCount();
    if (count > 0) {
      var postlist = await dbhandler.getPosts();
      return postlist;
    } else {
      return netPost(context);
    }
  }

  Future<List> netPost(context) async {
    DBHelper dbhandler = DBHelper();
    var session = await dbhandler.getSession();
    List<Cookie> cookies = [new Cookie("PHPSESSID", session)];
    var cj = new CookieJar();
    cj.saveFromResponse(
        Uri.parse('http://hashtag2.gearhostpreview.com'), cookies);
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
                    netPost(context);
                    setState(() => {});
                  },
                )
              ]),
        ),
        backgroundColor: Colors.red,
      ));
    });
    error = false;
    dbhandler.savePosts(posts);
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
            } else if (snapshot.hasError) {
              print(snapshot.error);
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
    return netPost(context).then((posts) {
      setState(() => posts = posts);
    });
  }
}
