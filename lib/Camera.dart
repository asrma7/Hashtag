import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

File _image;

class CameraShow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CameraShowState();
  }
}

class _CameraShowState extends State<CameraShow> {
  final focus = FocusNode();
  final focustag = FocusNode();
  final _caption = TextEditingController();
  final _tags = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> tag = [];
  Future _getImage() async {
    var images = await ImagePicker.pickImage(source: ImageSource.camera);
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(images.path);
    File compressedFile = await FlutterNativeImage.compressImage(images.path,
        targetHeight: 600,
        targetWidth: (properties.width * 600 / properties.width).round());
    setState(() {
      _image = compressedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widget = [];
    for (int i = 0; i < tag.length; i++) {
      widget.add(
        new Chip(
          label: Text(tag[i]),
          onDeleted: () {
            setState(() {
              tag.removeAt(i);
            });
          },
        ),
      );
    }
    if (_image != null) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top:50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('This Tab is not yet ready, use device camera for now'),
                RaisedButton(
                  onPressed: _getImage,
                  child: Text(
                    'Open Device Camera',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.deepPurple,
                ),
                Image.file(
                  _image,
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 10.0,
                    left: 10.0,
                    right: 10.0,
                    bottom: 10.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _caption,
                      focusNode: focus,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Caption can\'t be empty';
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black12,
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black),
                        labelText: 'Caption',
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                ),
                Wrap(
                  children: widget,
                ),
                TextField(
                  focusNode: focustag,
                  controller: _tags,
                  onChanged: (val) {
                    if (val.contains(' ')) {
                      setState(() {
                        tag.add(val);
                        _tags.clear();
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black12,
                    border: InputBorder.none,
                    hintText: "Tags",
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                ),
                FlatButton(
                  child: Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                  onPressed: () async {
                    String tags = "";
                    for (int i = 0; i < tag.length; i++) {
                      tags = tags + "," + tag[i];
                    }
                    focus.unfocus();
                    if (_formKey.currentState.validate() && _image != null) {
                      _caption.clear();
                      Dio dio = new Dio();
                      Directory tempDir =
                          await getApplicationDocumentsDirectory();
                      String tempPath = tempDir.path;
                      var cj = new PersistCookieJar(tempPath);
                      dio.cookieJar = cj;
                      FormData formdata = new FormData.from({
                        "caption": _caption.text,
                        "tags": tags,
                        "api": "myhashtagapikey",
                        "pimg":
                            new UploadFileInfo(_image, basename(_image.path)),
                      });
                      dio
                          .post(
                              'http://hashtag2.gearhostpreview.com/submit.php',
                              data: formdata,
                              options: Options(
                                  method: 'POST',
                                  responseType:
                                      ResponseType.PLAIN // or ResponseType.JSON
                                  ))
                          .then((response) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Post Added successfully'),
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
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('This Tab is not yet ready, use device camera for now'),
              RaisedButton(
                onPressed: _getImage,
                child: Text('Open Device Camera'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
