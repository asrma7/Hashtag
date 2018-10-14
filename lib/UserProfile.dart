import 'package:hashtag/Posts.dart';

class UserProfile {
  final String username, fullname, dp, status;
  final int followers, followings, postcount;
  final List<Posts> post;
  UserProfile({
    this.username,
    this.fullname,
    this.dp,
    this.status,
    this.followers,
    this.followings,
    this.postcount,
    this.post,
  });
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    List<Posts> posts = [];
    for (int i = 0; i < json['posts'].length; i++) {
      Posts post = Posts.fromJson(json['posts'][i]);
      posts.add(post);
    }
    return UserProfile(
      username: json['username'] as String,
      fullname: json['fullname'] as String,
      dp: json['dp'] as String,
      status: json['status'] as String,
      followers: json['followers'] as int,
      followings: json['followings'] as int,
      postcount: json['postcount'] as int,
      post: posts,
    );
  }
}
