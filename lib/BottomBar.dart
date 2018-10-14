import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import './AddPost.dart';

class BottomBar extends StatelessWidget {
  final Function changepage;
  BottomBar(this.changepage);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 3.0,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            splashColor: Colors.transparent,
            onPressed: () {
              changepage(1);
            },
            icon: Icon(Icons.home, size: 30.0),
          ),
          IconButton(
            splashColor: Colors.transparent,
            onPressed: () {
              changepage(2);
            },
            icon: Icon(Icons.search, size: 30.0),
          ),
          IconButton(
            splashColor: Colors.transparent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPost()),
              );
            },
            icon: Icon(FontAwesomeIcons.plusSquare),
          ),
          IconButton(
            splashColor: Colors.transparent,
            onPressed: () {
              changepage(4);
            },
            icon: Icon(FontAwesomeIcons.heart),
          ),
          IconButton(
            splashColor: Colors.transparent,
            onPressed: () {
              changepage(5);
            },
            icon: Icon(FontAwesomeIcons.user),
          ),
        ],
      ),
    );
  }
}
