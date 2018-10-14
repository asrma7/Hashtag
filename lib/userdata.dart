class UserData {
  String fullname, dp, status, email;
  final int gender;
  UserData({
    this.fullname,
    this.dp,
    this.status,
    this.gender,
    this.email,
  });
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      fullname: json['fullname'] as String,
      dp: json['dp'] as String,
      email: json['email'] as String,
      gender: json['gender'] as int,
      status: json['status'] as String,
    );
  }
}
