import 'dart:convert';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_textview/flutter_html_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hashtag/DBHelper.dart';
import 'package:hashtag/comment.dart';
import 'dart:async';

class Comments extends StatefulWidget {
  final String postid;
  Comments(this.postid);
  @override
  State<StatefulWidget> createState() {
    return _CommentsState();
  }
}

class _CommentsState extends State<Comments> {
  final _addcomment = TextEditingController();
  final focus = FocusNode();
  final Dio dio = new Dio();
  Future<List> fetchNotification(context) async {
    List<Comment> comments = [];
    Comment comment;

    DBHelper dbhandler = DBHelper();
    var session = await dbhandler.getSession();
    List<Cookie> cookies = [new Cookie("PHPSESSID", session)];
    var cj = new CookieJar();
    cj.saveFromResponse(
        Uri.parse('http://hashtag2.gearhostpreview.com'), cookies);
    dio.cookieJar = cj;
    comments.clear();
    await dio
        .get('http://hashtag2.gearhostpreview.com/commentlist.php?postid=' +
            widget.postid)
        .timeout(Duration(seconds: 15))
        .then((response) {
      for (int i = 0; i < jsonDecode(response.data).length; i++) {
        comment = Comment.fromJson(jsonDecode(response.data)[i]);
        comments.add(comment);
      }
    }).catchError((err) => print(err));
    return comments;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: FutureBuilder(
        future: fetchNotification(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Comment> comments = snapshot.data;
            return Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: comments.length,
                    physics: new ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      Widget button = (comments[index].me)
                          ? GestureDetector(
                              child: Icon(Icons.delete_outline),
                              onTap: () async {
                                dio
                                    .post(
                                        "http://hashtag2.gearhostpreview.com/delcom.php",
                                        data: FormData.from({
                                          "pid": widget.postid,
                                          "ID": comments[index].id
                                        }),
                                        options: Options(
                                            method: 'POST',
                                            responseType: ResponseType
                                                .PLAIN // or ResponseType.JSON
                                            ))
                                    .then((response) {
                                  setState(() {});
                                }).catchError((err) {
                                  print(err);
                                });
                              },
                            )
                          : Icon(FontAwesomeIcons.heart);
                      return Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(
                                    comments[index].dp,
                                    scale: 40.0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 3.0),
                              width: queryData.size.width - 84.0,
                              child: HtmlText(
                                data: '<b>' +
                                    comments[index].user +
                                    '</b> ' +
                                    comments[index].comment,
                              ),
                            ),
                            button,
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[200])),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 10.0),
                          width: queryData.size.width - 80.0,
                          child: TextFormField(
                            controller: _addcomment,
                            focusNode: focus,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Comment can\'t be empty';
                              }
                            },
                            onFieldSubmitted: (val) {
                              dio
                                  .post(
                                      "http://hashtag2.gearhostpreview.com/comment.php",
                                      data: FormData.from({
                                        "id": widget.postid,
                                        "comment": val
                                      }),
                                      options: Options(
                                          method: 'POST',
                                          responseType: ResponseType
                                              .PLAIN // or ResponseType.JSON
                                          ))
                                  .then((response) {
                                setState(() {});
                              });
                              _addcomment.clear();
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelStyle: TextStyle(color: Colors.black),
                              hintText: 'Add Comment',
                            ),
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            dio
                                .post(
                                    "http://hashtag2.gearhostpreview.com/comment.php",
                                    data: FormData.from({
                                      "id": widget.postid,
                                      "comment": _addcomment.text
                                    }),
                                    options: Options(
                                        method: 'POST',
                                        responseType: ResponseType
                                            .PLAIN // or ResponseType.JSON
                                        ))
                                .then((response) {
                              setState(() {});
                            });
                            _addcomment.clear();
                            focus.unfocus();
                          },
                          child: Text(
                            'Post',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error in connection');
          }
          return CupertinoActivityIndicator();
        },
      ),
    );
  }
}
