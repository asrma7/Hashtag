import 'package:hashtag/Posts.dart';

class UserProfileo {
  final String id, username, fullname, dp, status;
  final int followers, followings, postcount;
  int following;
  bool fan;
  final List<Posts> post;
  UserProfileo({
    this.id,
    this.username,
    this.fullname,
    this.dp,
    this.status,
    this.followers,
    this.followings,
    this.postcount,
    this.post,
    this.following,
    this.fan,
  });
  factory UserProfileo.fromJson(Map<String, dynamic> json) {
    List<Posts> posts = [];
    for (int i = 0; i < json['posts'].length; i++) {
      Posts post = Posts.fromJson(json['posts'][i]);
      posts.add(post);
    }
    return UserProfileo(
      id: json['id'] as String,
      username: json['username'] as String,
      fullname: json['fullname'] as String,
      dp: json['dp'] as String,
      status: json['status'] as String,
      followers: json['followers'] as int,
      followings: json['followings'] as int,
      postcount: json['postcount'] as int,
      post: posts,
      following: json['following'] as int,
      fan: json['fan'] as bool,
    );
  }
}
