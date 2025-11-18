import Flutter
import UIKit

public class FlutterIdleDetectorPlugin: NSObject, FlutterPlugin {

    static var channel: FlutterMethodChannel?
    static var lastTouch = Date().timeIntervalSince1970
    static var timeout: TimeInterval = 120 // default seconds

    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(
            name: "flutter_idle_detector",
            binaryMessenger: registrar.messenger()
        )

        let instance = FlutterIdleDetectorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)

        startTimer()
        swizzleTouchEvents()
    }

    // MARK: - Timer
    public static func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let now = Date().timeIntervalSince1970
            if now - lastTouch >= timeout {
                channel?.invokeMethod("idle", arguments: nil)
            }
        }
    }

    // MARK: - Touch capturing (works even in WKWebView)
    public static func swizzleTouchEvents() {
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

    // MARK: - Flutter method handler
    public func handle(_ call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {

        case "setTimeout":
            if let ms = call.arguments as? Int {
                FlutterIdleDetectorPlugin.timeout = TimeInterval(Double(ms) / 1000.0)
            }
            result(nil)

        case "reset":
            FlutterIdleDetectorPlugin.lastTouch = Date().timeIntervalSince1970
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - Touch override
extension UIApplication {
    @objc func swizzled_sendEvent(_ event: UIEvent) {
        FlutterIdleDetectorPlugin.lastTouch = Date().timeIntervalSince1970
        self.swizzled_sendEvent(event)
    }
}
