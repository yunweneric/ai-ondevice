import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _sharedPreferences;

  LocalStorageService(this._sharedPreferences);

  Future<void> setString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _sharedPreferences.getString(key);
  }

  Future<void> remove(String key) async {
    await _sharedPreferences.remove(key);
  }

  Future<bool> hasInit() async {
    return _sharedPreferences.getBool('init') ?? false;
  }

  Future<void> saveInit() async {
    await _sharedPreferences.setBool('init', true);
  }

  Future<void> clear() async {
    await _sharedPreferences.clear();
  }
}
