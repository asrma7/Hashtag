import 'package:hashtag/Posts.dart';

class UserProfileo {
  final String username, fullname, dp, status;
  final int followers, followings, postcount;
  final int following;
  final List<Posts> post;
  UserProfileo({
    this.username,
    this.fullname,
    this.dp,
    this.status,
    this.followers,
    this.followings,
    this.postcount,
    this.post,
    this.following,
  });
  factory UserProfileo.fromJson(Map<String, dynamic> json) {
    List<Posts> posts = [];
    for (int i = 0; i < json['posts'].length; i++) {
      Posts post = Posts.fromJson(json['posts'][i]);
      posts.add(post);
    }
    return UserProfileo(
      username: json['username'] as String,
      fullname: json['fullname'] as String,
      dp: json['dp'] as String,
      status: json['status'] as String,
      followers: json['followers'] as int,
      followings: json['followings'] as int,
      postcount: json['postcount'] as int,
      post: posts,
      following: json['following'] as int,
    );
  }
}
