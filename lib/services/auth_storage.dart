import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  AuthStorage({SharedPreferences? preferences}) : _preferences = preferences;

  SharedPreferences? _preferences;

  static const String _tokenKey = 'auth_token';

  Future<SharedPreferences> _getPrefs() async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<void> saveToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await _getPrefs();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty ? token : null;
  }

  /// Checks if a token exists and is not empty
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Validates token format (basic check - must be non-empty string)
  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    // Basic JWT format check: should have 3 parts separated by dots
    final parts = token.split('.');
    return parts.length >= 2; // At least header.payload
  }

  Future<void> logout() async {
    final prefs = await _getPrefs();
    await prefs.remove(_tokenKey);
  }
}
