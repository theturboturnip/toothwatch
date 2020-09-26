package com.example.toothwatch

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain
import io.flutter.view.FlutterNativeView
import io.flutter.view.FlutterRunArguments
import java.lang.RuntimeException


class TimerService : Service() {
    private val TAG = "TimerService"

    private var notificationStaticStateJSON = ""
    private var backgroundFlutterView: FlutterNativeView? = null;
    private var backgroundChannel: MethodChannel? = null;

    private val binder = TimerBinder()
    private var handler: Handler? = null
    private val notificationUpdateRunner = object : Runnable {
        override fun run() {
            _evalNotificationDart { res ->
                val handler = (this@TimerService).handler
                if (handler != null) {
//                    Log.i(TAG, "Updating notif")
                    val persistentNotification = _createNotificationFromNotificationText(PERSIST_NOTIFICATION_CHANNEL_ID, res["persistentNotificationText"] as Map<String, Any>)
                            .setOngoing(true)
                            .setOnlyAlertOnce(true)
                            .build()
                    val mNotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    mNotificationManager.notify(PERSIST_NOTIFICATION_ID, persistentNotification)

                    val alertNotificationMap = res["alertNotificationText"] as Map<String, Any>?
                    if (alertNotificationMap != null) {
                        val alertNotification = _createNotificationFromNotificationText(ALERT_NOTIFICATION_CHANNEL_ID, alertNotificationMap)
                                .build()
                        mNotificationManager.notify(ALERT_NOTIFICATION_ID, alertNotification)
                    }

                    // Post slightly more frequently than every second because this function takes time
                    // we don't want to skip over a second and look unresponsive
                    // If the TimerService.handler is set to null, then it doesn't re-post
                    handler.postDelayed(this, (res["nextNotificationDelayMillis"] as Int).toLong())
                } else {
//                    Log.i(TAG, "Not updating notif")
                }
            }
        }
    }

    companion object {
        const val STATE_JSON_ID = "TimerService.StateJSON";

        const val PERSIST_NOTIFICATION_CHANNEL_ID = "ToothwatchTimerPersistent";
        const val PERSIST_NOTIFICATION_ID = 1;

        const val ALERT_NOTIFICATION_CHANNEL_ID = "ToothwatchTimerAlerts";
        const val ALERT_NOTIFICATION_ID = 2;
    }

    inner class TimerBinder : Binder() {
        fun getService() : TimerService {
            return this@TimerService;
        }
    }

    override fun onBind(intent: Intent): IBinder {
        return binder;
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent != null) {
            notificationStaticStateJSON = intent.getStringExtra(STATE_JSON_ID);
        } else {
            throw RuntimeException("Started TimerService with a null intent, which isn't allowed");
        }

        _getFlutterChannel()

        _createNotificationChannel(PERSIST_NOTIFICATION_CHANNEL_ID, "Persistent Timer Notification")
        _createNotificationChannel(ALERT_NOTIFICATION_CHANNEL_ID, "Timer Alerts", NotificationManager.IMPORTANCE_HIGH)
        handler = Handler()
        _createNotification { notification ->
            startForeground(PERSIST_NOTIFICATION_ID, notification)

            // The handler may be null here, in which case the onDestroy must have been called before this finished.
            // In that case, don't update the notification
            handler?.postDelayed(notificationUpdateRunner, 1000);
        }


        return START_STICKY
    }

    override fun onDestroy() {
        handler?.removeCallbacksAndMessages(null)
        handler?.removeCallbacks(notificationUpdateRunner)
        handler = null

        val mNotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        mNotificationManager.cancel(PERSIST_NOTIFICATION_ID)
    }

    class ResultCallback(val callback: (Any?) -> Unit) : MethodChannel.Result {
        override fun success(result: Any?) {
            callback(result)
        }

        override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
            throw RuntimeException(errorMessage)
        }
        override fun notImplemented() {
            throw RuntimeException("Function not implemented")
        }
    }

    private fun _evalNotificationDart(callback: (Map<String, Any>) -> Unit) {
        _getFlutterChannel().invokeMethod(
                "getNotificationJSON",
                notificationStaticStateJSON,
                ResultCallback { result ->
                    val res = result as Map<String, Any>
                    this.notificationStaticStateJSON = res["newPersistentStateJSONStr"] as String
                    callback(res)
                }
        )
    }

    private fun _createNotification(callback: (Notification) -> Unit) {
        _evalNotificationDart {
            res ->
            val notification = _createNotificationFromNotificationText(PERSIST_NOTIFICATION_CHANNEL_ID, res["persistentNotificationText"] as Map<String, Any>)
                    .setOngoing(true)
                    .setOnlyAlertOnce(true)
                    .build()
            callback(notification)
        }
    }

    private fun _createNotificationFromNotificationText(channel_id: String, notificationText: Map<String, Any>) : NotificationCompat.Builder {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, 0)

        return NotificationCompat.Builder(this, channel_id)
                .setContentTitle(notificationText["title"] as? String)
                .setContentText(notificationText["subtitle"] as? String)
                .setSmallIcon(R.drawable.ic_baseline_child_care_24)
                .setContentIntent(pendingIntent)
    }

    private fun _createNotificationChannel(notificationChannelId: String, name: String, importance: Int = NotificationManager.IMPORTANCE_DEFAULT) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                    notificationChannelId,
                    name,
                    importance
            )
            val manager: NotificationManager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun _getFlutterChannel() : MethodChannel {
        if (backgroundFlutterView == null) {
            // Grab the callback handle for the callback dispatcher from
            // storage.
            val callbackHandle = TimerBackgroundChannelHelper.getRawHandle(this.applicationContext)

            // Retrieve the actual callback information needed to invoke it.
            val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)

            if (callbackInfo == null) {
                Log.e(TAG, "Fatal: failed to find callback")
                throw RuntimeException("Failed to find callback")
            }

            // Create a FlutterNativeView with no drawing surface (i.e., a
            // background view).
            backgroundFlutterView = FlutterNativeView(this, true)

            // Register all plugins for the application with our new
            // FlutterNativeView's plugin registry. Other plugins will not
            // work when running in the background if this isn't done!
//            val registry = backgroundFlutterView!!.pluginRegistry
//            sPluginRegistrantCallback.registerWith(registry)

            val args = FlutterRunArguments()
            args.bundlePath = FlutterMain.findAppBundlePath()
            args.entrypoint = callbackInfo.callbackName
            args.libraryPath = callbackInfo.callbackLibraryPath

            // Start running callback dispatcher code in our background view.
            backgroundFlutterView!!.runFromBundle(args)
        }

        if (backgroundChannel == null) {
            backgroundChannel = MethodChannel(backgroundFlutterView,
                    "com.example.toothwatch/timer_background")
        }
        FlutterMain.startInitialization(this)
        FlutterMain.ensureInitializationComplete(this, arrayOf())
        return backgroundChannel as MethodChannel
    }
}
