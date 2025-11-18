package com.example.flutter_idle_detector

import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class FlutterIdleDetectorPlugin : FlutterPlugin, ActivityAware {

    private lateinit var channel: MethodChannel
    private var lastInteraction = System.currentTimeMillis()
    private var timeout: Long = 120_000L // default = 2 minutes
    private val handler = Handler(Looper.getMainLooper())
    private var activityBinding: ActivityPluginBinding? = null

    private val idleCheckRunnable = object : Runnable {
        override fun run() {
            val now = System.currentTimeMillis()
            if (now - lastInteraction >= timeout) {
                channel.invokeMethod("idle", null)
            }
            handler.postDelayed(this, 1000)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "flutter_idle_detector")

        // Handle messages coming from Flutter
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "setTimeout" -> {
                    val ms = call.arguments as Int
                    timeout = ms.toLong()
                    result.success(null)
                }

                "reset" -> {
                    lastInteraction = System.currentTimeMillis()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding

        // Capture ALL touch events (WebView, PlatformViews, SDKs)
        binding.activity.window.decorView.setOnTouchListener { _, event ->
            if (event.action == MotionEvent.ACTION_DOWN) {
                lastInteraction = System.currentTimeMillis()
            }
            false
        }

        handler.post(idleCheckRunnable)
    }

    override fun onDetachedFromActivity() {
        handler.removeCallbacks(idleCheckRunnable)
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        handler.removeCallbacks(idleCheckRunnable)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        handler.removeCallbacks(idleCheckRunnable)
    }
}
