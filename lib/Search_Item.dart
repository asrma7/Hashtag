import 'package:flutter/material.dart';
import 'package:hashtag/Users.dart';
import 'package:hashtag/profileo.dart';

class SearchItem extends StatelessWidget {
  final Function changepage;
  final Users users;
  SearchItem(this.users, this.changepage);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.only(top: 20.0, left: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profileo(users.username),
            ),
          );
        },
        child: Row(
          children: <Widget>[
            Container(
              width: 60.0,
              height: 60.0,
              margin: EdgeInsets.only(
                right: 10.0,
              ),
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage(users.usericon),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  users.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  users.fullname,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
