import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ScreenSecurity {
  static void enable() {
    if (kIsWeb) return;
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChannels.platform.invokeMethod("SystemChrome.setApplicationSwitcherDescription");
    } catch (e) {
      debugPrint('ScreenSecurity error: $e');
    }
  }
}