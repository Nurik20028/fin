import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsService {
  static const _storage = FlutterSecureStorage();

  static Future<bool> loadDarkTheme() async {
    final result = await _storage.read(key: 'dark_theme');
    return result == 'true';
  }

  static Future<void> saveDarkTheme(bool value) async {
    await _storage.write(key: 'dark_theme', value: value.toString());
  }

  static Future<bool> loadScreenshotProtection() async {
    final result = await _storage.read(key: 'screen_protection');
    return result == 'true';
  }

  static Future<void> saveScreenshotProtection(bool value) async {
    await _storage.write(key: 'screen_protection', value: value.toString());
  }
}
