import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const _rememberMeKey = 'remember_me';

  Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  Future<bool> loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }
}