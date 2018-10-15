import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hashtag/BottomBar.dart';
import 'package:hashtag/Searcher.dart';

class Explore extends StatelessWidget {
  final Function changepage, removepage;
  Explore(this.changepage, this.removepage);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        removepage();
        return new Future(() => false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(CupertinoIcons.search),
                    Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  child: Icon(FontAwesomeIcons.qrcode),
                  onTap: () {},
                )
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Searcher(changepage, removepage),
                ),
              );
            },
          ),
        ),
        body: Container(
          child: Text('Still to be developed'),
        ),
        bottomNavigationBar: BottomBar(changepage),
      ),
    );
  }
}
