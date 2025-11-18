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
    private var timeout: Long = 120_000L // default 2 minutes
    private val handler = Handler(Looper.getMainLooper())
    private var activityBinding: ActivityPluginBinding? = null

    /// Runnable that checks idle state every 1 second
    private val idleCheckRunnable = object : Runnable {
        override fun run() {
            val now = System.currentTimeMillis()
            val elapsed = now - lastInteraction

            if (elapsed >= timeout) {
                channel.invokeMethod("idle", null)
            }

            handler.postDelayed(this, 1000)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "flutter_idle_detector")

        channel.setMethodCallHandler { call, result ->
            when (call.method) {

                "setTimeout" -> {
                    val ms = call.arguments as Int
                    timeout = ms.toLong()
                    resetTimer()
                    result.success(null)
                }

                "reset" -> {
                    resetTimer()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding

        /// Capture ALL touch events including WebView & SDK screens
        binding.activity.window.decorView.setOnTouchListener { _, event ->
            if (event.action == MotionEvent.ACTION_DOWN) {
                resetTimer()
            }
            false
        }

        /// Always restart timer loop safely
        restartIdleLoop()
    }

    override fun onDetachedFromActivity() {
        stopIdleLoop()
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        stopIdleLoop()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopIdleLoop()
    }

    // --------------------------------------------------------------
    // Helper Functions
    // --------------------------------------------------------------

    private fun resetTimer() {
        lastInteraction = System.currentTimeMillis()
    }

    private fun restartIdleLoop() {
        handler.removeCallbacks(idleCheckRunnable)
        handler.post(idleCheckRunnable)
        resetTimer()
    }

    private fun stopIdleLoop() {
        handler.removeCallbacks(idleCheckRunnable)
    }
}
