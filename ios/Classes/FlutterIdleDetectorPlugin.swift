// ios/Classes/FlutterIdleDetectorPlugin.swift
import Flutter
import UIKit

public class FlutterIdleDetectorPlugin: NSObject, FlutterPlugin {

    static var channel: FlutterMethodChannel?
    static var lastTouch: TimeInterval = Date().timeIntervalSince1970
    static var timeout: TimeInterval = 120
    static var monitoring = false
    static var timerStarted = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "flutter_idle_detector", binaryMessenger: registrar.messenger())
        let instance = FlutterIdleDetectorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
        startTimerLoop()
        swizzleTouch()
        print("IdlePlugin: registered")
    }

    public func handle(_ call: FlutterMethodCall, result: FlutterResult) {
        print("IdlePlugin: method \(call.method) args: \(String(describing: call.arguments))")
        switch call.method {
        case "setTimeout":
            if let ms = call.arguments as? Int {
                FlutterIdleDetectorPlugin.timeout = TimeInterval(ms) / 1000.0
            } else if let ms = call.arguments as? Double {
                FlutterIdleDetectorPlugin.timeout = TimeInterval(ms / 1000.0)
            }
            FlutterIdleDetectorPlugin.lastTouch = Date().timeIntervalSince1970
            print("IdlePlugin: timeout set to \(FlutterIdleDetectorPlugin.timeout) seconds")
            result(nil)
        case "start":
            FlutterIdleDetectorPlugin.monitoring = true
            FlutterIdleDetectorPlugin.lastTouch = Date().timeIntervalSince1970
            print("IdlePlugin: monitoring STARTED")
            result(nil)
        case "stop":
            FlutterIdleDetectorPlugin.monitoring = false
            print("IdlePlugin: monitoring STOPPED")
            result(nil)
        case "reset":
            FlutterIdleDetectorPlugin.lastTouch = Date().timeIntervalSince1970
            print("IdlePlugin: RESET")
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private static func startTimerLoop() {
        if timerStarted { return }
        timerStarted = true
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !monitoring { return }
            let elapsed = Date().timeIntervalSince1970 - lastTouch
            if elapsed >= timeout {
                print("IdlePlugin: idle detected")
                channel?.invokeMethod("idle", arguments: nil)
                lastTouch = Date().timeIntervalSince1970
            }
        }
    }

    private static func swizzleTouch() {
        guard
            let original = class_getInstanceMethod(UIApplication.self, #selector(UIApplication.sendEvent(_:))),
            let swizzled = class_getInstanceMethod(UIApplication.self, #selector(UIApplication.swizzled_sendEvent(_:)))
        else { return }
        method_exchangeImplementations(original, swizzled)
        print("IdlePlugin: swizzled sendEvent")
    }
}

extension UIApplication {
    @objc func swizzled_sendEvent(_ event: UIEvent) {
        if FlutterIdleDetectorPlugin.monitoring,
           let touch = event.allTouches?.first,
           touch.phase == .began || touch.phase == .moved || touch.phase == .ended {
            FlutterIdleDetectorPlugin.lastTouch = Date().timeIntervalSince1970
            // print to Xcode console
            print("IdlePlugin: touch -> reset lastTouch")
        }
        self.swizzled_sendEvent(event)
    }
}
