import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hashtag/DBHelper.dart';
import 'package:hashtag/explore.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import './Notifications.dart';
import './profile.dart';
import './Home.dart';

class PagesController extends StatefulWidget {
  final List<int> pagehistory = [1];
  PagesController();
  @override
  State<StatefulWidget> createState() {
    return _PageControllerState();
  }
}

class _PageControllerState extends State<PagesController> {
  DBHelper dbHelper = new DBHelper();
  String username;
  int index = 1;
  String userids = "";
  WebSocketChannel socketChannel;

  @override
  Widget build(BuildContext context) {
    void changepage(int i) {
      if (i != index && i != 9) {
        if (widget.pagehistory.length >= 3) widget.pagehistory.removeAt(0);
        widget.pagehistory.remove(i);
        widget.pagehistory.add(i);
        setState(() {
          index = i;
        });
      } else {
        setState(() {
          index = i;
        });
      }
    }

    bool removepage() {
      if (widget.pagehistory.length > 1) {
        setState(() {
          index = widget.pagehistory[widget.pagehistory.length - 2];
        });
        widget.pagehistory.removeLast();
        return false;
      } else {
        exit(0);
        return true;
      }
    }

    switch (index) {
      case 1:
        {
          return Home(changepage, removepage);
        }
      case 2:
        {
          return Explore(changepage, removepage);
        }
      case 4:
        {
          return Notifications(changepage, removepage);
        }
      case 5:
        {
          return Profile(changepage, removepage);
        }
      default:
        {
          return Home(changepage, removepage);
        }
    }
  }
}
