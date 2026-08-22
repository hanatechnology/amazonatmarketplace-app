package com.hanatech.marketplace

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

/**
 * Creates the notification channel referenced by the
 * `com.google.firebase.messaging.default_notification_channel_id` meta-data.
 *
 * The manifest only names the channel — it does not create it. On API 26+ a
 * notification posted to a channel that does not exist is dropped silently, so
 * this has to run before the first message arrives. Application (not
 * MainActivity) because FCM starts the process for a background message
 * without ever creating the activity.
 */
class AmazonatApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                DEFAULT_CHANNEL_ID,
                getString(R.string.default_notification_channel_name),
                // HIGH so order and refund updates surface as heads-up.
                NotificationManager.IMPORTANCE_HIGH,
            )
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    private companion object {
        // Must stay in sync with the meta-data value in AndroidManifest.xml.
        const val DEFAULT_CHANNEL_ID = "amazonat_default"
    }
}
