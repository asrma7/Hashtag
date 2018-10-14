import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hashtag/Post_Item.dart';
import 'package:hashtag/UserProfile.dart';
import 'package:hashtag/editprofile.dart';
import 'package:path_provider/path_provider.dart';
import './BottomBar.dart';
import 'dart:async';

class Profile extends StatefulWidget {
  final Function changepage, removepage;
  Profile(this.changepage, this.removepage);
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  Dio dio = new Dio();
  Future<UserProfile> fetchProfile(context) async {
    UserProfile profile;
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    var cj = new PersistCookieJar(tempPath);
    dio.cookieJar = cj;
    await dio
        .get('http://hashtag2.gearhostpreview.com/userprofile.php')
        .timeout(Duration(seconds: 15))
        .then((response) {
      profile = UserProfile.fromJson(jsonDecode(response.data));
    }).catchError((err) => print(err));
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () {
        widget.removepage();
        return new Future(() => false);
      },
      child: FutureBuilder(
          future: fetchProfile(context),
          builder: (context, snapshot) {
            UserProfile profile = snapshot.data;
            if (snapshot.hasData) {
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
                                        margin: EdgeInsets.only(top: 10.0),
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        width:
                                            queryData.size.width - 100.0 - 40.0,
                                        height: 35.0,
                                        child: FlatButton(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          child: Text('Edit Profile'),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProfile()));
                                          },
                                        ),
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
                                      physics: ClampingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return PostItem(
                                            profile.post[index], dio);
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
                bottomNavigationBar: BottomBar(widget.changepage),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error in connection'),
                ),
                bottomNavigationBar: BottomBar(widget.changepage),
              );
            }
            return Scaffold(
              body: Center(
                child: CupertinoActivityIndicator(),
              ),
              bottomNavigationBar: BottomBar(widget.changepage),
            );
          }),
    );
  }
}
