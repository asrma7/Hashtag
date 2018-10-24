import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hashtag/DBHelper.dart';
import 'package:hashtag/ProfileDisplay.dart';
import 'package:hashtag/UserProfileo.dart';
import 'dart:async';

class Profileo extends StatelessWidget {
  final String user;
  Profileo(this.user);
  final Dio dio = new Dio();
  Future<UserProfileo> fetchProfile(context) async {
    DBHelper dbhandler = DBHelper();
    UserProfileo profile;
    var session = await dbhandler.getSession();
    List<Cookie> cookies = [new Cookie("PHPSESSID", session)];
    var cj = new CookieJar();
    cj.saveFromResponse(
        Uri.parse('http://hashtag2.gearhostpreview.com'), cookies);
    dio.cookieJar = cj;
    await dio
        .get('http://hashtag2.gearhostpreview.com/userprofile.php?user=' + user)
        .timeout(Duration(seconds: 15))
        .then((response) {
      profile = UserProfileo.fromJson(jsonDecode(response.data));
    });
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchProfile(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserProfileo profile = snapshot.data;
            return ProfileDisplay(profile, dio);
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Internal error occured!'),
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
}
