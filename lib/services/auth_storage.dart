import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  AuthStorage();

  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_tokenKey);
    return token != null && token.isNotEmpty ? token : null;
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
  }
}
