import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hashtag/register.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  final Function changepage, removepage;
  Login(this.changepage, this.removepage);
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String uname, password;
  bool _obscureText = true;
  bool _isButtonDisabled = false;
  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  var contexts;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        contexts = context;
        return Container(
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/background.jpg'),
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Image(
                    image: AssetImage('assets/icon.png'),
                    height: 100.0,
                  ),
                  Card(
                    margin: EdgeInsets.all(15.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              top: 10.0,
                              left: 10.0,
                              right: 10.0,
                              bottom: 20.0,
                            ),
                            child: TextFormField(
                              controller: _username,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Username can\'t be empty';
                                }
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.black12,
                                border: InputBorder.none,
                                labelStyle: TextStyle(color: Colors.black),
                                labelText: 'Username',
                                contentPadding:
                                    EdgeInsets.only(top: 10.0, left: 10.0),
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
                              controller: _password,
                              obscureText: _obscureText,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Password can\'t be empty';
                                }
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.black12,
                                contentPadding:
                                    EdgeInsets.only(top: 10.0, left: 10.0),
                                labelText: "Password",
                                labelStyle: TextStyle(color: Colors.black),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  onPressed: () => setState(
                                      () => _obscureText = !_obscureText),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: <Widget>[
                                RaisedButton(
                                  child: Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.lightBlue,
                                  onPressed: (!_isButtonDisabled)
                                      ? () {
                                          if (_formKey.currentState
                                              .validate()) {
                                            senddata(
                                                _username.text, _password.text);
                                            setState(() {
                                              _isButtonDisabled = true;
                                            });
                                          }
                                        }
                                      : null,
                                ),
                                RaisedButton(
                                    child: Text(
                                      'Register',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    color: Colors.lightBlue,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Register()));
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  senddata(uname, pass) async {
    Dio dio = new Dio();
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    var cj = new PersistCookieJar(tempPath);
    dio.cookieJar = cj;
    FormData formData = new FormData.from(
        {"uname": uname, "password": pass, "api": 'myhashtagapikey'});
    dio
        .post("http://hashtag2.gearhostpreview.com/mobile.php",
            data: formData,
            options: Options(
                method: 'POST',
                responseType: ResponseType.PLAIN // or ResponseType.JSON
                ))
        .timeout(Duration(seconds: 15))
        .then((response) {
      createsession(jsonDecode(response.data));
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

  createsession(Map<String, dynamic> data) async {
    if (data['status'] == 'success') {
      String session = data['session'];
      Directory tempDir = await getApplicationDocumentsDirectory();
      String tempPath = tempDir.path;
      List<Cookie> cookies = [new Cookie("PHPSESSID", session)];
      var cj = new PersistCookieJar(tempPath);
      cj.saveFromResponse(
          Uri.parse('http://hashtag2.gearhostpreview.com'), cookies);
      Scaffold.of(contexts).showSnackBar(new SnackBar(
        content: Text(data['message']),
        backgroundColor: Colors.green,
      ));
      Future.delayed(Duration(seconds: 1), () {
        widget.changepage(1);
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
  }
}
