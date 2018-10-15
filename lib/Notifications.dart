import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_textview/flutter_html_text.dart';
import 'package:hashtag/ViewPost.dart';
import 'package:hashtag/notification.dart';
import 'package:hashtag/profileo.dart';
import 'package:path_provider/path_provider.dart';
import './BottomBar.dart';
import 'dart:async';

class Notifications extends StatelessWidget {
  final Function changepage, removepage;
  Notifications(this.changepage, this.removepage);
  final Dio dio = new Dio();
  Future<List> fetchNotification(context) async {
    List<Notificationo> notifications = [];
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    var cj = new PersistCookieJar(tempPath);
    dio.cookieJar = cj;
    await dio
        .get('http://hashtag2.gearhostpreview.com/notification.php')
        .timeout(Duration(seconds: 15))
        .then((response) {
      for (int i = 0; i < jsonDecode(response.data).length; i++) {
        Notificationo notification =
            Notificationo.fromJson(jsonDecode(response.data)[i]);
        notifications.add(notification);
      }
    }).catchError((err) => print(err));
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () {
        removepage();
        return new Future(() => false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
        ),
        body: Container(
          margin: EdgeInsets.all(10.0),
          child: FutureBuilder(
            future: fetchNotification(context),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Notificationo> notificationo = snapshot.data;
                return ListView.builder(
                  itemCount: notificationo.length,
                  physics: new ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (notificationo[index].type == "profile") {
                      return GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 40.0,
                                height: 40.0,
                                margin: EdgeInsets.only(
                                  right: 10.0,
                                ),
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new NetworkImage(
                                      notificationo[index].dp,
                                      scale: 40.0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: queryData.size.width - 90.0,
                                child: HtmlText(
                                  data: '<b>' +
                                      notificationo[index].user +
                                      '</b> ' +
                                      notificationo[index].notify,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  Profileo(notificationo[index].id),
                            ),
                          );
                        },
                      );
                    } else {
                      return GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 40.0,
                                height: 40.0,
                                margin: EdgeInsets.only(
                                  right: 10.0,
                                ),
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new NetworkImage(
                                      notificationo[index].dp,
                                      scale: 40.0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: queryData.size.width - 140.0,
                                child: HtmlText(
                                  data: '<b>' +
                                      notificationo[index].user +
                                      '</b> ' +
                                      notificationo[index].notify,
                                ),
                              ),
                              CachedNetworkImage(
                                imageUrl: notificationo[index].posticon,
                                height: 50.0,
                                width: 50.0,
                              )
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewPost(notificationo[index].id),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              }
              return Scaffold(
                body: Center(
                  child: CupertinoActivityIndicator(),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: BottomBar(changepage),
      ),
    );
  }
}
