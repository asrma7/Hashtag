class Notificationo {
  final String user, notify, dp, type, id, posticon;
  Notificationo({
    this.user,
    this.notify,
    this.dp,
    this.type,
    this.id,
    this.posticon,
  });
  factory Notificationo.fromJson(Map<String, dynamic> json) {
    return Notificationo(
      user: json['user'] as String,
      notify: json['notify'] as String,
      dp: json['dp'] as String,
      type: json['type'] as String,
      id: json['id'] as String,
      posticon: json['posticon'] as String,
    );
  }
}
