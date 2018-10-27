import 'package:meta/meta.dart';

class Messages {
  final String text, author, type;
  final int time;
  Messages({this.time, this.text, this.author, @required this.type});
  factory Messages.fromJson(Map<String, dynamic> json, String types) {
    return Messages(
      time: json['time'],
      text: json['text'],
      author: json['author'],
      type: types,
    );
  }
}
