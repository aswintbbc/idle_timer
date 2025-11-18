import Flutter
import UIKit

public class FlutterIdleDetectorPlugin: NSObject, FlutterPlugin {

    static var channel: FlutterMethodChannel?
    static var lastTouch: TimeInterval = Date().timeIntervalSince1970
    static var timeout: TimeInterval = 120 // seconds
    static var timerStarted = false

    public static func register(with registrar: FlutterPluginRegistrar) {

        lastTouch = Date().timeIntervalSince1970

        channel = FlutterMethodChannel(
            name: "flutter_idle_detector",
            binaryMessenger: registrar.messenger()
        )

        let instance = FlutterIdleDetectorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)

        startIdleTimerIfNeeded()
        swizzleEvents()
    }

    public func handle(_ call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {

        case "setTimeout":
            if let ms = call.arguments as? Int {
                FlutterIdleDetectorPlugin.timeout = TimeInterval(Double(ms) / 1000.0)
                FlutterIdleDetectorPlugin.lastTouch = Date().timeIntervalSince1970
            }
            result(nil)

        case "reset":
            FlutterIdleDetectorPlugin.lastTouch = Date().timeIntervalSince1970
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // -----------------------------------------------------
    //  Global Timer Loop
    // -----------------------------------------------------
    private static func startIdleTimerIfNeeded() {
        if timerStarted { return }
        timerStarted = true

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince1970 - lastTouch
            if elapsed >= timeout {
                channel?.invokeMethod("idle", arguments: nil)
            }
        }
    }

    // -----------------------------------------------------
    //  Touch Swizzling
    // -----------------------------------------------------
    private static func swizzleEvents() {
        guard
            let original = class_getInstanceMethod(UIApplication.self,
                #selector(UIApplication.sendEvent(_:))),
            let swizzled = class_getInstanceMethod(UIApplication.self,
                #selector(UIApplication.swizzled_sendEvent(_:)))
        else { return }

        method_exchangeImplementations(original, swizzled)
    }
}

extension UIApplication {

    @objc func swizzled_sendEvent(_ event: UIEvent) {
        if let touch = event.allTouches?.first,
           touch.phase == .began || touch.phase == .moved || touch.phase == .ended {
            FlutterIdleDetectorPlugin.lastTouch = Date().timeIntervalSince1970
        }

        self.swizzled_sendEvent(event)
    }
}
