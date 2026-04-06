package com.prism.prism

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.prism.security/settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isAutoTimeEnabled") {
                val autoTime = Settings.Global.getInt(contentResolver, Settings.Global.AUTO_TIME, 0)
                result.success(autoTime == 1)
            } else {
                result.notImplemented()
            }
        }
    }
}
