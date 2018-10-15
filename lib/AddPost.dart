import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

File _image;

class AddPost extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddPostState();
  }
}

class _AddPostState extends State<AddPost> {
  @override
  void dispose() {
    _image = null;
    super.dispose();
  }

  List<String> tag = [];
  final focus = FocusNode();
  final focustag = FocusNode();
  final _caption = TextEditingController();
  final _tags = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool enabled = true;
  Future _getImage() async {
    var images = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (images != null) {
      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(images.path);
      File compressedFile = await FlutterNativeImage.compressImage(
        images.path,
        targetHeight: 600,
        targetWidth: (properties.width * 600 / properties.height).round(),
      );
      setState(() {
        _image = compressedFile;
      });
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
      ),
      body: Builder(builder: (context) {
        return SingleChildScrollView(
          child: Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      height: 150.0,
                      width: 150.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: (_image == null)
                              ? AssetImage('assets/placeholder.png')
                              : FileImage(_image),
                        ),
                      ),
                    ),
                    onTap: _getImage,
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
                    onPressed: enabled
                        ? () async {
                            String tags = "";
                            for (int i = 0; i < tag.length; i++) {
                              tags = tags + "#" + tag[i];
                            }
                            focus.unfocus();
                            if (_formKey.currentState.validate() &&
                                _image != null) {
                              setState(() {
                                enabled = false;
                              });
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
                                "pimg": new UploadFileInfo(
                                    _image, basename(_image.path)),
                              });
                              dio
                                  .post(
                                      'http://hashtag2.gearhostpreview.com/submit.php',
                                      data: formdata,
                                      options: Options(
                                          method: 'POST',
                                          responseType: ResponseType
                                              .PLAIN // or ResponseType.JSON
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
                            } else if (_image == null) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Please select an image'),
                                backgroundColor: Colors.red,
                              ));
                            }
                          }
                        : null,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            margin: EdgeInsets.only(top: 20.0),
          ),
        );
      }),
    );
  }
}
