class Posts {
  final String id, user, usericon, postimage, tags, caption, time;
  bool like;
  int likecount;
  Posts({
    this.id,
    this.user,
    this.usericon,
    this.tags,
    this.postimage,
    this.caption,
    this.like,
    this.likecount,
    this.time,
  });
  factory Posts.fromJson(Map<String, dynamic> json) {
    return Posts(
      id: json['id'] as String,
      user: json['uname'] as String,
      usericon: json['dp'] as String,
      postimage: json['pp'] as String,
      tags: json['tags'] as String,
      caption: json['caption'] as String,
      time: json['time'] as String,
      like: json['liked'] as bool,
      likecount: json['hashes'] as int,
    );
  }
}
