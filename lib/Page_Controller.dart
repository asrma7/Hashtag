import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hashtag/Login.dart';
import './Searcher.dart';
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
  int index = 0;
  String userids = "";
  @override
  Widget build(BuildContext context) {
    void changepage(int i) {
      if (i != index) {
        if (widget.pagehistory.length >= 3) widget.pagehistory.removeAt(0);
        widget.pagehistory.remove(i);
        widget.pagehistory.add(i);
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
          return Searcher(changepage, removepage);
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
          return Login(changepage, removepage);
        }
    }
  }
}
