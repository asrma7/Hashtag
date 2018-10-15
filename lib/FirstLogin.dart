import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

File _image;

class FirstLogin extends StatefulWidget {
  final Function changepage, removepage;
  FirstLogin(this.changepage, this.removepage);
  @override
  State<StatefulWidget> createState() {
    return _FirstLoginState();
  }
}

class _FirstLoginState extends State<FirstLogin> {
  Dio dio = new Dio();
  bool dp = true;
  final focus = FocusNode();
  final _bio = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future _getImage() async {
    var images = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (images != null) {
      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(images.path);
      File compressedFile = await FlutterNativeImage.compressImage(images.path,
          quality: 80,
          targetHeight: 300,
          targetWidth: (properties.height * 300 / properties.height).round());
      setState(() {
        _image = compressedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dp) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Display Picture'),
        ),
        body: Builder(
          builder: (context) {
            return Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        width: 150.0,
                        height: 150.0,
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: (_image == null)
                                ? AssetImage('assets/placeholder.png')
                                : FileImage(_image),
                          ),
                        ),
                      ),
                      onTap: _getImage,
                    ),
                    FlatButton(
                      color: Colors.blueGrey,
                      child: Text(
                        'Use',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (_image != null) {
                          Directory tempDir =
                              await getApplicationDocumentsDirectory();
                          String tempPath = tempDir.path;
                          var cj = new PersistCookieJar(tempPath);
                          dio.cookieJar = cj;
                          dio
                              .post(
                            'http://hashtag2.gearhostpreview.com/dp.php',
                            data: FormData.from(
                              {
                                "api": 'myhashtagapikey',
                                "file": UploadFileInfo(
                                  _image,
                                  basename(_image.path),
                                )
                              },
                            ),
                            options: Options(responseType: ResponseType.PLAIN),
                          )
                              .then((val) {
                            setState(() {
                              dp = false;
                            });
                          }).catchError((err) {
                            print('err:' + err.toString());
                          });
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Please choose your Display Picture'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                    )
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile Bio'),
        ),
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _bio,
                      focusNode: focus,
                      validator: (value) {
                        if (value.length < 15 || value.length > 100) {
                          return 'Bio must be of 15-100 characters';
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black12,
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black),
                        labelText: 'Bio',
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  color: Colors.blueGrey,
                  child: Text(
                    'Proceed',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      dio
                          .post(
                        'http://hashtag2.gearhostpreview.com/status.php',
                        data: FormData.from(
                          {
                            "api": 'myhashtagapikey',
                            'status': _bio.text,
                          },
                        ),
                        options: Options(responseType: ResponseType.PLAIN),
                      )
                          .then((val) {
                        widget.changepage(1);
                      }).catchError((err) {
                        print('error occured' + err.toString());
                      });
                    }
                  },
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
