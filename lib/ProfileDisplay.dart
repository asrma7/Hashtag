import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hashtag/DM.dart';
import 'package:hashtag/Post_Item.dart';
import 'package:hashtag/UserProfileo.dart';
import 'package:hashtag/ViewPost.dart';

class ProfileDisplay extends StatefulWidget {
  final UserProfileo profile;
  final Dio dio;
  ProfileDisplay(this.profile, this.dio);
  @override
  State<StatefulWidget> createState() {
    return _ProfileDisplayState();
  }
}

class _ProfileDisplayState extends State<ProfileDisplay> {
  void showDemoDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        if (value == 'unfollow') {
          widget.dio.post('http://hashtag2.gearhostpreview.com/follow.php',
              data: FormData.from({"ID": widget.profile.id}),
              options: Options(responseType: ResponseType.PLAIN));
          setState(() {
            widget.profile.following = 1;
          });
        }
      }
    });
  }

  int views = 0;
  Widget view(profile, dio) {
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
    Dio dio = widget.dio;
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    Widget button;
    UserProfileo profile = widget.profile;
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
                  MaterialPageRoute(
                    builder: (context) => DM(
                          user: profile.username,
                        ),
                  ),
                );
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
              onPressed: () {
                showDemoDialog<String>(
                  context: context,
                  child: CupertinoAlertDialog(
                    title: const Text('Are you Sure?'),
                    content: Text('You are about to Unfollow ' +
                        profile.fullname +
                        '.'
                        'Continue?'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: const Text('Unfollow'),
                        isDestructiveAction: true,
                        onPressed: () {
                          Navigator.pop(context, 'unfollow');
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
            dio.post('http://hashtag2.gearhostpreview.com/follow.php',
                data: FormData.from({"ID": profile.id}),
                options: Options(responseType: ResponseType.PLAIN));
            setState(() {
              widget.profile.following = 0;
              profile.following = 0;
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
            dio.post('http://hashtag2.gearhostpreview.com/follow.php',
                data: FormData.from({"ID": profile.id}),
                options: Options(responseType: ResponseType.PLAIN));
            setState(() {
              widget.profile.following = 0;
            });
          },
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, has) => <Widget>[
              SliverAppBar(
                pinned: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(profile.username),
                    GestureDetector(
                      child: Icon(
                        FontAwesomeIcons.bars,
                        size: 20.0,
                      ),
                    )
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: new BoxDecoration(color: Colors.white),
                  padding: EdgeInsets.only(top: 5.0, left: 15.0, right: 15.0),
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
                                width: queryData.size.width - 100.0 - 40.0,
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
                                              fontWeight: FontWeight.bold),
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
                                              fontWeight: FontWeight.bold),
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
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text('following'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: queryData.size.width - 100.0 - 40.0,
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
                      Divider(),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          child: view(profile, dio),
        ),
      ),
    );
  }
}
