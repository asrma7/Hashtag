class Users {
  final String username, fullname, usericon;
  Users({
    this.username,
    this.fullname,
    this.usericon,
  });
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      username: json['username'] as String,
      fullname: json['fullname'] as String,
      usericon: json['dp'] as String,
    );
  }
}
