import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PrivacyService {
  static const MethodChannel _channel = MethodChannel('privacy_channel');
  static Future<void> setScreenshotProtection(bool enabled) async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('setScreenshotProtection', {
        'enabled': enabled,
      });
    } catch (e) {
      debugPrint('Screenshot protection error: $e');
    }
  }
  static Future<bool> loadScreenshotProtection() async {
    final result = await FlutterSecureStorage().read(key: "screen_protection");
    return result == "true";
  }
  static Future<void> saveScreenshotProtection(bool value) async {
    await const FlutterSecureStorage().write(
        key: "screen_protection",
        value: value.toString(),
    );
  }
}
