import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hashtag/Comments.dart';
import 'package:hashtag/profileo.dart';

import 'dart:async';

import './Posts.dart';

class PostItem extends StatefulWidget {
  final Dio dio;
  final Posts posts;
  PostItem(this.posts, this.dio);
  @override
  State<StatefulWidget> createState() {
    return _Post();
  }
}

class _Post extends State<PostItem> {
  double opacity = 0.0;
  @override
  Widget build(BuildContext context) {
    int likes = widget.posts.likecount;
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: 10.0,
              bottom: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  child: Row(
                    children: <Widget>[
                      new Container(
                        width: 50.0,
                        height: 50.0,
                        margin: EdgeInsets.only(
                          right: 10.0,
                        ),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(
                              widget.posts.usericon,
                              scale: 50.0,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        widget.posts.user,
                        style: TextStyle(
                          fontFamily: 'FreightSans',
                          fontSize: 15.0,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Profileo(widget.posts.user),
                      ),
                    );
                  },
                ),
                GestureDetector(
                  child: Icon(
                    FontAwesomeIcons.ellipsisV,
                    size: 20.0,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: doubletap,
            child: Container(
              child: Stack(
                children: [
                  Container(
                    height: 300.0,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: widget.posts.postimage,
                        placeholder: new CircularProgressIndicator(),
                        errorWidget: new Icon(Icons.error),
                      ),
                    ),
                  ),
                  Container(
                    height: 300.0,
                    child: Center(
                      child: Opacity(
                        opacity: opacity,
                        child: Icon(
                          FontAwesomeIcons.solidHeart,
                          size: 55.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    splashColor: Colors.transparent,
                    icon: Icon(
                      widget.posts.like
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      color: Color(
                        widget.posts.like ? 0xFFFF0000 : 0xFF000000,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (widget.posts.like) {
                          widget.posts.like = false;
                          widget.dio.post(
                              'http://hashtag2.gearhostpreview.com/unlike.php',
                              data: FormData.from({"ID": widget.posts.id}),
                              options: Options(
                                  method: 'POST',
                                  responseType:
                                      ResponseType.PLAIN // or ResponseType.JSON
                                  ));
                          widget.posts.likecount -= 1;
                        } else {
                          widget.posts.like = true;
                          widget.dio.post(
                              'http://hashtag2.gearhostpreview.com/like.php',
                              data: FormData.from({"ID": widget.posts.id}),
                              options: Options(
                                  method: 'POST',
                                  responseType: ResponseType.PLAIN));
                          widget.posts.likecount += 1;
                        }
                      });
                    },
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    icon: Icon(
                      FontAwesomeIcons.comment,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Comments(widget.posts.id),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    icon: Icon(
                      Icons.send,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              IconButton(
                splashColor: Colors.transparent,
                icon: Icon(
                  FontAwesomeIcons.save,
                ),
                onPressed: () {},
              ),
            ],
          ),
          Container(
            child: Text(
              '$likes Likes',
            ),
            width: double.infinity,
          ),
          Row(
            children: <Widget>[
              Text(
                widget.posts.user,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                ' ' + widget.posts.caption,
              ),
            ],
          ),
          Container(
            child: Text(
              'Tags: ' + widget.posts.tags,
            ),
            width: double.infinity,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Comments(widget.posts.id),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'View all comments',
                style: TextStyle(color: Colors.grey),
              ),
              width: double.infinity,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 5.0),
            child: Text(
              widget.posts.time + ' ago',
              style: TextStyle(color: Colors.grey),
            ),
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  void doubletap() {
    Future redo() async {
      await new Future.delayed(new Duration(milliseconds: 500), () {
        setState(() {
          opacity = 0.0;
        });
      });
    }

    setState(() {
      if (!widget.posts.like) {
        widget.dio.post('http://hashtag2.gearhostpreview.com/unlike.php',
            data: FormData.from({"ID": widget.posts.id}),
            options: Options(
                method: 'POST',
                responseType: ResponseType.PLAIN // or ResponseType.JSON
                ));
        widget.posts.likecount++;
      }
      widget.posts.like = true;
      opacity = 1.0;
    });
    redo();
  }
}
