package com.example.screenshot_memory

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

open class RebootReceiver : RestartReceiver()
open class UpgradeReceiver : RestartReceiver()

open class RestartReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        scheduleWatchNewlyCreatedImages(context)
    }
}