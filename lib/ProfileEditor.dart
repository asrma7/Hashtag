import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:hashtag/userdata.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ProfileEditor extends StatefulWidget {
  final UserData userData;
  ProfileEditor(this.userData);
  @override
  State<StatefulWidget> createState() {
    return _ProfileEditorState();
  }
}

class _ProfileEditorState extends State<ProfileEditor> {
  @override
  void dispose() {
    focus.dispose();
    focus2.dispose();
    focus3.dispose();
    super.dispose();
  }

  Future _getImage() async {
    var images = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (images != null) {
      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(images.path);
      File compressedFile = await FlutterNativeImage.compressImage(
        images.path,
        quality: 100,
        targetHeight: 600,
        targetWidth: (properties.width * 600 / properties.height).round(),
      );
      setState(() {
        _image = compressedFile;
      });
    }
  }

  File _image;
  final _formKey = GlobalKey<FormState>();
  final focus = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();
  final _fullname = TextEditingController();
  final _email = TextEditingController();
  final _bio = TextEditingController();
  int gender;
  @override
  Widget build(BuildContext context) {
    focus.addListener(() {
      if (focus.hasFocus)
        _fullname.selection = new TextSelection(
            baseOffset: 0, extentOffset: _fullname.text.length);
    });
    focus2.addListener(() {
      if (focus2.hasFocus)
        _email.selection =
            new TextSelection(baseOffset: 0, extentOffset: _email.text.length);
    });
    focus3.addListener(() {
      if (focus3.hasFocus)
        _bio.selection =
            new TextSelection(baseOffset: 0, extentOffset: _bio.text.length);
    });
    _fullname.text = _fullname.text.length == 0
        ? _fullname.text = widget.userData.fullname
        : _fullname.text;
    _email.text = _email.text.length == 0
        ? _email.text = widget.userData.email
        : _email.text;
    _bio.text =
        _bio.text.length == 0 ? _bio.text = widget.userData.status : _bio.text;

    gender = gender == null ? gender = widget.userData.gender : gender;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: Column(children: <Widget>[
            GestureDetector(
              child: Container(
                width: 100.0,
                height: 100.0,
                margin: EdgeInsets.only(
                  right: 10.0,
                ),
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: (_image == null)
                        ? NetworkImage(
                            widget.userData.dp,
                          )
                        : FileImage(_image),
                  ),
                ),
              ),
              onTap: _getImage,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: _fullname,
                      focusNode: focus,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'FullName can\'t be empty';
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black12,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: _email,
                      focusNode: focus2,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Email can\'t be empty';
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black12,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: _bio,
                      focusNode: focus3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value.length < 15 || value.length > 100) {
                          return 'Bio must be of 15-100 characters';
                        }
                      },
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black12,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Radio(
                          value: 0,
                          groupValue: gender,
                          onChanged: (i) {
                            setState(() {
                              gender = i;
                            });
                          },
                        ),
                        new Text(
                          'Male',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                        new Radio(
                          value: 1,
                          groupValue: gender,
                          onChanged: (i) {
                            setState(() {
                              gender = i;
                            });
                          },
                        ),
                        new Text(
                          'Female',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                        new Radio(
                          value: 2,
                          groupValue: gender,
                          onChanged: (i) {
                            setState(() {
                              gender = i;
                            });
                          },
                        ),
                        new Text(
                          'Not Specified',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                      ]),
                  FlatButton(
                    child: Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.blueAccent,
                      ),
                    ),
                    onPressed: () async {
                      focus.unfocus();
                      focus2.unfocus();
                      focus3.unfocus();
                      if (_formKey.currentState.validate()) {
                        String gen, fullname, email, bio;
                        fullname = (_fullname.text.length > 0)
                            ? _fullname.text
                            : widget.userData.fullname;
                        email = (_email.text.length > 0)
                            ? _email.text
                            : widget.userData.email;
                        bio = (_bio.text.length > 0)
                            ? _bio.text
                            : widget.userData.status;
                        switch (gender) {
                          case 0:
                            gen = "male";
                            break;
                          case 1:
                            gen = "female";
                            break;
                          case 2:
                            gen = "";
                            break;
                        }
                        Dio dio = new Dio();
                        Directory tempDir =
                            await getApplicationDocumentsDirectory();
                        String tempPath = tempDir.path;
                        var cj = new PersistCookieJar(tempPath);
                        dio.cookieJar = cj;
                        FormData formdata;
                        if (_image != null) {
                          formdata = new FormData.from({
                            "fullname": fullname,
                            "email": email,
                            "status": bio,
                            "gender": gen,
                            "api": "myhashtagapikey",
                            "file": new UploadFileInfo(
                                _image, basename(_image.path)),
                          });
                        } else {
                          formdata = new FormData.from({
                            "fullname": fullname,
                            "email": email,
                            "status": bio,
                            "gender": gen,
                            "api": "myhashtagapikey",
                          });
                        }
                        dio
                            .post(
                                'http://hashtag2.gearhostpreview.com/change.php',
                                data: formdata,
                                options: Options(
                                    method: 'POST',
                                    responseType: ResponseType
                                        .PLAIN // or ResponseType.JSON
                                    ))
                            .then((response) {
                          print(response);
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Profile edited successfully'),
                            backgroundColor: Colors.green,
                          ));
                          print('success');
                          Future.delayed(Duration(seconds: 1), () {
                            Navigator.pop(context);
                          });
                        }).catchError((error) => print(error));
                      }
                    },
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
