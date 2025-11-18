import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class IdleTimer {
  static const MethodChannel _channel = MethodChannel('flutter_idle_detector');
  static ValueNotifier<bool> isIdle = ValueNotifier(false);
  static void initialize({
    required void Function() onIdle,
    Duration timeout = const Duration(minutes: 2),
  }) {
    _channel.invokeMethod("setTimeout", timeout.inMilliseconds);

    _channel.setMethodCallHandler((call) async {
      if (call.method == "idle" && !isIdle.value) {
        isIdle.value = true;
        onIdle();
      }
    });
  }

  static Future<void> start() async {
    isIdle.value = false;
    await _channel.invokeMethod("start");
  }

  static Future<void> stop() async {
    await _channel.invokeMethod("stop");
  }

  static Future<void> reset() async {
    isIdle.value = false;
    await _channel.invokeMethod("reset");
  }
}
