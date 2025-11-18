package com.example.flutter_idle_detector

import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class FlutterIdleDetectorPlugin: FlutterPlugin, ActivityAware {

    private lateinit var channel: MethodChannel
    private var lastInteraction = System.currentTimeMillis()
    private var timeout = 120000L
    private val handler = Handler(Looper.getMainLooper())
    private var activityBinding: ActivityPluginBinding? = null
    private val runnable = object : Runnable {
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
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.activity.window.decorView.setOnTouchListener { _, event ->
            if (event.action == MotionEvent.ACTION_DOWN) {
                lastInteraction = System.currentTimeMillis()
            }
            false
        }
        handler.post(runnable)
    }

    override fun onDetachedFromActivity() {
        handler.removeCallbacks(runnable)
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
}
