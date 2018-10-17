import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final String username;
  Register(this.username);
  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _username.text = widget.username;
    super.initState();
  }

  bool _autovalidate = false;
  String uname, password;
  bool _obscureText = true;
  bool _isButtonDisabled = false;
  @override
  void dispose() {
    _username.dispose();
    _fullname.dispose();
    _email.dispose();
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
          child: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                ),
                Container(
                  margin: EdgeInsets.only(top: 30.0),
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
                                    } else if (value.length < 6) {
                                      return 'Username must be atleast of 6 characters';
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
                                  controller: _fullname,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Fullname can\'t be empty';
                                    }
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black12,
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(color: Colors.black),
                                    labelText: 'Fullname',
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
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    Pattern pattern =
                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                    RegExp regex = new RegExp(pattern);
                                    if (!regex.hasMatch(value))
                                      return 'Enter Valid Email';
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black12,
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(color: Colors.black),
                                    labelText: 'Email',
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
                              Container(
                                margin: EdgeInsets.only(
                                  top: 10.0,
                                  left: 10.0,
                                  right: 10.0,
                                  bottom: 20.0,
                                ),
                                child: TextFormField(
                                  obscureText: _obscureText,
                                  validator: (value) {
                                    if (value != _password.text) {
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
                                          () => _obscureText = !_obscureText),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: RaisedButton(
                                  child: Text(
                                    'Register',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.lightBlue,
                                  onPressed: (!_isButtonDisabled)
                                      ? () {
                                          if (_formKey.currentState
                                              .validate()) {
                                            senddata(
                                                _username.text,
                                                _fullname.text,
                                                _email.text,
                                                _password.text);
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
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  senddata(uname, fname, email, pass) async {
    Dio dio = new Dio();
    FormData formData = new FormData.from({
      "username": uname,
      "fullname": fname,
      "email": email,
      "password": pass,
      "api": 'myhashtagapikey'
    });
    dio
        .post("http://hashtag2.gearhostpreview.com/mobileregister.php",
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
}
