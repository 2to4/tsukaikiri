package com.futo4.tsukaikiri

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        OnDeviceAiPlugin(applicationContext)
            .register(flutterEngine.dartExecutor.binaryMessenger)
    }
}
