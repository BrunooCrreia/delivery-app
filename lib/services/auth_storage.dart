import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  AuthStorage({SharedPreferences? preferences}) : _preferences = preferences;

  SharedPreferences? _preferences;

  static const String _tokenKey = 'auth_token';
  static const String _userNameKey = 'user_name';
  static const String _userPhotoKey = 'user_photo';

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

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    final parts = token.split('.');
    return parts.length >= 2;
  }

  Future<void> saveUserData({required String nome, String? photoUrl}) async {
    final prefs = await _getPrefs();
    await prefs.setString(_userNameKey, nome);
    if (photoUrl != null && photoUrl.isNotEmpty) {
      await prefs.setString(_userPhotoKey, photoUrl);
    }
  }

  Future<String?> getUserName() async {
    final prefs = await _getPrefs();
    return prefs.getString(_userNameKey);
  }

  Future<String?> getUserPhoto() async {
    final prefs = await _getPrefs();
    return prefs.getString(_userPhotoKey);
  }

  Future<void> logout() async {
    final prefs = await _getPrefs();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhotoKey);
  }
}
