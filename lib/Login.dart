import 'dart:async';
import 'dart:convert';
import 'package:hashtag/DBHelper.dart';
import 'package:hashtag/FirstLogin.dart';
import 'package:hashtag/Page_Controller.dart';
import 'package:hashtag/register.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:onesignal/onesignal.dart';

class Login extends StatefulWidget {
  Login();
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  bool _autovalidate = false;
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
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
                      autovalidate: _autovalidate,
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                          } else {
                                            _autovalidate = true;
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
                                                  Register(_username.text)));
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
      createsession(response.data, response.headers['set-cookie']);
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

  createsession(String response, header) async {
    var data = jsonDecode(response);
    if (data['status'] == 'success') {
      String userid = data['username'];
      String fullname = data['fullname'];
      String email = data['email'];
      String session = data['session'] == null
          ? header[0].toString().substring(10, 36)
          : data['session'];
      await OneSignal.shared.sendTag("user-id", userid);
      DBHelper dbHandler = new DBHelper();
      dbHandler.login(userid, fullname, email, session);
      Scaffold.of(contexts).showSnackBar(new SnackBar(
        content: Text(data['message']),
        backgroundColor: Colors.green,
      ));
      Future.delayed(Duration(seconds: 1), () {
        if (data['firsttime']) {
          Navigator.of(contexts).pushReplacement(
              MaterialPageRoute(builder: (contexts) => FirstLogin()));
        } else {
          Navigator.of(contexts).pushReplacement(
              MaterialPageRoute(builder: (contexts) => PagesController()));
        }
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
