import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hashtag/Camera.dart';
import 'package:hashtag/DirectMessages.dart';
import './Post_Manager.dart';
import 'dart:async';
import './BottomBar.dart';

class Home extends StatelessWidget {
  final Function changepage, removepage;
  Home(this.changepage, this.removepage);
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        removepage();
        return new Future(() => false);
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: GestureDetector(
            onTap: () {
              _scrollController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 10.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CameraShow()));
                          },
                          child: Icon(
                            FontAwesomeIcons.camera,
                            size: 30.0,
                          ),
                        ),
                      ),
                      Text(
                        'Hashtag',
                        style: TextStyle(
                          fontFamily: 'Billabong',
                          fontSize: 30.0,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DirectMessages(),
                        ),
                      );
                    },
                    child: Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        gradient: new RadialGradient(
                          center: const Alignment(0.0, 0.0),
                          radius: 0.5,
                          colors: [
                            const Color(0xFF1A000D),
                            const Color(0xFFFFCCE6),
                          ],
                          stops: [0.2, 1.0],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FontAwesomeIcons.solidPaperPlane,
                        color: Color(0xddffffff),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: PostManager(_scrollController),
        bottomNavigationBar: BottomBar(changepage),
      ),
    );
  }
}
