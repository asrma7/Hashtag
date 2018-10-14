import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hashtag/DM.dart';
import 'package:hashtag/Post_Item.dart';
import 'package:hashtag/UserProfileo.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class Profileo extends StatefulWidget {
  final String user;
  Profileo(this.user);
  @override
  State<StatefulWidget> createState() {
    return _ProfileoState();
  }
}

class _ProfileoState extends State<Profileo> {
  Dio dio = new Dio();
  UserProfileo profile;
  Future<UserProfileo> fetchProfile(context) async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    var cj = new PersistCookieJar(tempPath);
    dio.cookieJar = cj;
    await dio
        .get('http://hashtag2.gearhostpreview.com/userprofile.php?user=' +
            widget.user)
        .timeout(Duration(seconds: 15))
        .then((response) {
      profile = UserProfileo.fromJson(jsonDecode(response.data));
    }).catchError((err) => print(err));
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    return FutureBuilder(
        future: fetchProfile(context),
        builder: (context, snapshot) {
          Widget button;
          if (snapshot.hasData) {
            UserProfileo profile = snapshot.data;
            if (profile.following == 0) {
              button = Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    height: 35.0,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: FlatButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Text('message'),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => DM()));
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    height: 35.0,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: FlatButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Icon(FontAwesomeIcons.userCheck),
                      onPressed: _unfollow,
                    ),
                  ),
                ],
              );
            } else if (profile.fan) {
              button = Container(
                margin: EdgeInsets.only(top: 10.0),
                height: 35.0,
                color: Colors.lightBlue,
                child: FlatButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.lightBlue[200],
                  child: Text(
                    'follow back',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    dio
                        .post('http://hashtag2.gearhostpreview.com/follow.php',
                            data: FormData.from({"ID": profile.id}))
                        .then((response) {
                      setState(() {
                        fetchProfile(context);
                      });
                    });
                  },
                ),
              );
            } else {
              button = Container(
                margin: EdgeInsets.only(top: 10.0),
                height: 35.0,
                color: Colors.lightBlue,
                child: FlatButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.lightBlue[200],
                  child: Text(
                    'follow',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    dio
                        .post('http://hashtag2.gearhostpreview.com/follow.php',
                            data: FormData.from({"ID": profile.id}))
                        .then((response) {
                      setState(() {
                        fetchProfile(context);
                      });
                    });
                  },
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(profile.username),
                    GestureDetector(
                      child: Icon(
                        FontAwesomeIcons.ellipsisV,
                        size: 20.0,
                      ),
                    )
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 100.0,
                                  height: 100.0,
                                  margin: EdgeInsets.only(
                                    right: 10.0,
                                  ),
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new CachedNetworkImageProvider(
                                        profile.dp,
                                        scale: 100.0,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: <Widget>[
                                    Container(
                                      width:
                                          queryData.size.width - 100.0 - 40.0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                profile.postcount.toString(),
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text('posts'),
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                profile.followers.toString(),
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text('followers'),
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                profile.followings.toString(),
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text('following'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width:
                                          queryData.size.width - 100.0 - 40.0,
                                      child: button,
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.all(10.0),
                              padding: EdgeInsets.only(top: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    profile.fullname,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(profile.status),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      DefaultTabController(
                        length: 3,
                        child: new Column(
                          children: <Widget>[
                            new TabBar(
                              indicatorColor: Colors.transparent,
                              tabs: <Widget>[
                                Icon(Icons.grid_on),
                                Icon(FontAwesomeIcons.square),
                                Icon(FontAwesomeIcons.tag),
                              ],
                            ),
                            Divider(),
                            Container(
                              height: queryData.size.height - 130.0,
                              child: new TabBarView(
                                children: <Widget>[
                                  new GridView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: profile.post.length,
                                      gridDelegate:
                                          new SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return CachedNetworkImage(
                                          imageUrl:
                                              profile.post[index].postimage,
                                        );
                                      }),
                                  new ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return PostItem(profile.post[index], dio);
                                    },
                                    itemCount: profile.post.length,
                                  ),
                                  new Text("Hello Flutter"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error in connection'),
              ),
            );
          }
          return Scaffold(
            body: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        });
  }

  Future<Null> _unfollow() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unfollow'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You will never be satisfied.'),
                Text('You\’re like me. I’m never satisfied.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Unfollow'),
              onPressed: () {
                dio
                    .post('http://hashtag2.gearhostpreview.com/follow.php',
                        data: FormData.from({"ID": profile.id}),
                        options: Options(responseType: ResponseType.PLAIN))
                    .then((response) {
                  print(response.data);
                  Navigator.of(context, rootNavigator: true).pop();
                  setState(() {
                    fetchProfile(context);
                  });
                });
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
