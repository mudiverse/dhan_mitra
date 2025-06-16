class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  UserSession._internal();

  String? userId;

  void setUserId(String id) {
    userId = id;
  }

  String get getUserId {
    if (userId == null) {
      throw Exception("User ID not set");
    }
    return userId!;
  }
}
