package com.example.toothwatch

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.widget.Toast
import androidx.core.app.NotificationCompat


class TimerService : Service() {
    private var timerStartMillis = 0L;
    private val binder = TimerBinder();
    private val handler = Handler();
    private val notificationUpdateRunner = object : Runnable {
        override fun run() {
            val notification: Notification = _createNotification()

            val mNotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            mNotificationManager.notify(NOTIFICATION_ID, notification)

            // Post slightly more frequently than every second because this function takes time
            // we don't want to skip over a second and look unresponsive
            handler.postDelayed(this, 500)
        }
    }

    companion object {
        const val MS_SINCE_EPOCH_EXTRA = "TimerService.StartUTCTime";
        const val START_SECONDS_EXTRA = "TimerService.StartSeconds";


        const val NOTIFICATION_CHANNEL_ID = "ToothwatchTimerServiceNotifications";
        const val NOTIFICATION_ID = 1;
    }

    inner class TimerBinder : Binder() {
        fun getService() : TimerService {
            return this@TimerService;
        }
    }

    fun getElapsedSeconds() : Double {
        return (System.currentTimeMillis() - timerStartMillis) / 1000.0;
    }

    override fun onBind(intent: Intent): IBinder {
        return binder;
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Toast.makeText(this, "service starting", Toast.LENGTH_SHORT).show()
        if (intent != null) {
            timerStartMillis = intent.getLongExtra(MS_SINCE_EPOCH_EXTRA, System.currentTimeMillis());
            timerStartMillis -= (intent.getDoubleExtra(START_SECONDS_EXTRA, 0.0) * 1000).toLong();
        }

        _createNotificationChannel()
        val notification = _createNotification()
        startForeground(NOTIFICATION_ID, notification)

        handler.postDelayed(notificationUpdateRunner, 1000);

        return START_NOT_STICKY
    }

    override fun onDestroy() {
        Toast.makeText(this, "service destroyed", Toast.LENGTH_SHORT).show()
        handler.removeCallbacksAndMessages(null);
        val mNotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        mNotificationManager.cancel(NOTIFICATION_ID);
    }

    private fun _createNotification() : Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, 0)

        // https://stackoverflow.com/a/54097773/4248422
        val secs = getElapsedSeconds().toInt()
        val formattedTime = "${(secs / 60).toString().padStart(2, '0')}:${(secs % 60).toString().padStart(2, '0')}"

        return NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
                .setContentTitle("Toothwatch")
                .setContentText(formattedTime)
                .setSmallIcon(R.drawable.ic_baseline_child_care_24)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .build()
    }

    private fun _createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                    NOTIFICATION_CHANNEL_ID,
                    "Foreground Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager: NotificationManager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }
}
