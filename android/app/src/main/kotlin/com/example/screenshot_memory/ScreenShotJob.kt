package com.example.screenshot_memory

import android.app.job.JobInfo
import android.app.job.JobInfo.TriggerContentUri
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ComponentName
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.RequiresApi


val MEDIA_URI: Uri = Uri.parse("content://" + MediaStore.AUTHORITY + "/")

@RequiresApi(Build.VERSION_CODES.N)
fun createJob(): JobInfo {
    return JobInfo.Builder(12, ComponentName(BuildConfig.APPLICATION_ID, PhotosContentJob::class.java.name)).apply {
        addTriggerContentUri(TriggerContentUri(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                TriggerContentUri.FLAG_NOTIFY_FOR_DESCENDANTS))
        addTriggerContentUri(TriggerContentUri(MEDIA_URI, 0))
    }.build()
}

@RequiresApi(Build.VERSION_CODES.N)
fun scheduleWatchNewlyCreatedImages(context: Context) {
    val js: JobScheduler = context.getSystemService(Context.JOB_SCHEDULER_SERVICE) as JobScheduler
    js.schedule(createJob())
}

val PROJECTION = arrayOf(
        MediaStore.Images.ImageColumns._ID, MediaStore.Images.ImageColumns.DATA
)

class PhotosContentJob : JobService() {

    override fun onStopJob(p0: JobParameters?): Boolean {
        return true
    }

    @RequiresApi(Build.VERSION_CODES.N)
    override fun onStartJob(parameter: JobParameters?): Boolean {
        scheduleWatchNewlyCreatedImages(this)
        Log.d(PhotosContentJob::class.java.name, "START JOB: ${parameter?.triggeredContentUris?.map { it.toString() }?.reduce { acc, uri -> "$acc,$uri" }}")

        val listOfPaths = mutableListOf<String>()

        parameter?.triggeredContentUris?.map { it.pathSegments.last() }?.toSet()?.forEach { id ->
            Log.d(PhotosContentJob::class.java.name, "Check id $id")

            val cursor = contentResolver.query(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                    PROJECTION, "${MediaStore.Images.ImageColumns._ID} = '$id'", null, null)

            if (cursor?.moveToFirst() == true) {
                cursor.getString(1)?.let { listOfPaths.add(it) }
            }

            cursor?.close()
        }


        Log.d(PhotosContentJob::class.java.name, "Paths: ${if (listOfPaths.isEmpty()) "" else listOfPaths.reduce { acc, uri -> "$acc,$uri" }}")

        // ANDROID P does not work, needs to be started from a forground context, or notification
//        if (listOfPaths.isNotEmpty()) {
//            val intent = Intent(this, MainActivity::class.java)
//            intent.putExtra(MainActivity.EXTRA_SCREENSHOT_PATH, listOfPaths[0])
//            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//            startActivity(intent)
//        }

        return false
    }

}