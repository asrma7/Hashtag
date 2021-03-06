import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hashtag/ChangePassword.dart';
import 'package:hashtag/DBHelper.dart';
import 'package:hashtag/Login.dart';
import 'package:hashtag/Post_Item.dart';
import 'package:hashtag/UserProfile.dart';
import 'package:hashtag/ViewPost.dart';
import 'package:hashtag/editprofile.dart';
import 'package:onesignal/onesignal.dart';
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
  void showDemoDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        if (value == 'deactivate') {
          dio
        .get('http://hashtag2.gearhostpreview.com/delacc.php');
        }
      }
    });
  }

  Dio dio = new Dio();
  Future<UserProfile> fetchProfile(context) async {
    UserProfile profile;
    DBHelper dbhandler = DBHelper();
    var session = await dbhandler.getSession();
    List<Cookie> cookies = [new Cookie("PHPSESSID", session)];
    var cj = new CookieJar();
    cj.saveFromResponse(
        Uri.parse('http://hashtag2.gearhostpreview.com'), cookies);
    dio.cookieJar = cj;
    await dio
        .get('http://hashtag2.gearhostpreview.com/userprofile.php')
        .timeout(Duration(seconds: 15))
        .then((response) {
      profile = UserProfile.fromJson(jsonDecode(response.data));
    });
    return profile;
  }

  int views = 0;
  Widget view(profile) {
    if (views == 0) {
      return GridView.builder(
          itemCount: profile.post.length,
          gridDelegate:
              new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: CachedNetworkImage(
                imageUrl: profile.post[index].postimage,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ViewPost(profile.post[index].id),
                  ),
                );
              },
            );
          });
    } else if (views == 1) {
      return ListView.builder(
        itemBuilder: (context, index) {
          return PostItem(profile.post[index], dio);
        },
        itemCount: profile.post.length,
      );
    } else {
      return new Text("Not yet developed");
    }
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
                body: NestedScrollView(
                  headerSliverBuilder: (context, has) => <Widget>[
                        SliverAppBar(
                          pinned: true,
                          title: Text(profile.username),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            decoration: new BoxDecoration(color: Colors.white),
                            padding: EdgeInsets.only(
                                top: 5.0, left: 15.0, right: 15.0),
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
                                          image: new NetworkImage(
                                            profile.dp,
                                            scale: 100.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Container(
                                          width: queryData.size.width -
                                              100.0 -
                                              40.0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  Text(
                                                    profile.postcount
                                                        .toString(),
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
                                                    profile.followers
                                                        .toString(),
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
                                                    profile.followings
                                                        .toString(),
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
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          width: queryData.size.width -
                                              100.0 -
                                              40.0,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                Divider(),
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          views = 0;
                                        });
                                      },
                                      icon: Icon(Icons.grid_on),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          views = 1;
                                        });
                                      },
                                      icon: Icon(FontAwesomeIcons.square),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          views = 2;
                                        });
                                      },
                                      icon: Icon(FontAwesomeIcons.tag),
                                    ),
                                  ],
                                ),
                                Divider(),
                              ],
                            ),
                          ),
                        ),
                      ],
                  body: new Container(
                    decoration: new BoxDecoration(color: Colors.white),
                    child: view(profile),
                  ),
                ),
                bottomNavigationBar: BottomBar(widget.changepage),
                endDrawer: new Drawer(
                  semanticLabel: 'Profile Menu',
                  child: Container(
                    child: new ListView(children: <Widget>[
                      FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.send),
                            Container(
                              child: Text(
                                'Feedback',
                                style: TextStyle(fontSize: 17.0),
                              ),
                              padding: EdgeInsets.only(left: 10.0),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Row(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.powerOff),
                            Container(
                              child: Text(
                                'Log out',
                                style: TextStyle(fontSize: 17.0),
                              ),
                              padding: EdgeInsets.only(left: 10.0),
                            ),
                          ],
                        ),
                        onPressed: () {
                          DBHelper dbHelper = new DBHelper();
                          dbHelper.logout();
                          OneSignal.shared.deleteTag("user-id");
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => Login()));
                          dio.get(
                              'http://hashtag2.gearhostpreview.com/logout.php');
                        },
                      ),
                      FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Row(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.asterisk),
                            Container(
                              child: Text(
                                'Change Password',
                                style: TextStyle(fontSize: 17.0),
                              ),
                              padding: EdgeInsets.only(left: 10.0),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChangePassword()));
                        },
                      ),
                      FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete_forever),
                            Container(
                              child: Text(
                                'De-activate',
                                style: TextStyle(fontSize: 17.0),
                              ),
                              padding: EdgeInsets.only(left: 10.0),
                            ),
                          ],
                        ),
                        onPressed: () {
                          showDemoDialog<String>(
                            context: context,
                            child: CupertinoAlertDialog(
                              title: const Text('Are you Sure?'),
                              content: const Text(
                                  'You are about to DEACTIVATE your account.'
                                  'It cannot be restored at a later time! Continue?'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: const Text('Deactivate'),
                                  isDestructiveAction: true,
                                  onPressed: () {
                                    Navigator.pop(context, 'deactivate');
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context, 'Cancel');
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ]),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Internal Error occured!'),
                ),
                appBar: AppBar(
                  title: Text('Profile'),
                ),
                bottomNavigationBar: BottomBar(widget.changepage),
                endDrawer: new Drawer(
                  semanticLabel: 'Profile Menu',
                  child: Container(
                    child: new ListView(children: <Widget>[
                      FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.send),
                            Container(
                              child: Text(
                                'Feedback',
                                style: TextStyle(fontSize: 17.0),
                              ),
                              padding: EdgeInsets.only(left: 10.0),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Row(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.powerOff),
                            Container(
                              child: Text(
                                'Log out',
                                style: TextStyle(fontSize: 17.0),
                              ),
                              padding: EdgeInsets.only(left: 10.0),
                            ),
                          ],
                        ),
                        onPressed: () {
                          DBHelper dbHelper = new DBHelper();
                          dbHelper.logout();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => Login()));
                        },
                      ),
                      FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Row(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.asterisk),
                            Container(
                              child: Text(
                                'Change Password',
                                style: TextStyle(fontSize: 17.0),
                              ),
                              padding: EdgeInsets.only(left: 10.0),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete_forever),
                            Container(
                              child: Text(
                                'De-activate',
                                style: TextStyle(fontSize: 17.0),
                              ),
                              padding: EdgeInsets.only(left: 10.0),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ]),
                  ),
                ),
              );
            }
            return Scaffold(
              body: Center(
                child: CupertinoActivityIndicator(),
              ),
              bottomNavigationBar: BottomBar(widget.changepage),
              endDrawer: new Drawer(
                semanticLabel: 'Profile Menu',
                child: Container(
                  child: new ListView(children: <Widget>[
                    FlatButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.send),
                          Container(
                            child: Text(
                              'Feedback',
                              style: TextStyle(fontSize: 17.0),
                            ),
                            padding: EdgeInsets.only(left: 10.0),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Row(
                        children: <Widget>[
                          Icon(FontAwesomeIcons.powerOff),
                          Container(
                            child: Text(
                              'Log out',
                              style: TextStyle(fontSize: 17.0),
                            ),
                            padding: EdgeInsets.only(left: 10.0),
                          ),
                        ],
                      ),
                      onPressed: () {
                        DBHelper dbHelper = new DBHelper();
                        dbHelper.logout();
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                    ),
                    FlatButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Row(
                        children: <Widget>[
                          Icon(FontAwesomeIcons.asterisk),
                          Container(
                            child: Text(
                              'Change Password',
                              style: TextStyle(fontSize: 17.0),
                            ),
                            padding: EdgeInsets.only(left: 10.0),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.delete_forever),
                          Container(
                            child: Text(
                              'De-activate',
                              style: TextStyle(fontSize: 17.0),
                            ),
                            padding: EdgeInsets.only(left: 10.0),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ]),
                ),
              ),
            );
          }),
    );
  }
}
