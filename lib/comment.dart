class Comment {
  final String id, user, dp, comment;
  final bool me;
  Comment({
    this.id,
    this.user,
    this.dp,
    this.comment,
    this.me,
  });
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      user: json['user'] as String,
      comment: json['comment'] as String,
      dp: json['dp'] as String,
      me: json['me'] as bool,
    );
  }
}
