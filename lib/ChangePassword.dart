import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hashtag/DBHelper.dart';

class ChangePassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChangePasswordState();
  }
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _autovalidate = false;
  final TextEditingController _oldpassword = TextEditingController();
  final TextEditingController _newpassword = TextEditingController();
  bool _obscureText = true;
  bool _obscureText2 = true;
  bool _obscureText3 = true;
  bool _isButtonDisabled = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (contexts) {
          senddata(oldpass, newpass) async {
            Dio dio = new Dio();
            DBHelper dbHelper = new DBHelper();
            var session = await dbHelper.getSession();
            List<Cookie> cookies = [new Cookie("PHPSESSID", session)];
            var cj = new CookieJar();
            cj.saveFromResponse(
                Uri.parse('http://hashtag2.gearhostpreview.com'), cookies);
            dio.cookieJar = cj;
            FormData formData = new FormData.from({
              "opassword": oldpass,
              "cpassword": newpass,
              "api": 'myhashtagapikey'
            });
            dio
                .post("http://hashtag2.gearhostpreview.com/pass.php",
                    data: formData,
                    options: Options(
                        method: 'POST',
                        responseType: ResponseType.PLAIN // or ResponseType.JSON
                        ))
                .timeout(Duration(seconds: 15))
                .then((response) {
              Map<String, dynamic> data = jsonDecode(response.data);
              if (data['status'] == 'success') {
                Scaffold.of(contexts).showSnackBar(new SnackBar(
                  content: Text(data['message']),
                  backgroundColor: Colors.green,
                ));
                Future.delayed(Duration(seconds: 1), () {
                  Navigator.of(context).pop();
                });
              } else {
                Scaffold.of(contexts).showSnackBar(new SnackBar(
                  content: Text(data['message']),
                  backgroundColor: Colors.red,
                ));
                setState(() {
                  _isButtonDisabled = false;
                });
              }
            }).catchError((error) {
              Scaffold.of(contexts).showSnackBar(new SnackBar(
                content: Text('Check your internet connection'),
                backgroundColor: Colors.red,
              ));
              print(error);
              setState(() {
                _isButtonDisabled = false;
              });
            });
          }

          return Container(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Card(
                  child: Form(
                    autovalidate: _autovalidate,
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Change Password',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.blueGrey),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 10.0,
                            left: 10.0,
                            right: 10.0,
                            bottom: 20.0,
                          ),
                          child: TextFormField(
                            controller: _oldpassword,
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value.length < 6) {
                                return 'Password can\'t be less than 6 letters';
                              }
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.black12,
                              contentPadding:
                                  EdgeInsets.only(top: 10.0, left: 10.0),
                              labelText: "Old-Password",
                              labelStyle: TextStyle(color: Colors.black),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () => setState(
                                    () => _obscureText = !_obscureText),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 10.0,
                            left: 10.0,
                            right: 10.0,
                            bottom: 20.0,
                          ),
                          child: TextFormField(
                            controller: _newpassword,
                            obscureText: _obscureText2,
                            validator: (value) {
                              if (value.length < 6) {
                                return 'Password can\'t be less than 6 letters';
                              }
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.black12,
                              contentPadding:
                                  EdgeInsets.only(top: 10.0, left: 10.0),
                              labelText: "New-Password",
                              labelStyle: TextStyle(color: Colors.black),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () => setState(
                                    () => _obscureText2 = !_obscureText2),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 10.0,
                            left: 10.0,
                            right: 10.0,
                            bottom: 20.0,
                          ),
                          child: TextFormField(
                            obscureText: _obscureText3,
                            validator: (value) {
                              if (value != _newpassword.text) {
                                return 'Password don\'t match';
                              }
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.black12,
                              contentPadding:
                                  EdgeInsets.only(top: 10.0, left: 10.0),
                              labelText: "Re-Password",
                              labelStyle: TextStyle(color: Colors.black),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () => setState(
                                    () => _obscureText3 = !_obscureText3),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: RaisedButton(
                            child: Text(
                              'Change',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.lightBlue,
                            onPressed: (!_isButtonDisabled)
                                ? () {
                                    if (_formKey.currentState.validate()) {
                                      senddata(
                                          _oldpassword.text, _newpassword.text);
                                      setState(() {
                                        _isButtonDisabled = true;
                                      });
                                    } else {
                                      _autovalidate = true;
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
