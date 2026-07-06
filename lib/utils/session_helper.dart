import 'package:shared_preferences/shared_preferences.dart';

class SessionHelper {
  static Future<void> saveUser(String userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_id", userId);
    await prefs.setString("username", username);
  }

  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "user_id": prefs.getString("user_id"),
      "username": prefs.getString("username"),
    };
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_id") != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user_id");
    await prefs.remove("username");
  }
}
