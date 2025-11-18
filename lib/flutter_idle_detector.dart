import 'package:flutter/services.dart';

class IdleTimer {
  static const MethodChannel _channel = MethodChannel('flutter_idle_detector');
  static bool isIdle = false;
  static void initialize({
    required void Function() onIdle,
    Duration timeout = const Duration(minutes: 2),
  }) {
    _channel.invokeMethod("setTimeout", timeout.inMilliseconds);

    _channel.setMethodCallHandler((call) async {
      if (call.method == "idle" && !isIdle) {
        isIdle = true;
        onIdle();
      }
    });
  }

  static Future<void> reset() async {
    isIdle = false;
    await _channel.invokeMethod("reset");
  }
}
