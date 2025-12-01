// android/src/main/kotlin/com/example/flutter_idle_detector/FlutterIdleDetectorPlugin.kt
package com.mindster.flutter_idle_detector

import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.MotionEvent
import android.view.Window
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterIdleDetectorPlugin : FlutterPlugin, ActivityAware {

    companion object {
        const val TAG = "IdlePlugin"
    }

    private lateinit var channel: MethodChannel
    private var lastInteraction = System.currentTimeMillis()
    private var timeout: Long = 120_000L
    private val handler = Handler(Looper.getMainLooper())
    private var activityBinding: ActivityPluginBinding? = null
    private var monitoring = false

    private val idleLoop = object : Runnable {
        override fun run() {
            try {
                if (monitoring) {
                    val now = System.currentTimeMillis()
                    if (now - lastInteraction >= timeout) {
                        Log.d(TAG, "Idle detected -> invoking flutter")
                        channel.invokeMethod("idle", null)
                        // After idle detected, reset lastInteraction to avoid repeat flooding
                        lastInteraction = System.currentTimeMillis()
                    }
                }
            } catch (t: Throwable) {
                Log.e(TAG, "Error in idleLoop: ${t.message}")
            } finally {
                handler.postDelayed(this, 1000)
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "flutter_idle_detector")
        channel.setMethodCallHandler(this::handleMethod)
        // Start the idle loop but it will only act when `monitoring` is true.
        handler.post(idleLoop)
        Log.d(TAG, "onAttachedToEngine: handler posted")
    }

    private fun handleMethod(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "MethodCall: ${call.method} args=${call.arguments}")
        when (call.method) {
            "setTimeout" -> {
                val ms = when (val a = call.arguments) {
                    is Int -> a.toLong()
                    is Long -> a
                    is Double -> (a.toLong())
                    else -> 120000L
                }
                timeout = ms
                Log.d(TAG, "Timeout set to $timeout ms")
                // reset lastInteraction when timeout set
                lastInteraction = System.currentTimeMillis()
                result.success(null)
            }
            "start" -> {
                monitoring = true
                lastInteraction = System.currentTimeMillis()
                Log.d(TAG, "Monitoring STARTED")
                result.success(null)
            }
            "stop" -> {
                monitoring = false
                Log.d(TAG, "Monitoring STOPPED")
                result.success(null)
            }
            "reset" -> {
                lastInteraction = System.currentTimeMillis()
                Log.d(TAG, "Timer RESET")
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        installTouchListener(binding.activity.window)
        Log.d(TAG, "onAttachedToActivity: installed touch listener")
    }

    override fun onDetachedFromActivity() {
        activityBinding = null
        Log.d(TAG, "onDetachedFromActivity")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        handler.removeCallbacks(idleLoop)
        Log.d(TAG, "onDetachedFromEngine")
    }

    private fun installTouchListener(window: Window) {
        val original = window.callback
        window.callback = object : Window.Callback by original {
            override fun dispatchTouchEvent(event: MotionEvent): Boolean {
                try {
                    if (monitoring && event.actionMasked != MotionEvent.ACTION_CANCEL) {
                        // reset on down/move/up
                        if (event.actionMasked == MotionEvent.ACTION_DOWN ||
                            event.actionMasked == MotionEvent.ACTION_MOVE ||
                            event.actionMasked == MotionEvent.ACTION_UP) {
                            lastInteraction = System.currentTimeMillis()
                            Log.d(TAG, "Touch detected -> reset lastInteraction")
                        }
                    }
                } catch (t: Throwable) {
                    Log.e(TAG, "dispatchTouchEvent error: ${t.message}")
                }
                return original.dispatchTouchEvent(event)
            }
        }
    }
}
