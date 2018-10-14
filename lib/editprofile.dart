import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hashtag/ProfileEditor.dart';
import 'package:hashtag/userdata.dart';
import 'package:path_provider/path_provider.dart';

class EditProfile extends StatelessWidget {
  final Dio dio = new Dio();
  Future<UserData> fetchuser(context) async {
    UserData profile = new UserData();
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    var cj = new PersistCookieJar(tempPath);
    dio.cookieJar = cj;
    await dio
        .get('http://hashtag2.gearhostpreview.com/getprofile.php')
        .timeout(Duration(seconds: 15))
        .then((response) {
      profile = UserData.fromJson(jsonDecode(response.data));
    }).catchError((err) => print(err));
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: FutureBuilder(
        future: fetchuser(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = snapshot.data;
            return ProfileEditor(userData);
          } else if (snapshot.hasError) {
            print(snapshot.error);
          }
          return Center(
            child: CupertinoActivityIndicator(),
          );
        },
      ),
    );
  }
}
