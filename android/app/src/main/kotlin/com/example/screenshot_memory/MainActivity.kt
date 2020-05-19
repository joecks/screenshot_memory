package com.example.screenshot_memory

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Parcelable
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {
    companion object {
        const val EXTRA_SCREENSHOT_PATH = "screenshot_path"
    }

    private var screenshotPath : String? = null;

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor, "newIntent").setMethodCallHandler { call, result ->
            if (call.method?.contentEquals("getScreenshotPath") == true) {
                screenshotPath?.let {
                    result.success(screenshotPath)
                    screenshotPath = null
                }
            }
        }
//        flutterEngine.dartExecutor.se

//        if ()
//        MethodChannel(flutterEngine.dartExecutor, "newIntent").invokeMethod("onScreenshotPathReceived", )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(MainActivity::class.java.simpleName, "OnCreate called");

        (intent.getParcelableExtra<Parcelable>(Intent.EXTRA_STREAM) as? Uri)?.let {
            screenshotPath = queryMediaForPath(it)
        }

        super.onCreate(savedInstanceState)



//        if (intent.data != null) {
//            MethodChannel(flutterEngine.dartExecutor, "newIntent").invokeMethod("onScreenshotPathReceived", intent.data.toString())
//        }


//        scheduleWatchNewlyCreatedImages(this)
    }

    private fun queryMediaForPath(uri: Uri): String? {
        val id = uri.pathSegments.last()
        val cursor = contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                PROJECTION, "${MediaStore.Images.ImageColumns._ID} = '$id'", null, null)
        cursor.use {
            if (it?.moveToFirst() == true) {
                return it.getString(1)
            }

            return null
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        Log.d(MainActivity::class.java.simpleName, "New intent received");
    }
}






