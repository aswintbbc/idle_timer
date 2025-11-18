import Flutter
import UIKit

public class FlutterIdleDetectorPlugin: NSObject, FlutterPlugin {

    static var channel: FlutterMethodChannel?
    static var lastTouch = Date().timeIntervalSince1970
    static var timeout: TimeInterval = 120

    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "flutter_idle_detector",
                                       binaryMessenger: registrar.messenger())
        let instance = FlutterIdleDetectorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
        startTimer()
        swizzle()
    }

    public static func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let now = Date().timeIntervalSince1970
            if now - lastTouch >= timeout {
                channel?.invokeMethod("idle", arguments: nil)
            }
        }
    }

    public static func swizzle() {
        let original = class_getInstanceMethod(UIApplication.self, #selector(UIApplication.sendEvent(_:)))!
        let swizzled = class_getInstanceMethod(UIApplication.self, #selector(UIApplication.mySendEvent(_:)))!
        method_exchangeImplementations(original, swizzled)
    }

    public func handle(_ call: FlutterMethodCall, result: FlutterResult) {
        if call.method == "reset" {
            FlutterIdleDetectorPlugin.lastTouch = Date().timeIntervalSince1970
        }
        result(nil)
    }
}

extension UIApplication {
    @objc func mySendEvent(_ event: UIEvent) {
        FlutterIdleDetectorPlugin.lastTouch = Date().timeIntervalSince1970
        self.mySendEvent(event)
    }
}
