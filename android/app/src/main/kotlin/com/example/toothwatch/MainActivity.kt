package com.example.toothwatch

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    val TAG = "MainActivity"
    private val FLUTTER_CHANNEL = "com.example.toothwatch/timer";

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FLUTTER_CHANNEL).setMethodCallHandler {
            call, result ->
                if (call.method == "setBackgroundChannelHandle") {
                    TimerBackgroundChannelHelper.setHandle(this.applicationContext, call.arguments as Long)
                } else if (call.method == "startTimerService") {
                    startTimerService(call.argument<String>("stateJson") ?: "");
                    result.success(null);
                } else if (call.method == "closeTimerServiceIfPresent") {
                    val hadService = closeTimerServiceIfPresent()
                    result.success(hadService)
                } else {
                    result.notImplemented()
                }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        closeTimerServiceIfPresent()
        // TODO - This should probably stop the timer - this used to be implicit(?) before, because state was tied to the notification. But now that it isn't, the app can """keep counting""" while the notification isn't up.
    }

    private fun startTimerService(stateJson: String) {
        val service = Intent(this, TimerService::class.java)
        service.putExtra(TimerService.STATE_JSON_ID, stateJson)

        startService(service)
        bindService(service, connection, 0)
    }

    private fun closeTimerServiceIfPresent() : Boolean {
        val hadService = connection.timerService != null
        val service = Intent(this, TimerService::class.java)
        if (connection.timerService != null) {
            Log.i(TAG, "Unbinding service as was not null")
            connection.unbindService(this)
        }
        Log.i(TAG, "Stopping service")
        stopService(service)
        return hadService
    }

    private val connection = object : ServiceConnection {
        val TAG = "TimerServiceConnection";

        var timerService: TimerService? = null;

        fun unbindService(context: Context) {
            timerService = null
            context.unbindService(this)
            Log.i(TAG, "Service unbound, now $timerService")
        }

        override fun onServiceConnected(className: ComponentName?,
                                        service: IBinder) {
            val binder = service as TimerService.TimerBinder
            timerService = binder.getService()
            Log.i(TAG, "Service connected, now $timerService")
        }

        override fun onBindingDied(name: ComponentName?) {
            timerService = null
            Log.e(TAG, "Binding died, now $timerService")
        }

        // This function is only for when the service is killed or crashes
        override fun onServiceDisconnected(arg0: ComponentName?) {
            timerService = null
            Log.i(TAG, "Service crashed, now $timerService")
        }
    }
}
