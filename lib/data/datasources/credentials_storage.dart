import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../core/models/user_credentials.dart';

class CredentialsStorage {
  static const _nameKey = 'user_name';
  static const _passwordKey = 'user_password';
  static const _userIdKey = 'user_id';
  static const _baseUrlKey = 'server_base_url';

  Future<UserCredentials> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return UserCredentials(
      name: prefs.getString(_nameKey) ?? '',
      password: prefs.getString(_passwordKey) ?? '',
      userId: prefs.getString(_userIdKey),
    );
  }

  Future<void> saveCredentials(UserCredentials credentials) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, credentials.name);
    await prefs.setString(_passwordKey, credentials.password);
    if (credentials.userId != null) {
      await prefs.setString(_userIdKey, credentials.userId!);
    }
  }

  Future<String> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey) ?? ApiConstants.defaultBaseUrl;
  }

  Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
  }
}
