class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  UserSession._internal();

  String? userId;

  void setUserId(String id) {
    // Always store only the first 6 characters as the user ID
    userId = id.length >= 6 ? id.substring(0, 6) : id;
  }

  String get getUserId {
    if (userId == null) {
      throw Exception("User ID not set");
    }
    return userId!;
  }
}
