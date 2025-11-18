import 'package:flutter/services.dart';

class FlutterIdleDetector {
  static const MethodChannel _channel =
      MethodChannel('flutter_idle_detector');

  static void initialize({required void Function() onIdle}) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "idle") onIdle();
    });
  }

  static Future<void> reset() async {
    await _channel.invokeMethod("reset");
  }
}
