package com.example.toothwatch

import android.content.*
import android.os.Bundle
import android.os.IBinder
import android.os.PersistableBundle
import android.preference.PreferenceManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    val TAG = "MainActivity"
    private val FLUTTER_CHANNEL = "com.example.toothwatch/timer";
    private val DESTROYED_SAFELY_PREF = "ToothwatchDestroyedSafely"
    var wasDestroyedSafely : Boolean = false;

    override fun onStart() {
        super.onStart()

        val prefs = PreferenceManager.getDefaultSharedPreferences(this)
        wasDestroyedSafely = prefs.getBoolean(DESTROYED_SAFELY_PREF, false)
        // Set it to false, so if we stop abnormally it is left unchanged and we can pick that up later.
        prefs.edit().putBoolean(DESTROYED_SAFELY_PREF, false).apply()
    }

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
                } else if (call.method == "getIfDestroyedSafely") {
                    result.success(wasDestroyedSafely)
                } else {
                    result.notImplemented()
                }
        }
    }

    override fun onStop() {
        super.onStop()

        val prefs = PreferenceManager.getDefaultSharedPreferences(this)
        // We are being safely destroyed
        prefs.edit().putBoolean(DESTROYED_SAFELY_PREF, true).apply()

        // TODO - stop leaking timer service?
        unbindService()
    }

    private fun startTimerService(stateJson: String) {
        val service = Intent(this, TimerService::class.java)
        service.putExtra(TimerService.STATE_JSON_ID, stateJson)

        startService(service)
        bindService(service, connection, 0)
    }

    private fun closeTimerServiceIfPresent() : Boolean {
        val hadService = connection.timerService != null
        unbindService()
        val service = Intent(this, TimerService::class.java)
        Log.i(TAG, "Stopping service")
        stopService(service)
        return hadService
    }

    private fun unbindService() {
        if (connection.timerService != null) {
            Log.i(TAG, "Unbinding service as was not null")
            connection.unbindService(this)
        }
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
