package com.example.flutter_idle_detector

import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.MotionEvent
import android.view.Window
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class FlutterIdleDetectorPlugin : FlutterPlugin, ActivityAware {

    private lateinit var channel: MethodChannel
    private var lastInteraction = System.currentTimeMillis()
    private var timeout: Long = 120_000L // default 2 min
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

        installGlobalTouchListener(binding.activity.window)
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

    // -----------------------------------------------------
    //  GLOBAL TOUCH HOOK (Works inside ALL SDK Views!!)
    // -----------------------------------------------------
    private fun installGlobalTouchListener(window: Window) {
        val originalCallback = window.callback

        window.callback = object : Window.Callback by originalCallback {
            override fun dispatchTouchEvent(event: MotionEvent): Boolean {
                if (event.action == MotionEvent.ACTION_DOWN ||
                    event.action == MotionEvent.ACTION_MOVE ||
                    event.action == MotionEvent.ACTION_UP
                ) {
                    resetTimer()
                }
                return originalCallback.dispatchTouchEvent(event)
            }
        }
    }

    // -----------------------------------------------------
    // Helpers
    // -----------------------------------------------------
    private fun resetTimer() {
        lastInteraction = System.currentTimeMillis()
        Log.d("IdlePlugin", "Timer Reset")
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
