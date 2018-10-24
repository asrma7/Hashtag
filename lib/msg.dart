class Messages {
  final String text, author;
  final int time;
  Messages({
    this.time,
    this.text,
    this.author,
  });
  factory Messages.fromJson(Map<String, dynamic> json) {
    return Messages(
        time: json['time'], text: json['text'], author: json['author']);
  }
}