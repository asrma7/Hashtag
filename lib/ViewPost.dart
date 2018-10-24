import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hashtag/DBHelper.dart';
import 'package:hashtag/Post_Item.dart';
import 'package:hashtag/Posts.dart';

class ViewPost extends StatelessWidget {
  final postid;
  ViewPost(this.postid);
  final Dio dio = new Dio();
  Future<Posts> fetchpost(context) async {
    Posts post;
    DBHelper dbhandler = DBHelper();
    var session = await dbhandler.getSession();
    List<Cookie> cookies = [new Cookie("PHPSESSID", session)];
    var cj = new CookieJar();
    cj.saveFromResponse(
        Uri.parse('http://hashtag2.gearhostpreview.com'), cookies);

    dio.cookieJar = cj;
    await dio
        .get('http://hashtag2.gearhostpreview.com/postview.php?id=' + postid)
        .timeout(Duration(seconds: 15))
        .then((response) {
      post = Posts.fromJson(jsonDecode(response.data));
    }).catchError((err) => print(err));
    return post;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      future: fetchpost(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Photo'),
            ),
            body: SingleChildScrollView(
              child: PostItem(snapshot.data, dio),
            ),
          );
        }
        return Scaffold(
          body: Center(
            child: CupertinoActivityIndicator(),
          ),
        );
      },
    );
  }
}
