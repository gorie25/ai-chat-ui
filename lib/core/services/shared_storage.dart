import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageManager {
  LocalStorageManager._();
  static final LocalStorageManager instance = LocalStorageManager._();

  Future<String?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveData(String value, {required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
