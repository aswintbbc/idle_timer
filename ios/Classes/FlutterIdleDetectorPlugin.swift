import Flutter
import UIKit

public class FlutterIdleDetectorPlugin: NSObject, FlutterPlugin {

    // MARK: - State
    static var channel: FlutterMethodChannel?
    static var lastTouch: TimeInterval = Date().timeIntervalSince1970
    static var timeout: TimeInterval = 120 // seconds
    static var timerStarted = false

    // MARK: - Plugin Registration
    public static func register(with registrar: FlutterPluginRegistrar) {

        // Reset timer on plugin attach (hot restart, app resume, etc.)
        lastTouch = Date().timeIntervalSince1970

        channel = FlutterMethodChannel(
            name: "flutter_idle_detector",
            binaryMessenger: registrar.messenger()
        )

        let instance = FlutterIdleDetectorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)

        startIdleTimerIfNeeded()
        swizzleTouchEvents()
    }

    // MARK: - Handle Calls From Flutter
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

    // MARK: - Timer Loop
    private static func startIdleTimerIfNeeded() {
        if timerStarted { return }
        timerStarted = true

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let now = Date().timeIntervalSince1970
            let elapsed = now - lastTouch

            if elapsed >= timeout {
                channel?.invokeMethod("idle", arguments: nil)
            }
        }
    }

    // MARK: - Touch Event Swizzling
    private static func swizzleTouchEvents() {

        guard
            let originalMethod = class_getInstanceMethod(
                UIApplication.self,
                #selector(UIApplication.sendEvent(_:))
            ),
            let swizzledMethod = class_getInstanceMethod(
                UIApplication.self,
                #selector(UIApplication.swizzled_sendEvent(_:))
            )
        else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIApplication {

    // Intercepts all touches, including WKWebView
    @objc func swizzled_sendEvent(_ event: UIEvent) {
        FlutterIdleDetectorPlugin.lastTouch = Date().timeIntervalSince1970
        self.swizzled_sendEvent(event)
    }
}
